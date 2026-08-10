package com.sara.automation.tasks;

import com.sara.automation.interactions.OneScriptDynamicElements;
import com.sara.automation.utils.ResilientFormActions;
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
 * Tarea GENÉRICA para los módulos tipo editGrid del formulario de Creación/Edición de Casos
 * (Novedades, Finalización, Documentación CNM, ...). Todos comparten el mismo patrón:
 *
 *   1. Abrir la pestaña indicada (tabHref, p. ej. "#finalizacion").
 *   2. Clic en "Crear" (botón del editGrid en la pestaña activa).
 *   3. En el DIALOG: seleccionar la PRIMERA opción de TODOS los dropdowns custom (sin importar
 *      sus nombres) y escribir una observación corta si hay textarea.
 *   4. Guardar el dialog.
 *   5. Guardado general y espera de la recarga (para no dejar el frame desprendido al paso siguiente).
 */
public class CrearRegistroEnTab implements Task {

    private static final String SCOPE_DIALOG = ".formio-dialog-content";

    private static final By DROPDOWNS_DIALOG = By.cssSelector(SCOPE_DIALOG + " .custom-dropdown-control");
    private static final By TEXTAREA_OBS = By.cssSelector(SCOPE_DIALOG + " textarea.form-control[maxlength='1024']");
    private static final By BTN_GUARDAR_DIALOG = By.xpath(
            "//div[contains(@class,'formio-dialog-content')]//button[contains(@class,'btn-primary') and normalize-space(.)='Guardar']");
    private static final By BTN_GUARDAR_DIALOG_FALLBACK = By.xpath(
            "//div[contains(@class,'formio-dialog-content')]//button[contains(@class,'btn-primary')]");
    private static final By BTN_CREAR_ACTIVO = By.xpath(
            "//div[contains(@class,'tab-pane') and contains(@class,'active')]//button[contains(@class,'btn-primary') and contains(normalize-space(.),'Crear')]");
    private static final By BTN_CREAR_FALLBACK = By.xpath(
            "//button[contains(@class,'btn-primary') and contains(normalize-space(.),'Crear')]");
    private static final By BTN_GUARDAR_GENERAL = By.id("kaceCustomSubmit");
    private static final By BTN_GUARDAR_GENERAL_FALLBACK = By.cssSelector("button[name^='data[kaceCustomSubmit']");

    private final String tabHref;   // p. ej. "#finalizacion"
    private final String nombre;    // p. ej. "Finalización" (para logs)
    private final String textoObs;

    public CrearRegistroEnTab(String tabHref, String nombre) {
        this.tabHref = tabHref;
        this.nombre = nombre;
        this.textoObs = nombre + " de prueba automatizada";
    }

    public static Performable en(String tabHref, String nombre) {
        return instrumented(CrearRegistroEnTab.class, tabHref, nombre);
    }

