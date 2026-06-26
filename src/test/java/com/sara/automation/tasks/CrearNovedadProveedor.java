package com.sara.automation.tasks;

import com.sara.automation.interactions.OneScriptDynamicElements;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.List;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Crea una NOVEDAD del proveedor dentro del caso (pestaña "Novedades" del formulario de
 * Creación/Edición de Casos), tras diligenciar el proveedor y el guardado general.
 *
 * Flujo:
 *   1. Entra al iframe del formulario y abre la pestaña "Novedades".
 *   2. Clic en "Crear" (ref=editgrid-novedades_asistencia_movilidad-addRow).
 *   3. En el DIALOG (mismo patrón que gestión de proveedor): selecciona la primera opción de
 *      "Quien reporta la novedad", "Causa de la novedad" y "Se Genero Queja", y escribe una
 *      observación corta.
 *   4. Guarda el dialog y luego ejecuta el guardado general.
 *
 * Después de esto, el flujo continúa con los cambios de estado del caso.
 */
public class CrearNovedadProveedor implements Task {

    private static final String EDITGRID = "novedades_asistencia_movilidad";
    private static final String SCOPE_DIALOG = ".formio-dialog-content";

    private static final By TAB_NOVEDADES = By.cssSelector("a[href='#novedades']");
    private static final By BTN_CREAR = By.cssSelector("[ref='editgrid-" + EDITGRID + "-addRow']");
    private static final By BTN_CREAR_FALLBACK = By.xpath(
            "//div[contains(@class,'formio-component-" + EDITGRID + "')]//button[contains(normalize-space(.),'Crear')]");

    // Dropdowns custom dentro del dialog.
    private static final String COMP_QUIEN = "formio-component-quien_reporta_la_novedad";
    private static final String COMP_CAUSA = "formio-component-causa_de_la_novedad";
    private static final String COMP_QUEJA = "formio-component-se_genero_queja";

    private static final By TEXTAREA_OBS = By.cssSelector(SCOPE_DIALOG + " textarea.form-control[maxlength='1024']");
    private static final By BTN_GUARDAR_DIALOG = By.xpath(
            "//div[contains(@class,'formio-dialog-content')]//button[contains(@class,'btn-primary') and normalize-space(.)='Guardar']");
    private static final By BTN_GUARDAR_DIALOG_FALLBACK = By.xpath(
            "//div[contains(@class,'formio-dialog-content')]//button[contains(@class,'btn-primary')]");
    // Guardado general: id estable 'kaceCustomSubmit'.
    private static final By BTN_GUARDAR_GENERAL = By.id("kaceCustomSubmit");
    private static final By BTN_GUARDAR_GENERAL_FALLBACK = By.cssSelector("button[name^='data[kaceCustomSubmit']");

    private static final String TEXTO_OBS = "Novedad de prueba automatizada";

    public static Performable now() {
        return instrumented(CrearNovedadProveedor.class);
    }

