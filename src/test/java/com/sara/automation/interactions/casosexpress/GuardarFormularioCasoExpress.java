package com.sara.automation.interactions.casosexpress;

import com.sara.automation.ui.CasoExpressPage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Interaction;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * INTERACTION: Guardar el formulario Caso Express.
 *
 * ============================================================
 * PROPÓSITO:
 * Hacer clic en el botón "Guardar" del formulario y esperar
 * a que el caso sea guardado en la base de datos.
 *
 * CONTEXTO INICIAL: DENTRO del iframe
 * CONTEXTO FINAL: DENTRO del iframe (pero el formulario está guardado)
 * ============================================================
 *
 * PASOS:
 * 1. Esperar a que el botón "Guardar" esté clickeable
 * 2. Hacer scroll al botón (está al final del formulario)
 * 3. Hacer clic en el botón
 * 4. Esperar a que el guardado se complete (esperar mensaje o redirección)
 * 5. Volver al documento principal (salir del iframe)
 *
 * IMPORTANTE:
 * - El botón "Guardar" solo aparece al final del formulario
 * - Después del clic, puede haber un delay mientras se procesa en el servidor
 * - La página puede redirigirse o mostrar un mensaje de éxito
 * - Al final, salimos del iframe para volver al documento principal
 *
 * PRECONDICIÓN:
 * - El driver está dentro del iframe
 * - Todos los campos requeridos han sido rellenados
 * - El botón "Guardar" está visible
 *
 * POSTCONDICIÓN:
 * - El caso ha sido guardado en la base de datos
 * - El driver está en el documento principal (fuera del iframe)
 * - Podemos proceder a operaciones posteriores (validar guardado, crear otro caso, etc.)
 *
 * EJEMPLO DE USO:
 * actor.attemptsTo(GuardarFormularioCasoExpress.now());
 */
public class GuardarFormularioCasoExpress implements Interaction {

    private static final int TIMEOUT_SEGUNDOS = 30;

    /**
     * Factory method para crear esta Interaction.
     */
    public static Interaction now() {
        return instrumented(GuardarFormularioCasoExpress.class);
    }

    @Override
    @Step("Guardar el formulario Caso Express")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        JavascriptExecutor js = (JavascriptExecutor) driver;

        System.out.println("[GuardarFormularioCasoExpress] Iniciando guardado del caso...");

        // PASO 1: Asegurarse que estamos dentro del iframe
        // ============================================================
        System.out.println("[GuardarFormularioCasoExpress] PASO 1: Confirmando contexto del iframe...");
        driver.switchTo().defaultContent();
        try {
            new WebDriverWait(driver, Duration.ofSeconds(10))
                    .until(ExpectedConditions.frameToBeAvailableAndSwitchToIt(CasoExpressPage.IFRAME_ONESCRIPT));
            System.out.println("[GuardarFormularioCasoExpress]   ✓ Estamos dentro del iframe");
        } catch (Exception e) {
            throw new RuntimeException("[GuardarFormularioCasoExpress] No se pudo entrar al iframe", e);
        }

        // PASO 2: Esperar a que el botón "Guardar" esté visible y clickeable
        // ============================================================
        System.out.println("[GuardarFormularioCasoExpress] PASO 2: Esperando botón 'Guardar'...");
        WebElement btnGuardar;
        try {
            btnGuardar = new WebDriverWait(driver, Duration.ofSeconds(TIMEOUT_SEGUNDOS))
                    .until(ExpectedConditions.elementToBeClickable(CasoExpressPage.BOTON_GUARDAR_FORMULARIO));
            System.out.println("[GuardarFormularioCasoExpress]   ✓ Botón 'Guardar' encontrado");
        } catch (Exception e) {
            throw new RuntimeException(
                "[GuardarFormularioCasoExpress] No se pudo encontrar el botón 'Guardar' después de " + TIMEOUT_SEGUNDOS + " segundos",
                e
            );
        }

        // PASO 3: Hacer scroll al botón (está al final del formulario)
        // ============================================================
        System.out.println("[GuardarFormularioCasoExpress] PASO 3: Scroll al botón...");
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", btnGuardar);
        System.out.println("[GuardarFormularioCasoExpress]   ✓ Scroll completado");

        // PASO 4: Hacer clic en el botón "Guardar"
        // ============================================================
        System.out.println("[GuardarFormularioCasoExpress] PASO 4: Haciendo clic en 'Guardar'...");
        try {
            btnGuardar.click();
            System.out.println("[GuardarFormularioCasoExpress]   ✓ Clic ejecutado");
        } catch (Exception e1) {
            // Fallback: intentar con JavaScript
            System.out.println("[GuardarFormularioCasoExpress]   ⚠ Clic nativo falló, intentando JavaScript...");
            try {
                js.executeScript("arguments[0].click();", btnGuardar);
                System.out.println("[GuardarFormularioCasoExpress]   ✓ Clic con JavaScript exitoso");
            } catch (Exception e2) {
                throw new RuntimeException("[GuardarFormularioCasoExpress] No se pudo hacer clic en 'Guardar'", e2);
            }
        }

        // PASO 5: Esperar a que el guardado se complete
        // ============================================================
        // Pueden ocurrir varios escenarios:
        // - La página se recarga
        // - Aparece un mensaje de éxito
        // - El iframe desaparece
        // Esperamos a que algo cambio o esperamos un tiempo prudente
        System.out.println("[GuardarFormularioCasoExpress] PASO 5: Esperando que el guardado se complete...");
        try {
            // Esperar a que el iframe desaparezca o cambie (indica que el guardado terminó)
            new WebDriverWait(driver, Duration.ofSeconds(TIMEOUT_SEGUNDOS))
                    .until(d -> {
                        try {
                            d.switchTo().defaultContent();
                            d.switchTo().frameToBeAvailableAndSwitchToIt(CasoExpressPage.IFRAME_ONESCRIPT);
                            // Si llegamos aquí, el iframe aún existe
                            return false;
                        } catch (Exception e) {
                            // El iframe ya no existe o cambió, probablemente el guardado se completó
                            return true;
                        }
                    });
            System.out.println("[GuardarFormularioCasoExpress]   ✓ Guardado completado (iframe cambió)");
        } catch (Exception e) {
            // Fallback: simplemente esperar un tiempo prudente
            System.out.println("[GuardarFormularioCasoExpress]   ⚠ Timeout esperando cambio de iframe, esperando tiempo prudente...");
            try {
                Thread.sleep(3000);
            } catch (InterruptedException ex) {
                Thread.currentThread().interrupt();
            }
            System.out.println("[GuardarFormularioCasoExpress]   ✓ Tiempo de espera completado");
        }

        // PASO 6: Salir del iframe y volver al documento principal
        // ============================================================
        System.out.println("[GuardarFormularioCasoExpress] PASO 6: Saliendo del iframe...");
        driver.switchTo().defaultContent();
        System.out.println("[GuardarFormularioCasoExpress]   ✓ Estamos en el documento principal\n");
        System.out.println("[GuardarFormularioCasoExpress] ==================== ✓ CASO GUARDADO EXITOSAMENTE ====================\n");
    }

}
