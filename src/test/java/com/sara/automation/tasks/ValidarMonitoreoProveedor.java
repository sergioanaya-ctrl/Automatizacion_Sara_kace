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
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.List;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Navega a la pestaña "Monitoreo proveedor" y valida que exista al menos una fila
 * en el editGrid (ref="editgrid-monitoreo_proveedor_asistencia_movilidad-row"),
 * confirmando que el guardado del formulario de tareas de monitoreo fue exitoso.
 */
public class ValidarMonitoreoProveedor implements Task {

    private static final By TAB_MONITOREO_PROVEEDOR = By.cssSelector("a[href='#monitoreoProveedor']");
    private static final By FILAS_EDITGRID = By.cssSelector(
            "tr[ref='editgrid-monitoreo_proveedor_asistencia_movilidad-row']");

    public static Performable ahora() {
        return instrumented(ValidarMonitoreoProveedor.class);
    }

    @Override
    @Step("Validar que existe registro en pestaña 'Monitoreo proveedor'")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));

        System.out.println("\n  [ValidarMonitoreoProveedor] ==================== VALIDAR MONITOREO PROVEEDOR ====================");

        // 1. Entrar al iframe si aplica
        entrarAlIframe(driver, wait);

        // 2. Clic en pestaña "Monitoreo proveedor"
        ResilientFormActions.clickConReintentoStaleSafe(driver, TAB_MONITOREO_PROVEEDOR, TAB_MONITOREO_PROVEEDOR, 20, 3);
        System.out.println("  [ValidarMonitoreoProveedor] ✓ Pestaña 'Monitoreo proveedor' abierta");
        sleep(1500);

        // 3. Esperar y validar filas en el editGrid
        try {
            wait.until(d -> !d.findElements(FILAS_EDITGRID).isEmpty());
            List<WebElement> filas = driver.findElements(FILAS_EDITGRID);
            System.out.println("  [ValidarMonitoreoProveedor] ✓ Filas encontradas en editGrid: " + filas.size());

            // Imprimir contenido de las celdas de la primera fila para trazabilidad
            List<WebElement> celdas = filas.get(0).findElements(By.cssSelector("td.editgrid-table-column"));
            System.out.println("  [ValidarMonitoreoProveedor] --- Datos primera fila ---");
            for (int i = 0; i < celdas.size(); i++) {
                String texto = celdas.get(i).getText().trim();
                if (!texto.isEmpty()) {
                    System.out.println("  [ValidarMonitoreoProveedor]   [" + i + "] " + texto);
                }
            }

        } catch (Exception e) {
            throw new AssertionError(
                    "No se encontraron registros en 'Monitoreo proveedor'. El guardado pudo haber fallado. Detalle: " + e.getMessage(), e);
        }

        System.out.println("  [ValidarMonitoreoProveedor] ==================== ✓ FIN ====================\n");
    }

    private void entrarAlIframe(WebDriver driver, WebDriverWait wait) {
        wait.until(d -> {
            d.switchTo().defaultContent();
            if (!d.findElements(TAB_MONITOREO_PROVEEDOR).isEmpty()) {
                return true;
            }
            for (WebElement frame : d.findElements(By.id("form_onescript_iframe"))) {
                try {
                    d.switchTo().frame(frame);
                    if (!d.findElements(TAB_MONITOREO_PROVEEDOR).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
                d.switchTo().defaultContent();
            }
            return false;
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
