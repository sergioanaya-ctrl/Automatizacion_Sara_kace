package com.sara.automation.tasks;

import com.sara.automation.ui.TareasDeMonitoreoPage;
import com.sara.automation.utils.ResilientFormActions;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.List;
import java.util.Random;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Edita una tarea de monitoreo existente: abre el formulario de edición,
 * cambia su estado (Cerrada, Cancelada, etc.) y guarda.
 *
 * Flujo:
 *   1. Abre pestaña "Tareas de monitoreo"
 *   2. Localiza la primera tarea en la tabla
 *   3. Clic en botón "Editar" (icono lápiz)
 *   4. Se abre modal de edición
 *   5. Cambia estado en dropdown "Estado siguiente"
 *   6. Guarda
 *
 * Selectores centralizados en: TareasDeMonitoreoPage
 */
public class EditarTareaDeMonitoreo implements Task {

    private final String nuevoEstado;

    public EditarTareaDeMonitoreo(String nuevoEstado) {
        this.nuevoEstado = nuevoEstado;
    }

    public static Performable aEstado(String nuevoEstado) {
        return instrumented(EditarTareaDeMonitoreo.class, nuevoEstado);
    }

    @Override
    @Step("Editar primera tarea de monitoreo a estado '{nuevoEstado}'")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));

        System.out.println("\n  [EditarTareaDeMonitoreo] ==================== EDITAR TAREA ====================");

        // 1. Entrar al iframe
        entrarAlIframe(driver, wait);

        // 2. Abrir pestaña "Tareas de monitoreo"
        ResilientFormActions.clickConReintentoStaleSafe(driver, TareasDeMonitoreoPage.TAB_TAREAS, TareasDeMonitoreoPage.TAB_TAREAS, 20, 3);
        System.out.println("  [EditarTareaDeMonitoreo] ✓ Pestaña 'Tareas de monitoreo' abierta");
        sleep(1000);

        // 3. Esperar tabla visible
        wait.until(d -> {
            List<WebElement> tbody = d.findElements(TareasDeMonitoreoPage.TABLA_TAREAS);
            return !tbody.isEmpty() && tbody.get(0).isDisplayed();
        });
        System.out.println("  [EditarTareaDeMonitoreo] ✓ Tabla visible");

        // 4. Validar que hay al menos 1 tarea
        List<WebElement> filas = driver.findElements(TareasDeMonitoreoPage.FILAS_TABLA);
        if (filas.isEmpty()) {
            throw new AssertionError("No hay tareas de monitoreo para editar.");
        }

        // 5. Clic en botón "Editar" de la primera tarea
        ResilientFormActions.clickConReintentoStaleSafe(driver, TareasDeMonitoreoPage.BTN_EDITAR_PRIMERA, TareasDeMonitoreoPage.BTN_EDITAR_PRIMERA_FALLBACK, 20, 3);
        System.out.println("  [EditarTareaDeMonitoreo] ✓ Clic en botón 'Editar' de primera tarea");
        sleep(1500);

        // 6. Esperar modal de edición
        wait.until(d -> !d.findElements(TareasDeMonitoreoPage.MODAL_EDICION).isEmpty());
        System.out.println("  [EditarTareaDeMonitoreo] ✓ Modal de edición abierto");
        sleep(1000);

        // 6.5 Crear fila en editGrid (opcional, con datos aleatorios)
        crearFilaEditGridAleatorio(driver, wait);
        sleep(1000);

        // 7. Cambiar estado en dropdown
        try {
            WebElement dropdown = wait.until(ExpectedConditions.presenceOfElementLocated(TareasDeMonitoreoPage.DROPDOWN_ESTADO));
            dropdown.click();
            sleep(500);

            // Buscar opción en dropdown
            WebElement opcion = driver.findElement(TareasDeMonitoreoPage.opcionEstado(nuevoEstado));
            opcion.click();
            System.out.println("  [EditarTareaDeMonitoreo] ✓ Estado cambidao a: " + nuevoEstado);
        } catch (Exception e) {
            throw new RuntimeException("No se pudo cambiar el estado a: " + nuevoEstado, e);
        }

        // 8. Clic en Guardar
        ResilientFormActions.clickConReintentoStaleSafe(driver, TareasDeMonitoreoPage.BTN_GUARDAR_MODAL, TareasDeMonitoreoPage.BTN_GUARDAR_MODAL_FALLBACK, 20, 3);
        System.out.println("  [EditarTareaDeMonitoreo] ✓ Tarea guardada");

        // 9. Esperar a que modal se cierre
        sleep(2000);
        driver.switchTo().defaultContent();
        System.out.println("  [EditarTareaDeMonitoreo] ==================== ✓ FIN ====================\n");
    }

    private void entrarAlIframe(WebDriver driver, WebDriverWait wait) {
        boolean encontrado = wait.until(d -> {
            d.switchTo().defaultContent();
            if (!d.findElements(TareasDeMonitoreoPage.TAB_TAREAS).isEmpty()) {
                return true;
            }
            for (WebElement frame : d.findElements(By.id("form_onescript_iframe"))) {
                try {
                    d.switchTo().frame(frame);
                    if (!d.findElements(TareasDeMonitoreoPage.TAB_TAREAS).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
                d.switchTo().defaultContent();
            }
            return false;
        });
        if (!encontrado) {
            throw new AssertionError("No se encontró la pestaña 'Tareas de monitoreo'.");
        }
    }

    private void crearFilaEditGridAleatorio(WebDriver driver, WebDriverWait wait) {
        try {
            // Clic en "Crear" del editGrid
            WebElement btnCrearFila = wait.until(ExpectedConditions.elementToBeClickable(
                    TareasDeMonitoreoPage.BTN_CREAR_FILA_EDITGRID));
            btnCrearFila.click();
            System.out.println("  [EditarTareaDeMonitoreo] ✓ Dialog para crear fila abierto");
            sleep(1500);

            // Seleccionar opciones aleatorias en los 4 dropdowns
            seleccionarDropdownAleatorio(driver, "#custom-select-ehshd4", "Monitoreo con");
            sleep(400);
            seleccionarDropdownAleatorio(driver, "#custom-select-ecxhl4l", "Momento del servicio");
            sleep(400);
            seleccionarDropdownAleatorio(driver, "#custom-select-esi7kdj", "Respuesta a monitoreo");
            sleep(400);
            seleccionarDropdownAleatorio(driver, "#custom-select-esfdm2m", "Se generó queja");
            sleep(400);

            // Llenar observaciones con texto simple
            List<WebElement> textareas = driver.findElements(By.cssSelector(".formio-dialog-content textarea"));
            if (textareas.size() >= 2) {
                textareas.get(0).sendKeys("Observación del asesor - editada automáticamente");
                textareas.get(1).sendKeys("Observación del proveedor - editada automáticamente");
                System.out.println("  [EditarTareaDeMonitoreo] ✓ Observaciones llenadas");
            }

            sleep(500);

            // Guardar fila (botón dentro del dialog)
            WebElement btnGuardarFila = wait.until(ExpectedConditions.elementToBeClickable(
                    By.xpath("//div[contains(@class, 'formio-dialog-content')]//button[contains(text(), 'Guardar')]")));
            btnGuardarFila.click();
            System.out.println("  [EditarTareaDeMonitoreo] ✓ Fila en editGrid creada y guardada");
            sleep(1000);

        } catch (Exception e) {
            System.out.println("  [EditarTareaDeMonitoreo] ⚠ Error creando fila editGrid: " + e.getMessage());
        }
    }

    private void seleccionarDropdownAleatorio(WebDriver driver, String selectorDropdown, String etiqueta) {
        try {
            WebElement dropdown = driver.findElement(By.cssSelector(selectorDropdown));
            dropdown.click();
            sleep(300);

            List<WebElement> opciones = driver.findElements(By.cssSelector(selectorDropdown + " .custom-option"));
            if (!opciones.isEmpty()) {
                Random r = new Random();
                opciones.get(r.nextInt(opciones.size())).click();
                System.out.println("  [EditarTareaDeMonitoreo] ✓ " + etiqueta + " seleccionado aleatoriamente");
            }
        } catch (Exception e) {
            System.out.println("  [EditarTareaDeMonitoreo] ⚠ Error en dropdown '" + etiqueta + "': " + e.getMessage());
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
