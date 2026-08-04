package com.sara.automation.interactions.casosexpress;

import com.sara.automation.ui.CasoExpressPage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Interaction;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import net.serenitybdd.screenplay.waits.WaitUntil;
import net.serenitybdd.screenplay.actions.Click;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * INTERACTION: Habilitar la edición del formulario OneScript.
 *
 * ============================================================
 * PROPÓSITO:
 * El formulario viene en modo lectura ("Read-only").
 * Esta Interaction hace clic en el botón "Habilitar Formulario"
 * para que los campos pasen a modo editable.
 *
 * CONTEXTO INICIAL: DENTRO del iframe (después de EntrarAlIframeFormulario)
 * CONTEXTO FINAL: DENTRO del iframe (no cambia de contexto)
 * ============================================================
 *
 * PASOS:
 * 1. Esperar a que el botón "Habilitar Formulario" esté clickeable
 * 2. Hacer clic en el botón
 * 3. Esperar a que los campos estén habilitados (presencia de campos input/textarea)
 *
 * IMPORTANTE:
 * - Debe ejecutarse DENTRO del iframe
 * - Si se ejecuta fuera del iframe, fallará porque no verá los campos
 * - El botón tiene 3 selectores alternativos en caso que uno falle
 *
 * PRECONDICIÓN:
 * - El driver está dentro del iframe (usar EntrarAlIframeFormulario primero)
 * - El formulario está cargado pero en modo lectura
 *
 * POSTCONDICIÓN:
 * - El formulario está en modo edición
 * - Los campos input, select, textarea están habilitados
 * - Podemos escribir en los campos
 */
public class HabilitarFormularioCasoExpress implements Interaction {

    // Timeout para esperar el botón
    private static final int TIMEOUT_SEGUNDOS = 20;

    /**
     * Factory method para crear esta Interaction.
     */
    public static Interaction now() {
        return instrumented(HabilitarFormularioCasoExpress.class);
    }

    @Override
    @Step("Habilitar edición del formulario Caso Express (Habilitar Formulario)")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        JavascriptExecutor js = (JavascriptExecutor) driver;

        // PASO 1: Re-asegurarse que estamos dentro del iframe
        // ============================================================
        // Razón: Screenplay puede haber reseteado el contexto entre interacciones.
        // Por eso, re-cambiamos al iframe explícitamente.
        System.out.println("[HabilitarFormularioCasoExpress] PASO 1: Re-confirmar contexto del iframe...");
        driver.switchTo().defaultContent();
        try {
            new WebDriverWait(driver, Duration.ofSeconds(10))
                    .until(ExpectedConditions.frameToBeAvailableAndSwitchToIt(CasoExpressPage.IFRAME_ONESCRIPT));
            System.out.println("[HabilitarFormularioCasoExpress]   ✓ Estamos dentro del iframe");
        } catch (Exception e) {
            throw new RuntimeException("[HabilitarFormularioCasoExpress] No se pudo volver al iframe", e);
        }

        // PASO 2: Esperar y hacer clic en el botón "Habilitar Formulario"
        // ============================================================
        // Intentamos 3 estrategias diferentes:
        // 1. Selector CSS (más confiable si el HTML no cambia)
        // 2. XPath por texto (si el selector CSS cambió)
        // 3. JavaScript directo (última opción si Selenium no ve el elemento)
        System.out.println("[HabilitarFormularioCasoExpress] PASO 2: Buscando botón 'Habilitar Formulario'...");

        // Estrategia 1: CSS selector
        try {
            System.out.println("[HabilitarFormularioCasoExpress]   Intento 1: Usando CSS selector...");
            WebElement button = new WebDriverWait(driver, Duration.ofSeconds(TIMEOUT_SEGUNDOS))
                    .until(ExpectedConditions.elementToBeClickable(CasoExpressPage.BOTON_HABILITAR_FORMULARIO));

            // Scroll el botón a la vista (por si está abajo)
            js.executeScript("arguments[0].scrollIntoView({block:'center'});", button);
            System.out.println("[HabilitarFormularioCasoExpress]     Botón encontrado: '" + button.getText() + "'");

            // Hacer clic
            button.click();
            System.out.println("[HabilitarFormularioCasoExpress]     ✓ Clic exitoso (CSS)");
            esperarQueFormularioSeaEditable(driver);
            return;
        } catch (Exception e1) {
            System.out.println("[HabilitarFormularioCasoExpress]     ✗ CSS selector falló: " + e1.getMessage());
        }

        // Estrategia 2: XPath por texto
        try {
            System.out.println("[HabilitarFormularioCasoExpress]   Intento 2: Usando XPath por texto...");
            WebElement button = new WebDriverWait(driver, Duration.ofSeconds(TIMEOUT_SEGUNDOS))
                    .until(ExpectedConditions.elementToBeClickable(CasoExpressPage.BOTON_HABILITAR_FORMULARIO_XPATH));

            js.executeScript("arguments[0].scrollIntoView({block:'center'});", button);
            System.out.println("[HabilitarFormularioCasoExpress]     Botón encontrado: '" + button.getText() + "'");

            button.click();
            System.out.println("[HabilitarFormularioCasoExpress]     ✓ Clic exitoso (XPath)");
            esperarQueFormularioSeaEditable(driver);
            return;
        } catch (Exception e2) {
            System.out.println("[HabilitarFormularioCasoExpress]     ✗ XPath falló: " + e2.getMessage());
        }

        // Estrategia 3: JavaScript directo
        try {
            System.out.println("[HabilitarFormularioCasoExpress]   Intento 3: Usando JavaScript directo...");
            Object result = js.executeScript(
                "var buttons = document.querySelectorAll('button[name*=\"habilitar_edicion_del_caso\"]'); " +
                "if (buttons.length > 0) { " +
                "  buttons[0].scrollIntoView(true); " +
                "  buttons[0].click(); " +
                "  return 'clicked'; " +
                "} " +
                "return 'not-found';"
            );

            if ("clicked".equals(result)) {
                System.out.println("[HabilitarFormularioCasoExpress]     ✓ Clic exitoso (JavaScript)");
                esperarQueFormularioSeaEditable(driver);
                return;
            }
        } catch (Exception e3) {
            System.out.println("[HabilitarFormularioCasoExpress]     ✗ JavaScript falló: " + e3.getMessage());
        }

        // Si llegamos aquí, todos los intentos fallaron
        throw new RuntimeException(
            "[HabilitarFormularioCasoExpress] No se pudo encontrar ni hacer clic en el botón 'Habilitar Formulario'. " +
            "El selector puede haber cambiado o el formulario no cargó correctamente."
        );
    }

    /**
     * Esperar a que el formulario esté editable.
     * Verificamos que al menos un campo input o textarea esté presente en el DOM.
     */
    private void esperarQueFormularioSeaEditable(WebDriver driver) {
        System.out.println("[HabilitarFormularioCasoExpress] PASO 3: Esperando que el formulario sea editable...");
        try {
            new WebDriverWait(driver, Duration.ofSeconds(10))
                    .until(ExpectedConditions.presenceOfElementLocated(
                        org.openqa.selenium.By.cssSelector("input[type='text'], input[type='email'], textarea, select")
                    ));
            System.out.println("[HabilitarFormularioCasoExpress]   ✓ Formulario ahora está editable\n");
        } catch (Exception e) {
            throw new RuntimeException(
                "[HabilitarFormularioCasoExpress] El formulario no pasó a modo editable después del clic",
                e
            );
        }
    }

}
