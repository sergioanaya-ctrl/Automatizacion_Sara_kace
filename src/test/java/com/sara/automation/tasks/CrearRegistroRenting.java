package com.sara.automation.tasks;

import com.sara.automation.interactions.OneScriptDynamicElements;
import com.sara.automation.ui.RentingPage;
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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Random;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Crea un registro en el submódulo "Renting" del formulario de Creación/Edición de Casos
 * (editGrid {@code renting_asistencia_movilidad}, pestaña {@code #renting}).
 *
 * Flujo:
 *   1. Entra al iframe del formulario y abre la pestaña "Renting".
 *   2. Espera a que el editGrid esté listo (evita el doble-render de Form.io).
 *   3. Clic en "Crear" (ref=editgrid-renting_asistencia_movilidad-addRow).
 *   4. En el DIALOG diligencia los 4 dropdowns REQUERIDOS (primera opción válida de cada uno):
 *      responsable, Motivo, Tipo de llamada y Estado del escalamiento; escribe la Observación y,
 *      si el formulario la habilitara, la "Fecha y hora compromiso" (flatpickr, fecha futura).
 *   5. Guarda el dialog, espera su cierre y ejecuta el guardado general.
 *
 * PRECONDICIÓN: el caso debe haberse creado con la línea "RENTING" (servicios GRUA, GRUA MOTOS,
 * GRUA PESADOS PEQUENO/MEDIANO/GRANDE). Con otra línea la pestaña no se renderiza y la tarea
 * falla con un mensaje explícito.
 *
 * Submódulo INDEPENDIENTE: no comparte estado ni orden de ejecución con Novedades, Tareas de
 * monitoreo, Reprogramación de citas ni ningún otro submódulo.
 */
public class CrearRegistroRenting implements Task {

    private static final String TEXTO_OBS = "Renting de prueba automatizada";

    public static Performable now() {
        return instrumented(CrearRegistroRenting.class);
    }

    @Override
    @Step("Crear registro en la pestaña Renting: Crear, diligenciar y guardar")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        JavascriptExecutor js = (JavascriptExecutor) driver;
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(40));

        System.out.println("\n  [CrearRegistroRenting] ==================== CREAR REGISTRO RENTING ====================");

        // 1. Entrar al iframe del formulario y abrir la pestaña "Renting".
        // Cada submódulo es INDEPENDIENTE: el paso anterior pudo haber recargado el DOM justo antes
        // de este punto, así que localizamos y hacemos clic dentro del mismo ciclo de reintento
        // (re-localiza por selector si el elemento queda stale) en vez de reutilizar una referencia.
        entrarAlFrameConTab(driver, wait);
        ResilientFormActions.clickConReintentoStaleSafe(driver, RentingPage.TAB, RentingPage.TAB, 20, 3);
        System.out.println("  [CrearRegistroRenting] ✓ Pestaña 'Renting' abierta");
        sleep(800);

        // 2. CRÍTICO: esperar a que el editGrid esté verdaderamente listo. Form.io sufre un glitch
        // ocasional en la primera carga: muestra simultáneamente una fila en edición inline Y un
        // diálogo, cuando debería mostrar solo la tabla.
        esperarEditGridListo(driver, wait);
        System.out.println("  [CrearRegistroRenting] ✓ EditGrid listo (sin doble-render)");

        // 3. Clic en "Crear".
        ResilientFormActions.clickConReintentoStaleSafe(
                driver, RentingPage.BTN_CREAR, RentingPage.BTN_CREAR_FALLBACK, 20, 3);
        System.out.println("  [CrearRegistroRenting] ✓ Click en 'Crear'");

        // 4. Esperar el dialog (se da por abierto cuando ya existe el primer dropdown requerido).
        wait.until(d -> !d.findElements(By.cssSelector(
                RentingPage.SCOPE_DIALOG + " ." + RentingPage.COMP_RESPONSABLE + " .custom-dropdown-control")).isEmpty());
        System.out.println("  [CrearRegistroRenting] ✓ Dialog abierto");

        // 5. Los 4 dropdowns REQUERIDOS. Se elige la primera opción válida de cada uno (igual que
        // Novedades / Escalamientos sura): cualquier opción sirve para el caso de prueba y el
        // resultado es determinista, lo que hace reproducible cualquier fallo.
        // Se deja un respiro entre selecciones porque el dialog se re-renderiza tras cada una.
        seleccionarDropdown(driver, js, RentingPage.COMP_RESPONSABLE, "responsable");
        sleep(700);
        seleccionarDropdown(driver, js, RentingPage.COMP_MOTIVO, "Motivo");
        sleep(700);
        seleccionarDropdown(driver, js, RentingPage.COMP_TIPO_LLAMADA, "Tipo de llamada");
        sleep(700);
        seleccionarDropdown(driver, js, RentingPage.COMP_ESTADO_ESCALAMIENTO, "Estado del escalamiento");
        sleep(500);

        // 6. "Fecha y hora compromiso": llega deshabilitada y NO es requerida. Solo se diligencia
        // si alguna regla del formulario la habilitó tras las selecciones anteriores.
        diligenciarFechaCompromisoSiEstaHabilitada(driver);

        // 7. Observación.
        llenarObservacion(driver, js, wait);

        // 8. Guardar el dialog y esperar a que cierre.
        ResilientFormActions.clickConReintentoStaleSafe(
                driver, RentingPage.BTN_GUARDAR_DIALOG, RentingPage.BTN_GUARDAR_DIALOG_FALLBACK, 15, 3);
        new WebDriverWait(driver, Duration.ofSeconds(15)).until(d ->
                d.findElements(By.cssSelector(RentingPage.SCOPE_DIALOG)).stream().noneMatch(WebElement::isDisplayed));
        System.out.println("  [CrearRegistroRenting] ✓ Registro guardado (dialog cerrado)");

        // 9. Guardado general + espera de la recarga: si devolviéramos el control de inmediato, el
        // paso siguiente entraría a un iframe que se desprende a mitad de camino.
        ResilientFormActions.clickConReintentoStaleSafe(
                driver, RentingPage.BTN_GUARDAR_GENERAL, RentingPage.BTN_GUARDAR_GENERAL_FALLBACK, 20, 3);
        System.out.println("  [CrearRegistroRenting] ✓ Guardado general");

        driver.switchTo().defaultContent();
        sleep(3000);
        try {
            WebDriverWait recarga = new WebDriverWait(driver, Duration.ofSeconds(30));
            recarga.until(d -> "complete".equals(((JavascriptExecutor) d).executeScript("return document.readyState")));
            recarga.until(ExpectedConditions.presenceOfElementLocated(By.id("form_onescript_iframe")));
        } catch (Exception ignored) {
            // Si la espera activa no confirma la recarga, el sleep posterior da el margen necesario.
        }
        sleep(4000);
        driver.switchTo().defaultContent();

        System.out.println("  [CrearRegistroRenting] ==================== ✓ FIN (página recargada) ====================\n");
    }

    /**
     * Selecciona la primera opción válida del dropdown custom indicado, acotando la búsqueda al
     * dialog para no confundirlo con un componente homónimo del resto del formulario
     * (p. ej. el "Motivo" de Reprogramación de citas o el resumen del propio editGrid).
     */
    private void seleccionarDropdown(WebDriver driver, JavascriptExecutor js, String componentClass, String etiqueta) {
        try {
            String valor = OneScriptDynamicElements.selectFirstCustomDropdownOption(
                    driver, componentClass, RentingPage.SCOPE_DIALOG);
            System.out.println("  [CrearRegistroRenting] ✓ " + etiqueta + " = " + valor);
        } catch (Exception e) {
            // Cierra cualquier lista abierta antes de propagar: una lista desplegada tapa el resto
            // del dialog e impediría diagnosticar (o reintentar) el siguiente campo.
            try {
                js.executeScript("document.activeElement && document.activeElement.dispatchEvent("
                        + "new KeyboardEvent('keydown',{key:'Escape',bubbles:true}));");
            } catch (Exception ignored) {
                // El cierre es best-effort; no debe enmascarar el error real.
            }
            throw new AssertionError("No se pudo seleccionar el dropdown requerido '" + etiqueta
                    + "' (" + componentClass + ") del submódulo Renting: " + e.getMessage(), e);
        }
    }

    /**
     * Diligencia "Fecha y hora compromiso" únicamente si el formulario la habilitó. El campo llega
     * con disabled="disabled" y aria-required="false", por lo que omitirlo es el comportamiento
     * correcto y no bloquea el guardado.
     */
    private void diligenciarFechaCompromisoSiEstaHabilitada(WebDriver driver) {
        List<WebElement> inputs = driver.findElements(RentingPage.INPUT_FECHA_COMPROMISO);
        if (inputs.isEmpty()) {
            System.out.println("  [CrearRegistroRenting] · 'Fecha y hora compromiso' no presente, se omite");
            return;
        }
        WebElement hidden = inputs.get(0);
        if (!hidden.isEnabled() || hidden.getAttribute("disabled") != null) {
            System.out.println("  [CrearRegistroRenting] · 'Fecha y hora compromiso' deshabilitada (no requerida), se omite");
            return;
        }

        String fecha = LocalDateTime.now()
                .plusDays(1 + new Random().nextInt(7))
                .format(DateTimeFormatter.ofPattern("MM/dd/yyyy HH:mm"));
        try {
            // setDate(valor, true) dispara los eventos de change que Form.io necesita para
            // registrar el nuevo valor; se invoca sobre el input hidden, que es el que lleva
            // adjunta la instancia de flatpickr (el input visible es de solo lectura).
            Object ok = ((JavascriptExecutor) driver).executeScript(
                    "const hidden = arguments[0];"
                            + "if (hidden && hidden._flatpickr) {"
                            + "  hidden._flatpickr.setDate(arguments[1], true);"
                            + "  return true;"
                            + "}"
                            + "return false;",
                    hidden, fecha);
            if (Boolean.TRUE.equals(ok)) {
                System.out.println("  [CrearRegistroRenting] ✓ Fecha y hora compromiso = " + fecha);
            } else {
                System.out.println("  [CrearRegistroRenting] ⚠ El input no expone instancia flatpickr, se omite la fecha");
            }
        } catch (Exception e) {
            System.out.println("  [CrearRegistroRenting] ⚠ No se pudo fijar la fecha compromiso: " + e.getMessage());
        }
    }

    private void llenarObservacion(WebDriver driver, JavascriptExecutor js, WebDriverWait wait) {
        WebElement textarea = wait.until(d -> {
            for (By by : new By[]{RentingPage.TEXTAREA_OBSERVACION, RentingPage.TEXTAREA_OBSERVACION_FALLBACK}) {
                for (WebElement t : d.findElements(by)) {
                    try {
                        if (t.isDisplayed() && t.isEnabled()) {
                            return t;
                        }
                    } catch (Exception ignored) {
                        // Elemento stale durante el re-render: se reintenta en la próxima vuelta.
                    }
                }
            }
            return null;
        });
        setReactTextareaValue(js, textarea, TEXTO_OBS);
        System.out.println("  [CrearRegistroRenting] ✓ Observación escrita");
    }

    /**
     * Escribe en la textarea usando el setter nativo del prototipo: asignar .value directamente no
     * es detectado por el framework de la UI, y sendKeys es reinterceptado por Form.io.
     */
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
     * Busca la pestaña "Renting" en el documento principal y en los iframes de la página, y deja
     * el driver posicionado en el contexto donde la encontró.
     */
    private void entrarAlFrameConTab(WebDriver driver, WebDriverWait wait) {
        boolean encontrado;
        try {
            encontrado = wait.until(d -> {
                d.switchTo().defaultContent();
                if (!d.findElements(RentingPage.TAB).isEmpty()) {
                    return true;
                }
                List<WebElement> conocido = d.findElements(By.id("form_onescript_iframe"));
                if (!conocido.isEmpty()) {
                    try {
                        d.switchTo().frame(conocido.get(0));
                        if (!d.findElements(RentingPage.TAB).isEmpty()) {
                            return true;
                        }
                    } catch (Exception ignored) {
                        // El iframe pudo desprenderse por una recarga: se sigue con el barrido general.
                    }
                    d.switchTo().defaultContent();
                }
                for (WebElement frame : d.findElements(By.tagName("iframe"))) {
                    try {
                        d.switchTo().defaultContent();
                        d.switchTo().frame(frame);
                        if (!d.findElements(RentingPage.TAB).isEmpty()) {
                            return true;
                        }
                    } catch (Exception ignored) {
                        // Iframe no accesible o stale: se prueba el siguiente.
                    }
                }
                d.switchTo().defaultContent();
                return false;
            });
        } catch (org.openqa.selenium.TimeoutException e) {
            encontrado = false;
        }
        if (!encontrado) {
            throw new AssertionError(
                    "No se encontró la pestaña 'Renting' (#renting) en la página ni en sus iframes. "
                            + "Esta pestaña solo se renderiza cuando el caso se creó con la línea RENTING; "
                            + "verifica la columna 'linea' del feature.");
        }
    }

    /**
     * Espera a que el editGrid de la pestaña activa esté "verdaderamente listo": tabla visible y
     * sin filas en modo edición inline (previene el doble-render de Form.io).
     */
    private void esperarEditGridListo(WebDriver driver, WebDriverWait wait) {
        wait.until(d -> {
            List<WebElement> tabActive = d.findElements(
                    By.cssSelector(".tab-pane.active, [role='tabpanel'][style*='display: block']"));
            if (tabActive.isEmpty()) {
                return false;
            }
            WebElement tab = tabActive.get(0);
            try {
                List<WebElement> tablas = tab.findElements(By.cssSelector("table.table"));
                if (tablas.isEmpty() || !tablas.get(0).isDisplayed()) {
                    return false;
                }
                List<WebElement> filasEnEdicion = tab.findElements(By.cssSelector(
                        "tbody tr:has(button.btn[title*='Guardar']), tbody tr:has(button.btn[title*='Cancelar'])"));
                return filasEnEdicion.isEmpty();
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