    @Override
    @Step("Crear una novedad del proveedor: pestaña Novedades, Crear, diligenciar y guardar")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        JavascriptExecutor js = (JavascriptExecutor) driver;
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(40));

        System.out.println("\n  [CrearNovedadProveedor] ==================== CREAR NOVEDAD ====================");

        // 1. Entrar al iframe del formulario y abrir la pestaña "Novedades".
        entrarAlFrameConTab(driver, wait);
        WebElement tab = wait.until(ExpectedConditions.elementToBeClickable(TAB_NOVEDADES));
        clickResiliente(js, tab);
        System.out.println("  [CrearNovedadProveedor] ✓ Pestaña 'Novedades' abierta");

        // 2. Clic en "Crear".
        WebElement crear = esperarClickable(driver, BTN_CREAR, BTN_CREAR_FALLBACK, 20);
        clickResiliente(js, crear);
        System.out.println("  [CrearNovedadProveedor] ✓ Click en 'Crear'");

        // 3. Esperar el dialog y diligenciar los 3 dropdowns (primera opción válida) + observación.
        wait.until(d -> !d.findElements(By.cssSelector(SCOPE_DIALOG + " ." + COMP_QUIEN + " .custom-dropdown-control")).isEmpty());

        String quien = seleccionarDropdown(driver, js, COMP_QUIEN, "Quien reporta");
        System.out.println("  [CrearNovedadProveedor] ✓ Quien reporta = " + quien);
        sleep(700); // el dialog se re-renderiza tras seleccionar; dar respiro al siguiente dropdown
        String causa = seleccionarDropdown(driver, js, COMP_CAUSA, "Causa de la novedad");
        System.out.println("  [CrearNovedadProveedor] ✓ Causa de la novedad = " + causa);
        sleep(700);
        String queja = seleccionarDropdown(driver, js, COMP_QUEJA, "Se generó queja");
        System.out.println("  [CrearNovedadProveedor] ✓ Se generó queja = " + queja);

        WebElement textarea = wait.until(d -> {
            for (WebElement t : d.findElements(TEXTAREA_OBS)) {
                if (t.isDisplayed() && t.isEnabled()) {
                    return t;
                }
            }
            return null;
        });
        setReactTextareaValue(js, textarea, TEXTO_OBS);
        System.out.println("  [CrearNovedadProveedor] ✓ Observación escrita");

        // 4. Guardar el dialog y esperar a que cierre.
        WebElement btnGuardar = esperarClickable(driver, BTN_GUARDAR_DIALOG, BTN_GUARDAR_DIALOG_FALLBACK, 15);
        clickResiliente(js, btnGuardar);
        new WebDriverWait(driver, Duration.ofSeconds(15)).until(d ->
                d.findElements(TEXTAREA_OBS).stream().noneMatch(WebElement::isDisplayed));
        System.out.println("  [CrearNovedadProveedor] ✓ Novedad guardada (dialog cerrado)");

        // 5. Guardado general.
        WebElement btnGeneral = esperarPresencia(driver, BTN_GUARDAR_GENERAL, BTN_GUARDAR_GENERAL_FALLBACK, 20);
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", btnGeneral);
        clickResiliente(js, btnGeneral);
        System.out.println("  [CrearNovedadProveedor] ✓ Click en Guardar general");

        // CRÍTICO: el guardado general recarga la página. Si devolvemos el control de inmediato,
        // el siguiente paso (transición de estados) entra a un iframe que se desprende
        // ("target frame detached"). Esperamos a que la recarga termine y el form vuelva a estar.
        driver.switchTo().defaultContent();
        sleep(3000); // dar tiempo a que INICIE la recarga
        try {
            WebDriverWait recarga = new WebDriverWait(driver, Duration.ofSeconds(30));
            recarga.until(d -> "complete".equals(((JavascriptExecutor) d).executeScript("return document.readyState")));
            recarga.until(ExpectedConditions.presenceOfElementLocated(By.id("form_onescript_iframe")));
        } catch (Exception ignored) {
        }
        sleep(4000); // settle adicional para que el formulario quede interactivo
        driver.switchTo().defaultContent();
        System.out.println("  [CrearNovedadProveedor] ==================== ✓ NOVEDAD CREADA (página recargada) ====================\n");
    }

    /**
     * Selecciona la primera opción del dropdown custom (en el dialog), con reintento: el dialog
     * se re-renderiza tras cada selección, por lo que el siguiente dropdown puede tardar en estar
     * listo. Reintenta hasta 3 veces cerrando cualquier menú abierto entre intentos.
     */
    private String seleccionarDropdown(WebDriver driver, JavascriptExecutor js, String componentClass, String etiqueta) {
        RuntimeException ultimo = null;
        for (int intento = 1; intento <= 3; intento++) {
            try {
                return OneScriptDynamicElements.selectFirstCustomDropdownOption(driver, componentClass, SCOPE_DIALOG);
            } catch (RuntimeException e) {
                ultimo = e;
                System.out.println("  [CrearNovedadProveedor] ⚠ '" + etiqueta + "' no listo (intento " + intento + "/3), reintentando...");
                // Cerrar cualquier dropdown abierto (Escape) sin tocar el dialog, y esperar el re-render.
                try {
                    js.executeScript("document.activeElement && document.activeElement.dispatchEvent(new KeyboardEvent('keydown',{key:'Escape',bubbles:true}));");
                } catch (Exception ignored) {
                }
                sleep(1200);
            }
        }
        throw (ultimo != null) ? ultimo : new RuntimeException("No se pudo seleccionar el dropdown: " + etiqueta);
    }

    private void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    /** Localiza el iframe que contiene la pestaña "Novedades". */
    private void entrarAlFrameConTab(WebDriver driver, WebDriverWait wait) {
        boolean encontrado = wait.until(d -> {
            d.switchTo().defaultContent();
            if (!d.findElements(TAB_NOVEDADES).isEmpty()) {
                return true;
            }
            List<WebElement> conocido = d.findElements(By.id("form_onescript_iframe"));
            if (!conocido.isEmpty()) {
                try {
                    d.switchTo().frame(conocido.get(0));
                    if (!d.findElements(TAB_NOVEDADES).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
                d.switchTo().defaultContent();
            }
            for (WebElement frame : d.findElements(By.tagName("iframe"))) {
                try {
                    d.switchTo().defaultContent();
                    d.switchTo().frame(frame);
                    if (!d.findElements(TAB_NOVEDADES).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
            }
            d.switchTo().defaultContent();
            return false;
        });
        if (!encontrado) {
            throw new AssertionError("No se encontró la pestaña 'Novedades' (a[href='#novedades']) en la página ni en sus iframes.");
        }
        System.out.println("  [CrearNovedadProveedor] ✓ Formulario del caso localizado");
    }

    private WebElement esperarClickable(WebDriver driver, By principal, By fallback, int segundos) {
        try {
            return new WebDriverWait(driver, Duration.ofSeconds(segundos))
                    .until(ExpectedConditions.elementToBeClickable(principal));
        } catch (Exception e) {
            return new WebDriverWait(driver, Duration.ofSeconds(segundos))
                    .until(ExpectedConditions.elementToBeClickable(fallback));
        }
    }

    private WebElement esperarPresencia(WebDriver driver, By principal, By fallback, int segundos) {
        try {
            return new WebDriverWait(driver, Duration.ofSeconds(segundos))
                    .until(ExpectedConditions.presenceOfElementLocated(principal));
        } catch (Exception e) {
            return new WebDriverWait(driver, Duration.ofSeconds(segundos))
                    .until(ExpectedConditions.presenceOfElementLocated(fallback));
        }
    }

    /** Escribe en un textarea controlado por React/Form.io usando el SETTER NATIVO del prototipo. */
    private void setReactTextareaValue(JavascriptExecutor js, WebElement textarea, String valor) {
        js.executeScript(
                "var el = arguments[0]; var val = arguments[1];"
              + "var proto = window.HTMLTextAreaElement.prototype;"
              + "var setter = Object.getOwnPropertyDescriptor(proto, 'value').set;"
              + "el.focus();"
              + "setter.call(el, '');"
              + "el.dispatchEvent(new Event('input', {bubbles:true}));"
              + "setter.call(el, val);"
              + "el.dispatchEvent(new Event('input', {bubbles:true}));"
              + "el.dispatchEvent(new Event('change', {bubbles:true}));"
              + "el.dispatchEvent(new Event('blur', {bubbles:true}));",
                textarea, valor);
    }

    private void clickResiliente(JavascriptExecutor js, WebElement el) {
        try {
            js.executeScript("arguments[0].scrollIntoView({block:'center'});", el);
        } catch (Exception ignored) {
        }
        try {
            el.click();
        } catch (Exception e1) {
            try {
                js.executeScript("arguments[0].click();", el);
            } catch (Exception e2) {
                js.executeScript(
                        "var el=arguments[0];"
                      + "el.dispatchEvent(new MouseEvent('mousedown',{bubbles:true,cancelable:true,view:window}));"
                      + "el.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,cancelable:true,view:window}));"
                      + "el.click();", el);
            }
        }
    }
}
