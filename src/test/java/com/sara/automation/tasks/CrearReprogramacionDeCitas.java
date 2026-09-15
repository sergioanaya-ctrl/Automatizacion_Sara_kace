package com.sara.automation.tasks;

import com.sara.automation.interactions.OneScriptDynamicElements;
import com.sara.automation.ui.ReprogramacionDeCitasPage;
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
 * Crea una reprogramación de cita en la pestaña "Reprogramación de citas": abre la pestaña,
 * clic en "Crear", confirma el SweetAlert2 opcional ("¿deseas continuar?"), llena el dialog
 * (Motivo, Fecha y hora nueva cita, Observación, ¿Quién solicita?) con datos aleatorios y
 * una fecha futura, guarda el dialog y guarda de forma general.
 *
 * Submódulo independiente, sin relación con "Tareas de monitoreo" ni con ningún otro
 * submódulo del formulario: no depende de su estado ni de su orden de ejecución.
 */
public class CrearReprogramacionDeCitas implements Task {

    public static Performable now() {
        return instrumented(CrearReprogramacionDeCitas.class);
    }

    @Override
    @Step("Crear reprogramación de cita")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));

        System.out.println("\n  [CrearReprogramacionDeCitas] ==================== CREAR REPROGRAMACIÓN ====================");

        // 1. Entrar al iframe
        entrarAlIframe(driver, wait);

        // 2. Abrir pestaña "Reprogramación de citas"
        ResilientFormActions.clickConReintentoStaleSafe(driver, ReprogramacionDeCitasPage.TAB, ReprogramacionDeCitasPage.TAB, 20, 3);
        System.out.println("  [CrearReprogramacionDeCitas] ✓ Pestaña 'Reprogramación de citas' abierta");
        sleep(1000);

        // 3. Confirmar SweetAlert2 si aparece al CAMBIAR de pestaña ("Hay tareas pendientes por
        // gestionar, deseas continuar?"). Si no aparece, se continúa directo al botón "Crear".
        confirmarSweetAlertSiAparece(driver);

        // 4. Clic en "Crear"
        ResilientFormActions.clickConReintentoStaleSafe(driver, ReprogramacionDeCitasPage.BTN_CREAR, ReprogramacionDeCitasPage.BTN_CREAR_FALLBACK, 20, 3);
        System.out.println("  [CrearReprogramacionDeCitas] ✓ Clic en 'Crear'");
        sleep(1500);

        // 5. Confirmar SweetAlert2 si además aparece tras el clic en "Crear" (por si acaso)
        confirmarSweetAlertSiAparece(driver);

        // 5. Esperar dialog de creación
        wait.until(d -> !d.findElements(ReprogramacionDeCitasPage.DIALOG_CONTENIDO).isEmpty());
        System.out.println("  [CrearReprogramacionDeCitas] ✓ Dialog abierto");
        sleep(1000);

        // 6. Motivo (custom dropdown aleatorio)
        seleccionarOpcionCustomDropdown(driver, wait, ReprogramacionDeCitasPage.SELECTOR_MOTIVO, "Motivo");
        sleep(500);

        // 7. Fecha y hora nueva cita (flatpickr, no puede ser menor a la fecha actual)
        LocalDateTime fechaFutura = LocalDateTime.now().plusDays(1 + new Random().nextInt(7));
        String fechaFormato = fechaFutura.format(DateTimeFormatter.ofPattern("MM/dd/yyyy HH:mm"));
        boolean fechaFijada = fijarFechaConFlatpickr(driver, wait, fechaFormato);
        if (fechaFijada) {
            System.out.println("  [CrearReprogramacionDeCitas] ✓ Fecha y hora nueva cita fijada vía flatpickr: " + fechaFormato);
        } else {
            System.out.println("  [CrearReprogramacionDeCitas] ⚠ No se pudo fijar la fecha vía flatpickr");
        }
        sleep(500);

        // 8. Observación
        try {
            WebElement observacion = wait.until(ExpectedConditions.presenceOfElementLocated(
                    ReprogramacionDeCitasPage.TEXTAREA_OBSERVACION));
            observacion.sendKeys("Reprogramación generada automáticamente - " + System.currentTimeMillis());
            System.out.println("  [CrearReprogramacionDeCitas] ✓ Observación llenada");
        } catch (Exception e) {
            System.out.println("  [CrearReprogramacionDeCitas] ⚠ No se pudo llenar Observación: " + e.getMessage());
        }
        sleep(500);

        // 9. ¿Quién solicita? (custom dropdown aleatorio)
        seleccionarOpcionCustomDropdown(driver, wait, ReprogramacionDeCitasPage.SELECTOR_QUIEN_SOLICITA, "¿Quién solicita?");
        sleep(500);

        // 10. Guardar el dialog
        WebElement btnGuardarDialog = wait.until(ExpectedConditions.elementToBeClickable(
                ReprogramacionDeCitasPage.BTN_GUARDAR_DIALOG));
        btnGuardarDialog.click();
        System.out.println("  [CrearReprogramacionDeCitas] ✓ Clic en 'Guardar' del dialog");
        sleep(1500);

        // 11. Esperar cierre del dialog
        esperarCierreDialog(driver, Duration.ofSeconds(8));
        driver.switchTo().defaultContent();

        // 12. Guardar general
        actor.attemptsTo(ClickGuardarEnIframe.clickGuardarEnIframe());
        System.out.println("  [CrearReprogramacionDeCitas] ✓ Clic en 'Guardar' general realizado");

        // 13. Espera a que la página se recargue tras el guardado general
        System.out.println("  [CrearReprogramacionDeCitas] Esperando a que la página se recargue completamente tras el guardado general...");
        sleep(15000);
        System.out.println("  [CrearReprogramacionDeCitas] Página recargada, lista para el siguiente paso");

        System.out.println("  [CrearReprogramacionDeCitas] ==================== ✓ FIN ====================\n");
    }

    private void entrarAlIframe(WebDriver driver, WebDriverWait wait) {
        boolean encontrado = wait.until(d -> {
            d.switchTo().defaultContent();
            if (!d.findElements(ReprogramacionDeCitasPage.TAB).isEmpty()) {
                return true;
            }
            for (WebElement frame : d.findElements(By.id("form_onescript_iframe"))) {
                try {
                    d.switchTo().frame(frame);
                    if (!d.findElements(ReprogramacionDeCitasPage.TAB).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
                d.switchTo().defaultContent();
            }
            return false;
        });
        if (!encontrado) {
            throw new AssertionError("No se encontró la pestaña 'Reprogramación de citas'.");
        }
    }

    /**
     * Confirma el modal SweetAlert2 ("Hay tareas pendientes por gestionar, deseas continuar?")
     * dando clic en "Sí" SOLO si aparece; de lo contrario continúa sin hacer nada.
     */
    private void confirmarSweetAlertSiAparece(WebDriver driver) {
        try {
            // Espera ACTIVA breve (no instantánea): el SweetAlert2 puede tardar un instante en
            // renderizar tras el cambio de pestaña. Si no aparece en ese margen, se asume que
            // no había tareas pendientes y se continúa directo, sin bloquear el flujo.
            long deadline = System.currentTimeMillis() + 3000;
            List<WebElement> popup = java.util.Collections.emptyList();
            while (System.currentTimeMillis() < deadline) {
                popup = driver.findElements(ReprogramacionDeCitasPage.SWAL_POPUP);
                if (!popup.isEmpty() && popup.get(0).isDisplayed()) {
                    break;
                }
                sleep(200);
            }

            if (!popup.isEmpty() && popup.get(0).isDisplayed()) {
                List<WebElement> btnSi = driver.findElements(ReprogramacionDeCitasPage.SWAL_BTN_SI);
                if (!btnSi.isEmpty()) {
                    btnSi.get(0).click();
                    System.out.println("  [CrearReprogramacionDeCitas] ✓ SweetAlert2 confirmado con 'Sí'");
                    sleep(800);
                }
            } else {
                System.out.println("  [CrearReprogramacionDeCitas] SweetAlert2 no apareció, continuando directo");
            }
        } catch (Exception e) {
            System.out.println("  [CrearReprogramacionDeCitas] SweetAlert2 no presente/ignorado: " + e.getMessage());
        }
    }

    private void esperarCierreDialog(WebDriver driver, Duration timeout) {
        try {
            new WebDriverWait(driver, timeout).until(
                    ExpectedConditions.invisibilityOfElementLocated(ReprogramacionDeCitasPage.DIALOG_CONTENIDO));
        } catch (Exception e) {
            System.out.println("  [CrearReprogramacionDeCitas] ⚠ Timeout esperando cierre del dialog: " + e.getMessage());
        }
    }

    /**
     * Fija la fecha usando la instancia flatpickr adjunta al input hidden real (id
     * "eqsgdd-fecha_y_hora_nueva_cita"). setDate(valor, true) dispara los eventos de change
     * necesarios para que Form.io detecte el nuevo valor.
     */
    private boolean fijarFechaConFlatpickr(WebDriver driver, WebDriverWait wait, String fechaFormato) {
        try {
            wait.until(d -> !d.findElements(By.id(ReprogramacionDeCitasPage.ID_INPUT_FECHA_HIDDEN)).isEmpty());
            Object resultado = ((JavascriptExecutor) driver).executeScript(
                    "const hidden = document.getElementById(arguments[1]);"
                            + "if (hidden && hidden._flatpickr) {"
                            + "  hidden._flatpickr.setDate(arguments[0], true);"
                            + "  return true;"
                            + "}"
                            + "return false;",
                    fechaFormato, ReprogramacionDeCitasPage.ID_INPUT_FECHA_HIDDEN);
            return resultado instanceof Boolean && (Boolean) resultado;
        } catch (Exception e) {
            System.out.println("  [CrearReprogramacionDeCitas] ⚠ Error fijando fecha vía flatpickr: " + e.getMessage());
            return false;
        }
    }

    private String leerTextoControl(WebDriver driver, String selectorContenedor) {
        try {
            Object texto = ((JavascriptExecutor) driver).executeScript(
                    "const el = document.querySelector(arguments[0] + ' .custom-dropdown-control');"
                            + "return el ? el.textContent.trim() : 'CONTROL_NO_ENCONTRADO';",
                    selectorContenedor);
            return texto != null ? texto.toString() : "NULL";
        } catch (Exception e) {
            return "ERROR: " + e.getMessage();
        }
    }

    private void seleccionarOpcionCustomDropdown(WebDriver driver, WebDriverWait wait, String selectorContenedor, String etiqueta) {
        System.out.println("  [CrearReprogramacionDeCitas] >> Dropdown '" + etiqueta + "' (" + selectorContenedor + ")");
        try {
            WebElement control = wait.until(ExpectedConditions.presenceOfElementLocated(
                    By.cssSelector(selectorContenedor + " .custom-dropdown-control")));

            String seleccionado = OneScriptDynamicElements.selectRandomOptionOfControl(driver, control);
            sleep(300);

            String textoFinal = leerTextoControl(driver, selectorContenedor);
            if (textoFinal.equalsIgnoreCase("Elige una opción") || textoFinal.contains("CONTROL_NO_ENCONTRADO")) {
                System.out.println("  [CrearReprogramacionDeCitas]    ✗ ADVERTENCIA: tras el clic el control sigue mostrando \"" + textoFinal + "\"");
            } else {
                System.out.println("  [CrearReprogramacionDeCitas]    ✓ " + etiqueta + " seleccionado: \"" + textoFinal + "\" (elegido=\"" + seleccionado + "\")");
            }
        } catch (Exception e) {
            System.out.println("  [CrearReprogramacionDeCitas]    ✗ Error en dropdown '" + etiqueta + "': " + e.getMessage());
        }
    }

    private void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