    @Override
    @Step("Crear registro en la pestaña #tabHref: Crear, diligenciar y guardar")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        JavascriptExecutor js = (JavascriptExecutor) driver;
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(40));
        By tabBy = By.cssSelector("a[href='" + tabHref + "']");

        System.out.println("\n  [CrearRegistroEnTab:" + nombre + "] ==================== INICIO ====================");

        // 1. Entrar al iframe y abrir la pestaña.
        // Cada submódulo (Finalización, Documentación CNM, Escalamientos Sura, ...) es
        // INDEPENDIENTE: el paso previo puede haber recargado el DOM justo antes de este punto,
        // por eso localizamos y hacemos clic dentro del mismo ciclo de reintento (re-localiza por
        // selector si el elemento queda stale) en vez de reutilizar una referencia ya obtenida.
        entrarAlFrameConTab(driver, wait, tabBy);
        ResilientFormActions.clickConReintentoStaleSafe(driver, tabBy, tabBy, 20, 3);
        System.out.println("  [CrearRegistroEnTab:" + nombre + "] ✓ Pestaña abierta");
        sleep(800);

        // CRÍTICO: Esperar a que el editGrid DENTRO de la pestaña activa esté verdaderamente listo.
        // Form.io editGrid sufre un glitch ocasional: durante la primera carga, muestra simultáneamente
        // una fila en modo edición inline Y un diálogo cuando debería mostrar solo la tabla.
        // Este wait previene ese double-render esperando a que no haya filas en edición inline.
        esperarEditGridListoEnPestanaActiva(driver, wait);
        System.out.println("  [CrearRegistroEnTab:" + nombre + "] ✓ EditGrid listo (sin doble-render)");

        // 2. Clic en "Crear" (de la pestaña activa).
        ResilientFormActions.clickConReintentoStaleSafe(driver, BTN_CREAR_ACTIVO, BTN_CREAR_FALLBACK, 20, 3);
        System.out.println("  [CrearRegistroEnTab:" + nombre + "] ✓ Click en 'Crear'");

        // 3. Esperar el dialog y diligenciar TODOS los dropdowns (primera opción) + observación.
        wait.until(d -> !d.findElements(DROPDOWNS_DIALOG).isEmpty()
                || !d.findElements(TEXTAREA_OBS).isEmpty());
        diligenciarDropdownsDelDialog(driver, js);
        llenarObservacion(driver, js);

        // 4. Guardar el dialog y esperar a que cierre.
        ResilientFormActions.clickConReintentoStaleSafe(driver, BTN_GUARDAR_DIALOG, BTN_GUARDAR_DIALOG_FALLBACK, 15, 3);
        new WebDriverWait(driver, Duration.ofSeconds(15)).until(d ->
                d.findElements(By.cssSelector(SCOPE_DIALOG)).stream().noneMatch(WebElement::isDisplayed));
        System.out.println("  [CrearRegistroEnTab:" + nombre + "] ✓ Registro guardado (dialog cerrado)");

        // 5. Guardado general + espera de recarga.
        ResilientFormActions.clickConReintentoStaleSafe(driver, BTN_GUARDAR_GENERAL, BTN_GUARDAR_GENERAL_FALLBACK, 20, 3);
        System.out.println("  [CrearRegistroEnTab:" + nombre + "] ✓ Guardado general");

        driver.switchTo().defaultContent();
        sleep(3000);
        try {
            WebDriverWait recarga = new WebDriverWait(driver, Duration.ofSeconds(30));
            recarga.until(d -> "complete".equals(((JavascriptExecutor) d).executeScript("return document.readyState")));
            recarga.until(ExpectedConditions.presenceOfElementLocated(By.id("form_onescript_iframe")));
        } catch (Exception ignored) {
        }
        sleep(4000);
        driver.switchTo().defaultContent();
        System.out.println("  [CrearRegistroEnTab:" + nombre + "] ==================== ✓ FIN (página recargada) ====================\n");
    }

    /**
     * Selecciona la primera opción de cada dropdown del dialog que aún muestre "Elige una opción".
     * Re-consulta tras cada selección (el dialog se re-renderiza / hay cascadas).
     */
    private void diligenciarDropdownsDelDialog(WebDriver driver, JavascriptExecutor js) {
        for (int pasada = 1; pasada <= 8; pasada++) {
            WebElement pendiente = null;
            for (WebElement c : driver.findElements(DROPDOWNS_DIALOG)) {
                try {
                    if (c.isDisplayed() && c.getText().trim().toLowerCase().contains("elige una")) {
                        pendiente = c;
                        break;
                    }
                } catch (Exception ignored) {
                }
            }
            if (pendiente == null) {
                break; // no quedan dropdowns sin seleccionar
            }
            try {
                String valor = OneScriptDynamicElements.selectFirstOptionOfControl(driver, pendiente);
                System.out.println("  [CrearRegistroEnTab:" + nombre + "]   [dropdown] = " + valor);
            } catch (Exception e) {
                System.out.println("  [CrearRegistroEnTab:" + nombre + "]   ⚠ dropdown no listo, reintentando: " + e.getMessage());
                try {
                    js.executeScript("document.activeElement && document.activeElement.dispatchEvent(new KeyboardEvent('keydown',{key:'Escape',bubbles:true}));");
                } catch (Exception ignored) {
                }
            }
            sleep(700);
        }
    }

    private void llenarObservacion(WebDriver driver, JavascriptExecutor js) {
        for (WebElement t : driver.findElements(TEXTAREA_OBS)) {
            try {
                if (t.isDisplayed() && t.isEnabled()) {
                    setReactTextareaValue(js, t, textoObs);
                    System.out.println("  [CrearRegistroEnTab:" + nombre + "]   ✓ Observación escrita");
                    return;
                }
            } catch (Exception ignored) {
            }
        }
    }

    private void entrarAlFrameConTab(WebDriver driver, WebDriverWait wait, By tabBy) {
        boolean encontrado = wait.until(d -> {
            d.switchTo().defaultContent();
            if (!d.findElements(tabBy).isEmpty()) {
                return true;
            }
            List<WebElement> conocido = d.findElements(By.id("form_onescript_iframe"));
            if (!conocido.isEmpty()) {
                try {
                    d.switchTo().frame(conocido.get(0));
                    if (!d.findElements(tabBy).isEmpty()) {
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
                    if (!d.findElements(tabBy).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
            }
            d.switchTo().defaultContent();
            return false;
        });
        if (!encontrado) {
            throw new AssertionError("No se encontró la pestaña '" + tabHref + "' en la página ni en sus iframes.");
        }
    }

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

    /**
     * Espera a que el editGrid dentro de la pestaña activa esté "verdaderamente listo":
     * tabla visible, sin filas en modo edición inline (previene el doble-render de Form.io).
     */
    private void esperarEditGridListoEnPestanaActiva(WebDriver driver, WebDriverWait wait) {
        wait.until(d -> {
            // Buscar la pestaña activa
            java.util.List<WebElement> tabActive = d.findElements(
                    By.cssSelector(".tab-pane.active, [role='tabpanel'][style*='display: block']"));
            if (tabActive.isEmpty()) {
                return false;
            }
            WebElement tab = tabActive.get(0);

            try {
                // Dentro de la pestaña activa, debe haber un editGrid con tabla
                java.util.List<WebElement> tablas = tab.findElements(By.cssSelector("table.table"));
                if (tablas.isEmpty() || !tablas.get(0).isDisplayed()) {
                    return false;
                }

                // NO debe haber filas en modo edición inline (con botones Guardar/Cancelar)
                java.util.List<WebElement> filasConEdicion = tab.findElements(
                        By.cssSelector("tbody tr:has(button.btn[title*='Guardar']), tbody tr:has(button.btn[title*='Cancelar'])"));
                if (!filasConEdicion.isEmpty()) {
                    // Filas en edición inline detectadas; esperar a que desaparezcan
                    return false;
                }

                return true;
            } catch (Exception e) {
                return false;
            }
        });
    }

    private void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
