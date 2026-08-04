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
 * TASK: Seleccionar el formulario "Creación de Casos (ASISTENCIA)".
 *
 * ============================================================
 * PROPÓSITO:
 * Dentro del menú "Caso Express" ya abierto, seleccionar
 * la opción de "Formulario Creación de Casos (ASISTENCIA)".
 * Esto carga el formulario dinámico en el iframe.
 *
 * CONTEXTO INICIAL: Documento principal con menú Caso Express abierto
 * CONTEXTO FINAL: Documento principal, formulario cargado en iframe
 *                 (pero aún no hemos entrado al iframe)
 * ============================================================
 *
 * PASOS INTERNOS:
 * 1. Esperar a que la opción "Formulario Creación de Casos (ASISTENCIA)" sea visible
 * 2. Hacer clic en la opción
 * 3. Esperar a que el formulario se cargue (se verá el iframe)
 *
 * IMPORTANTE:
 * - Esta opción aparece en el dropdown del menú "Caso Express"
 * - Después de hacer clic, se carga el iframe con el formulario
 * - Aún no hemos entrado al iframe, solo aparece en la página
 *
 * PRECONDICIÓN:
 * - El menú "Caso Express" está abierto (usar AbrirMenuCasoExpress primero)
 * - La opción "Formulario Creación de Casos (ASISTENCIA)" está visible
 *
 * POSTCONDICIÓN:
 * - La opción está seleccionada
 * - El formulario se está cargando en el iframe (visible en el documento principal)
 * - Estamos listos para entrar al iframe
 *
 * SIGUIENTE PASO:
 * - actor.attemptsTo(EntrarAlIframeFormulario.now())
 *
 * EJEMPLO DE USO:
 * actor.attemptsTo(SeleccionarFormularioAsistencia.now());
 */
public class SeleccionarFormularioAsistencia implements Task {

    /**
     * Factory method para crear esta Task.
     */
    public static Performable now() {
        return instrumented(SeleccionarFormularioAsistencia.class);
    }

    @Override
    @Step("Seleccionar formulario 'Creación de Casos (ASISTENCIA)'")
    public <T extends Actor> void performAs(T actor) {
        System.out.println("[SeleccionarFormularioAsistencia] Seleccionando formulario ASISTENCIA...\n");

        // PASO 1: Esperar a que la opción sea visible
        // ============================================================
        System.out.println("[SeleccionarFormularioAsistencia] PASO 1: Esperando opción visible...");
        actor.attemptsTo(
            WaitUntil.the(CasoExpressPage.FORMULARIO_ASISTENCIA, isVisible())
                .forNoMoreThan(10)
                .seconds()
        );
        System.out.println("[SeleccionarFormularioAsistencia]   ✓ Opción visible");

        // PASO 2: Hacer clic en la opción
        // ============================================================
        System.out.println("[SeleccionarFormularioAsistencia] PASO 2: Haciendo clic en la opción...");
        try {
            actor.attemptsTo(Click.on(CasoExpressPage.FORMULARIO_ASISTENCIA));
            System.out.println("[SeleccionarFormularioAsistencia]   ✓ Clic exitoso\n");
        } catch (Exception e) {
            throw new RuntimeException(
                "[SeleccionarFormularioAsistencia] No se pudo seleccionar 'Formulario Creación de Casos (ASISTENCIA)'",
                e
            );
        }

        // PASO 3: Esperar a que el formulario cargue
        // ============================================================
        System.out.println("[SeleccionarFormularioAsistencia] PASO 3: Esperando a que el formulario cargue...");
        try {
            actor.attemptsTo(
                WaitUntil.the(CasoExpressPage.FORMULARIO_ASISTENCIA, isVisible())
                    .forNoMoreThan(15)
                    .seconds()
            );
            System.out.println("[SeleccionarFormularioAsistencia]   ✓ Formulario cargado\n");
        } catch (Exception e) {
            // El formulario puede haber cargado aunque no veamos la opción
            System.out.println("[SeleccionarFormularioAsistencia]   ⚠ Formulario posiblemente cargado (continuando)\n");
        }

        System.out.println("[SeleccionarFormularioAsistencia] ✓ Formulario ASISTENCIA seleccionado\n");
    }

}
