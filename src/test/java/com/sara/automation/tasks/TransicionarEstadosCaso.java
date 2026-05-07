package com.sara.automation.tasks;

import com.sara.automation.interactions.ClickEstadoProgramado;
import com.sara.automation.interactions.ClickEstadoAceptadoDesplazamiento;
import com.sara.automation.interactions.ClickEstadoConcluido;
import com.sara.automation.interactions.ClickEstadoFinalizado;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.thucydides.core.annotations.Step;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Task para transicionar el caso a través de todos los estados:
 * Programado -> Aceptado y Desplazamiento -> Concluido -> Finalizado
 * 
 * Cada transición:
 * 1. Clickea el estado con JavaScript dentro del iframe
 * 2. Guarda automáticamente
 * 3. Espera 15 segundos antes del siguiente estado
 */
public class TransicionarEstadosCaso implements Task {

    public static Performable completarSecuencia() {
        return instrumented(TransicionarEstadosCaso.class);
    }

    @Override
    @Step("Transicionar caso a través de estados: Programado -> Aceptado/Desplazamiento -> Concluido -> Finalizado")
    public <T extends Actor> void performAs(T actor) {
        // 1. PROGRAMADO
        System.out.println("  [TransicionarEstadosCaso] === PASO 1: Transición a PROGRAMADO ===");
        actor.attemptsTo(ClickEstadoProgramado.clickEstadoProgramado());
        System.out.println("  [TransicionarEstadosCaso] ✓ Estado 'Programado' completado");
        esperarRecargaPagina();
        
        // 2. ACEPTADO Y DESPLAZAMIENTO
        System.out.println("  [TransicionarEstadosCaso] === PASO 2: Transición a ACEPTADO Y DESPLAZAMIENTO ===");
        actor.attemptsTo(ClickEstadoAceptadoDesplazamiento.clickEstadoAceptadoDesplazamiento());
        System.out.println("  [TransicionarEstadosCaso] ✓ Estado 'Aceptado y Desplazamiento' completado");
        esperarRecargaPagina();
        
        // 3. CONCLUIDO
        System.out.println("  [TransicionarEstadosCaso] === PASO 3: Transición a CONCLUIDO ===");
        actor.attemptsTo(ClickEstadoConcluido.clickEstadoConcluido());
        System.out.println("  [TransicionarEstadosCaso] ✓ Estado 'Concluido' completado");
        esperarRecargaPagina();
        
        // 4. FINALIZADO
        System.out.println("  [TransicionarEstadosCaso] === PASO 4: Transición a FINALIZADO ===");
        actor.attemptsTo(ClickEstadoFinalizado.clickEstadoFinalizado());
        System.out.println("  [TransicionarEstadosCaso] ✓ Estado 'Finalizado' completado");
        
        System.out.println("  [TransicionarEstadosCaso] ===== ✓✓✓ TODAS LAS TRANSICIONES COMPLETADAS =====");
    }
    
    /**
     * Espera 15 segundos para que la página se recargue completamente
     * entre cada transición de estado
     */
    private void esperarRecargaPagina() {
        System.out.println("  [TransicionarEstadosCaso] Esperando 15 segundos para recarga de página...");
        try {
            Thread.sleep(15000); // 15 segundos
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        System.out.println("  [TransicionarEstadosCaso] ✓ Página recargada, listo para siguiente estado");
    }
}
