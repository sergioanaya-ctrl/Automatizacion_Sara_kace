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

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Crea una nueva tarea de monitoreo: abre el flujo de creación desde la tabla,
 * opcionalmente cambia el estado siguiente (Cancelado TM, Cerrada, etc.) y guarda.
 *
 * Flujo:
 *   1. Abre pestaña "Tareas de monitoreo"
 *   2. Clic en botón "Crear Tarea"
 *   3. Se abre modal de creación/edición
 *   4. Cambio opcional de estado siguiente
 *   5. Clic en "Guardar" del modal
 *   6. Tarea creada
 *
 * Selectores centralizados en: TareasDeMonitoreoPage
 */
public class CrearTareaDeMonitoreo implements Task {

    private final String estadoSiguiente; // null = dejar por defecto, o nombre del estado

    public CrearTareaDeMonitoreo(String estadoSiguiente) {
        this.estadoSiguiente = estadoSiguiente;
    }

    public static Performable conEstado(String estado) {
        return instrumented(CrearTareaDeMonitoreo.class, estado);
    }

    public static Performable sinCambiarEstado() {
        return instrumented(CrearTareaDeMonitoreo.class, (String) null);
    }

    @Override
    @Step("Crear tarea de monitoreo con estado '{estadoSiguiente}'")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));

        System.out.println("\n  [CrearTareaDeMonitoreo] ==================== CREAR TAREA ====================");

        // 1. Entrar al iframe
        entrarAlIframe(driver, wait);

        // 2. Abrir pestaña "Tareas de monitoreo"
        ResilientFormActions.clickConReintentoStaleSafe(driver, TareasDeMonitoreoPage.TAB_TAREAS, TareasDeMonitoreoPage.TAB_TAREAS, 20, 3);
        System.out.println("  [CrearTareaDeMonitoreo] ✓ Pestaña 'Tareas de monitoreo' abierta");
        sleep(1000);

        // 3. Esperar tabla visible
        wait.until(d -> {
            List<WebElement> tbody = d.findElements(TareasDeMonitoreoPage.TABLA_TAREAS);
            return !tbody.isEmpty() && tbody.get(0).isDisplayed();
        });
        System.out.println("  [CrearTareaDeMonitoreo] ✓ Tabla visible");

        // 4. Clic en "Crear Tarea"
        ResilientFormActions.clickConReintentoStaleSafe(driver, TareasDeMonitoreoPage.BTN_CREAR_TAREA, TareasDeMonitoreoPage.BTN_CREAR_TAREA_FALLBACK, 20, 3);
        System.out.println("  [CrearTareaDeMonitoreo] ✓ Clic en 'Crear Tarea'");
        sleep(2000); // dar tiempo a que se abra el modal

        // 5. Esperar modal de creación
        wait.until(d -> !d.findElements(TareasDeMonitoreoPage.MODAL_EDICION).isEmpty());
        System.out.println("  [CrearTareaDeMonitoreo] ✓ Modal abierto");
        sleep(1000);

        // 6. Cambiar estado siguiente si se proporciona
        if (estadoSiguiente != null && !estadoSiguiente.isEmpty()) {
            try {
                WebElement dropdown = wait.until(ExpectedConditions.presenceOfElementLocated(TareasDeMonitoreoPage.DROPDOWN_ESTADO));
                dropdown.click();
                sleep(500);

                WebElement opcion = driver.findElement(TareasDeMonitoreoPage.opcionEstado(estadoSiguiente));
                opcion.click();
                System.out.println("  [CrearTareaDeMonitoreo] ✓ Estado cambiado a: " + estadoSiguiente);
                sleep(800);
            } catch (Exception e) {
                System.out.println("  [CrearTareaDeMonitoreo] ⚠ No se pudo cambiar estado a: " + estadoSiguiente);
                // continuar de todas formas
            }
        }

        // 7. Clic en "Guardar" del modal
        ResilientFormActions.clickConReintentoStaleSafe(driver, TareasDeMonitoreoPage.BTN_GUARDAR_MODAL, TareasDeMonitoreoPage.BTN_GUARDAR_MODAL_FALLBACK, 20, 3);
        System.out.println("  [CrearTareaDeMonitoreo] ✓ Tarea guardada");

        // 8. Esperar a que modal se cierre
        sleep(2000);
        driver.switchTo().defaultContent();
        System.out.println("  [CrearTareaDeMonitoreo] ==================== ✓ FIN ====================\n");
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

    private void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
