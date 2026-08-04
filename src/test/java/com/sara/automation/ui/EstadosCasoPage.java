package com.sara.automation.ui;

import net.serenitybdd.screenplay.targets.Target;
import org.openqa.selenium.By;

/**
 * Page Object para el módulo de Cambios de Estado del Caso.
 *
 * Centralizador de todos los selectores relacionados con transiciones de estado.
 * Soporta cualquier estado: Programado, Aceptado, Concluido, Finalizado, etc.
 *
 * CONTEXTO: DENTRO del iframe OneScript
 */
public class EstadosCasoPage {

    // ============================================================
    // SECCIÓN 1: BOTONES DE ESTADO (GENÉRICOS)
    // ============================================================

    /**
     * Factory: Obtener botón de estado por nombre exacto
     * {0} = nombre del estado (p.ej. "Programado", "Aceptado y en desplazamiento", etc.)
     *
     * Uso:
     *   EstadosCasoPage.BOTON_ESTADO.of("Programado")
     *   EstadosCasoPage.BOTON_ESTADO.of("Aceptado y en desplazamiento")
     */
    public static final Target BOTON_ESTADO = Target.the("Botón estado {0}")
            .locatedBy("//button[contains(text(), '{0}')]");

    /**
     * Factory: Obtener botón de estado con búsqueda parcial
     * Útil si el texto no coincide exactamente
     * {0} = parte del nombre del estado
     */
    public static final Target BOTON_ESTADO_CONTIENE = Target.the("Botón estado contiene {0}")
            .locatedBy("//button[contains(normalize-space(.), '{0}')]");

    // ============================================================
    // SECCIÓN 2: BOTONES DE ESTADO ESPECÍFICOS (FALLBACKS)
    // ============================================================

    /**
     * Estado: Programado
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target BOTON_ESTADO_PROGRAMADO = Target.the("Botón Estado Programado")
            .located(By.xpath("//button[contains(normalize-space(.), 'Programado')]"));

    /**
     * Estado: Aceptado y en Desplazamiento
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target BOTON_ESTADO_ACEPTADO_DESPLAZAMIENTO = Target.the("Botón Estado Aceptado y en Desplazamiento")
            .located(By.xpath("//button[contains(text(), 'Aceptado') and contains(text(), 'desplazamiento')]"));

    /**
     * Fallback para Aceptado: búsqueda simple
     */
    public static final Target BOTON_ESTADO_ACEPTADO = Target.the("Botón Estado Aceptado (Simple)")
            .located(By.xpath("//button[contains(normalize-space(.), 'Aceptado')]"));

    /**
     * Estado: Concluido
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target BOTON_ESTADO_CONCLUIDO = Target.the("Botón Estado Concluido")
            .located(By.xpath("//button[contains(normalize-space(.), 'Concluido')]"));

    /**
     * Estado: Finalizado
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target BOTON_ESTADO_FINALIZADO = Target.the("Botón Estado Finalizado")
            .located(By.xpath("//button[contains(normalize-space(.), 'Finalizado')]"));

    // ============================================================
    // SECCIÓN 3: BOTÓN GUARDAR (DENTRO DEL IFRAME)
    // ============================================================

    /**
     * Botón "Guardar" para persistir cambios de estado
     * CONTEXTO: DENTRO del iframe, al final del formulario
     */
    public static final By BOTON_GUARDAR_FORMULARIO = By.cssSelector("button[name='data[kaceCustomSubmit]']");

    public static final Target BOTON_GUARDAR_FORMULARIO_TARGET = Target.the("Guardar Formulario")
            .located(By.xpath("//button[@name='data[kaceCustomSubmit]' or contains(normalize-space(.), 'Guardar')]"));
}
