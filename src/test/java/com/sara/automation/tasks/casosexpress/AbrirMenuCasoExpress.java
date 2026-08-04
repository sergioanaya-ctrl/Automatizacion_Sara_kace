package com.sara.automation.tasks.casosexpress;

import com.sara.automation.ui.CasoExpressPage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.actions.Click;
import net.serenitybdd.screenplay.waits.WaitUntil;
import net.thucydides.core.annotations.Step;

import static net.serenitybdd.screenplay.Tasks.instrumented;
import static net.serenitybdd.screenplay.matchers.WebElementStateMatchers.isVisible;

/**
 * TASK: Abrir el menú "Caso Express".
 *
 * ============================================================
 * PROPÓSITO:
 * Orquestar la apertura del menú "Caso Express" que contiene
 * las opciones de formularios disponibles (ASISTENCIA, RECLAMACIONES, etc.).
 *
 * CONTEXTO INICIAL: Documento principal, en la página de inicio
 * CONTEXTO FINAL: Documento principal con el menú abierto
 * ============================================================
 *
 * PASOS INTERNOS:
 * 1. Esperar a que el botón "Caso Express" esté visible
 * 2. Hacer clic en el botón
 *
 * IMPORTANTE:
 * - Esta es una TASK (no una Interaction)
 * - Las Tasks orquestan Interactions para crear flujos más complejos
 * - Usa métodos Screenplay puro (WaitUntil, Click) que son más robustos
 *
 * PRECONDICIÓN:
 * - El actor está en la página de inicio del sistema
 * - El botón "Caso Express" está visible en el menú principal
 *
 * POSTCONDICIÓN:
 * - El menú "Caso Express" está abierto
 * - Se pueden ver las opciones (Formulario ASISTENCIA, RECLAMACIONES, etc.)
 *
 * SIGUIENTE PASO:
 * - actor.attemptsTo(SeleccionarFormularioAsistencia.now())
 *
 * EJEMPLO DE USO:
 * actor.attemptsTo(AbrirMenuCasoExpress.now());
 */
public class AbrirMenuCasoExpress implements Task {

    /**
     * Factory method para crear esta Task.
     */
    public static Performable now() {
        return instrumented(AbrirMenuCasoExpress.class);
    }

    @Override
    @Step("Abrir menú 'Caso Express'")
    public <T extends Actor> void performAs(T actor) {
        System.out.println("[AbrirMenuCasoExpress] Abriendo menú 'Caso Express'...\n");

        // PASO 1: Esperar a que el botón "Caso Express" sea visible
        // ============================================================
        System.out.println("[AbrirMenuCasoExpress] PASO 1: Esperando botón 'Caso Express' visible...");
        actor.attemptsTo(
            WaitUntil.the(CasoExpressPage.BOTON_CASO_EXPRESS, isVisible())
                .forNoMoreThan(10)
                .seconds()
        );
        System.out.println("[AbrirMenuCasoExpress]   ✓ Botón visible");

        // PASO 2: Hacer clic en el botón para abrir el menú
        // ============================================================
        System.out.println("[AbrirMenuCasoExpress] PASO 2: Haciendo clic en 'Caso Express'...");
        try {
            actor.attemptsTo(Click.on(CasoExpressPage.BOTON_CASO_EXPRESS));
            System.out.println("[AbrirMenuCasoExpress]   ✓ Clic exitoso\n");
        } catch (Exception e1) {
            // Fallback: intentar con el selector alternativo
            System.out.println("[AbrirMenuCasoExpress]   ⚠ Primer selector falló, intentando fallback...");
            try {
                actor.attemptsTo(Click.on(CasoExpressPage.BOTON_CASO_EXPRESS_FALLBACK));
                System.out.println("[AbrirMenuCasoExpress]   ✓ Clic exitoso (fallback)\n");
            } catch (Exception e2) {
                throw new RuntimeException(
                    "[AbrirMenuCasoExpress] No se pudo abrir el menú 'Caso Express'. " +
                    "Ambos selectores fallaron.",
                    e2
                );
            }
        }

        System.out.println("[AbrirMenuCasoExpress] ✓ Menú 'Caso Express' abierto\n");
    }

}
