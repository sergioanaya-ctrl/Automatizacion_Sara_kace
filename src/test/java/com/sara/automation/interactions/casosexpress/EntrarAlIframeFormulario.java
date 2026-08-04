package com.sara.automation.interactions.casosexpress;

import com.sara.automation.ui.CasoExpressPage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Interaction;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * INTERACTION: Entrar al iframe del formulario OneScript/Formio.
 *
 * ============================================================
 * PROPÓSITO:
 * Cambiar el contexto del driver del documento principal
 * al iframe que contiene el formulario dinámico.
 *
 * CONTEXTO INICIAL: Documento principal (fuera de cualquier iframe)
 * CONTEXTO FINAL: Dentro del iframe form_onescript_iframe
 * ============================================================
 *
 * PASOS:
 * 1. Cambiar al documento principal (switchTo().defaultContent())
 *    → Asegura que no estamos en ningún iframe previo
 * 2. Esperar a que el iframe esté disponible
 *    → Puede demorar si la página está cargando el formulario
 * 3. Cambiar al iframe
 *    → Ahora podemos acceder a elementos dentro del formulario
 *
 * IMPORTANTE:
 * - Esta es una Interaction, NO una Task
 * - Las Interactions son acciones ATÓMICAS (no componen otras acciones)
 * - Las Tasks ORQUESTAN Interactions para crear flujos más complejos
 *
 * PRECONDICIÓN:
 * - El formulario OneScript debe estar visible en la página
 * - El iframe debe existir en el DOM
 *
 * POSTCONDICIÓN:
 * - El driver está dentro del iframe
 * - Podemos acceder a elementos como inputs, selects, textareas
 */
public class EntrarAlIframeFormulario implements Interaction {

    // Timeout para esperar que el iframe esté disponible
    private static final int TIMEOUT_SEGUNDOS = 20;

    /**
     * Factory method para crear esta Interaction.
     */
    public static Interaction now() {
        return instrumented(EntrarAlIframeFormulario.class);
    }

    @Override
    @Step("Entrar al iframe del formulario OneScript/Formio")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();

        // PASO 1: Cambiar al documento principal
        // ============================================================
        // Razón: Screenplay puede resetear el contexto del iframe entre acciones.
        // Aseguramos que partimos del documento principal.
        System.out.println("[EntrarAlIframeFormulario] PASO 1: Saliendo de cualquier iframe previo...");
        driver.switchTo().defaultContent();
        System.out.println("[EntrarAlIframeFormulario]   ✓ Estamos en el documento principal");

        // PASO 2: Esperar a que el iframe esté disponible
        // ============================================================
        // ExpectedConditions.frameToBeAvailableAndSwitchToIt() hace dos cosas:
        // a) Espera a que el iframe exista en el DOM
        // b) Una vez existe, cambia el contexto al iframe automáticamente
        System.out.println("[EntrarAlIframeFormulario] PASO 2: Esperando iframe con ID 'form_onescript_iframe'...");
        try {
            new WebDriverWait(driver, Duration.ofSeconds(TIMEOUT_SEGUNDOS))
                    .until(ExpectedConditions.presenceOfElementLocated(CasoExpressPage.IFRAME_ONESCRIPT));
                driver.switchTo().frame(driver.findElement(CasoExpressPage.IFRAME_ONESCRIPT));
            System.out.println("[EntrarAlIframeFormulario]   ✓ Iframe encontrado e iframe cambiado correctamente");
        } catch (Exception e) {
            throw new RuntimeException(
                    "[EntrarAlIframeFormulario] No se pudo entrar al iframe después de " + TIMEOUT_SEGUNDOS + " segundos. " +
                    "Posibles causas: formulario no cargó, iframe con ID diferente, error de red.",
                    e
            );
        }

        // PASO 3: Confirmación
        // ============================================================
        // En este punto, el driver está dentro del iframe.
        // Los siguientes selectores buscarán dentro del iframe, no en el documento principal.
        System.out.println("[EntrarAlIframeFormulario] PASO 3: ✓ Contexto cambiado correctamente al iframe");
        System.out.println("[EntrarAlIframeFormulario]   (Ahora los selectores buscan DENTRO del iframe)\n");
    }

}
