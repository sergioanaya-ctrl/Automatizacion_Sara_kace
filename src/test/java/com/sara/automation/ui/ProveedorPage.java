package com.sara.automation.ui;

import net.serenitybdd.screenplay.targets.Target;
import org.openqa.selenium.By;

/**
 * Page Object para el módulo de Proveedores en Sara.
 *
 * Selectores para la gestión de proveedores dentro del formulario OneScript.
 */
public class ProveedorPage {

    /**
     * Botón "Crear Proveedor" en la tab de gestión.
     * CONTEXTO: DENTRO del iframe OneScript, en la pestaña de Proveedores
     */
    public static final Target BOTON_CREAR_PROVEEDOR = Target.the("Botón Crear Proveedor")
            .locatedBy("//button[contains(normalize-space(.), 'Crear') and ancestor::div[contains(@class,'proveedor')]]");

    /**
     * Campo: Tiempo de Monitoreo en Sitio (en minutos).
     * Tipo: text input o number input
     * CONTEXTO: DENTRO del iframe OneScript
     */
    public static final Target TIEMPO_MONITOREO_SITIO_MINUTOS = Target.the("Tiempo Monitoreo Sitio (minutos)")
            .located(By.cssSelector("input[name='data[tiempo_monitoreo_sitio]'], input[name*='tiempo_sitio']"));

    /**
     * Botón "Guardar" específico para Proveedor.
     * Aparece en la sección de edición de proveedor.
     * CONTEXTO: DENTRO del iframe OneScript
     */
    public static final Target GUARDAR_PROVEEDOR = Target.the("Guardar Proveedor")
            .locatedBy("//div[contains(@class,'proveedor')]//button[contains(normalize-space(.), 'Guardar')]");

    /**
     * Botón "Guardar" flotante general (para guardar cambios generales de la página).
     * CONTEXTO: DENTRO del iframe OneScript
     */
    public static final Target GUARDAR_GENERAL_FLOTANTE = Target.the("Guardar General Flotante")
            .located(By.cssSelector("button[name='data[kaceCustomSubmit]'], button[class*='floating-save']"));
}
