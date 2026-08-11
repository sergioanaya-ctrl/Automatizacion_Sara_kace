package com.sara.automation.tasks;

import com.sara.automation.utils.ResilientFormActions;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.List;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Validación de negocio: verifica que se hayan creado tareas de monitoreo automáticamente.
 *
 * Las tareas de monitoreo se generan en el backend tras cambios de estado.
 * Esta task solo VALIDA que existan, sin crear nada manualmente.
 *
 * Nota: a veces se crean 3, a veces más. El objetivo es verificar que AL MENOS una exista.
 *
 * Flujo:
 *   1. Entra al iframe
 *   2. Abre pestaña "Tareas de monitoreo"
 *   3. Espera a que la tabla se cargue
 *   4. Verifica que tbody tenga al menos 1 fila (no esté vacía)
 *   5. Si falla: AssertionError con mensaje claro
 */
public class ValidarTareasDeMonitoreoCreadas implements Task {

    private static final By TAB_TAREAS = By.cssSelector("a[href='#tareasDeMonitoreo']");
    private static final By TABLA_TAREAS = By.cssSelector(".data-table__table tbody");

    public static Performable ahora() {
        return instrumented(ValidarTareasDeMonitoreoCreadas.class);
    }

    @Override
    @Step("Validar que se hayan creado tareas de monitoreo automáticamente")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));

        System.out.println("\n  [ValidarTareasDeMonitoreoCreadas] ==================== VALIDAR TAREAS ====================");

        // 1. Entrar al iframe
        entrarAlIframe(driver, wait);

        // 2. Abrir pestaña "Tareas de monitoreo"
        ResilientFormActions.clickConReintentoStaleSafe(driver, TAB_TAREAS, TAB_TAREAS, 20, 3);
        System.out.println("  [ValidarTareasDeMonitoreoCreadas] ✓ Pestaña 'Tareas de monitoreo' abierta");
        sleep(1000); // tabla puede tardar en renderizar

        // 3. Esperar a que tabla se cargue
        wait.until(d -> {
            List<WebElement> tbody = d.findElements(TABLA_TAREAS);
            return !tbody.isEmpty() && tbody.get(0).isDisplayed();
        });
        System.out.println("  [ValidarTareasDeMonitoreoCreadas] ✓ Tabla cargada");

        // 4. Validar que hay al menos 1 fila
        List<WebElement> filas = driver.findElements(By.cssSelector(".data-table__table tbody tr"));
        if (filas.isEmpty()) {
            throw new AssertionError("No se encontraron tareas de monitoreo creadas. La tabla está vacía.");
        }

        // Validar que no sea el mensaje "No hay subcasos disponibles"
        String textoTabla = driver.findElement(TABLA_TAREAS).getText();
        if (textoTabla.contains("No hay") || textoTabla.contains("disponibles")) {
            throw new AssertionError("Tabla de tareas vacía: " + textoTabla);
        }

        // 5. Capturar y loguear el tipo de cada tarea creada
        System.out.println("  [ValidarTareasDeMonitoreoCreadas] ✓ Validación exitosa: " + filas.size() + " tarea(s) creada(s)");
        System.out.println("  [ValidarTareasDeMonitoreoCreadas] Tareas creadas:");
        for (int i = 0; i < filas.size(); i++) {
            WebElement fila = filas.get(i);
            try {
                // Primera columna (td) contiene el tipo de tarea
                List<WebElement> celdas = fila.findElements(By.cssSelector("td"));
                if (!celdas.isEmpty()) {
                    String tipoTarea = celdas.get(0).getText().trim();
                    if (!tipoTarea.isEmpty()) {
                        System.out.println("    [" + (i + 1) + "] " + tipoTarea);
                    }
                }
            } catch (Exception e) {
                System.out.println("    [" + (i + 1) + "] (no se pudo extraer tipo)");
            }
        }

        driver.switchTo().defaultContent();
        System.out.println("  [ValidarTareasDeMonitoreoCreadas] ==================== ✓ FIN ====================\n");
    }

    private void entrarAlIframe(WebDriver driver, WebDriverWait wait) {
        boolean encontrado = wait.until(d -> {
            d.switchTo().defaultContent();
            if (!d.findElements(TAB_TAREAS).isEmpty()) {
                return true;
            }
            for (WebElement frame : d.findElements(By.id("form_onescript_iframe"))) {
                try {
                    d.switchTo().frame(frame);
                    if (!d.findElements(TAB_TAREAS).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
                d.switchTo().defaultContent();
            }
            return false;
        });
        if (!encontrado) {
            throw new AssertionError("No se encontró la pestaña 'Tareas de monitoreo' en la página.");
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
