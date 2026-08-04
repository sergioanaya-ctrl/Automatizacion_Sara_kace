package com.sara.automation.ui;

import net.serenitybdd.screenplay.targets.Target;
import org.openqa.selenium.By;

/**
 * Page Object para el módulo de Gestión de Proveedores.
 *
 * Estructura:
 * 1. TAB - Pestaña de gestión de proveedores
 * 2. DIALOG - Modal para crear/editar proveedor
 * 3. DROPDOWNS - Custom dropdowns dentro del dialog
 * 4. CAMPOS - Campos numéricos y de texto
 * 5. BOTONES - Botones de acción
 */
public class ProveedorPage {

    // ============================================================
    // SECCIÓN 1: TAB DE GESTIÓN DE PROVEEDORES
    // ============================================================

    /**
     * Tab: Gestión de Proveedores
     * CONTEXTO: Dentro del iframe OneScript, en la pestaña principal
     */
    public static final Target TAB_GESTION_PROVEEDORES = Target.the("Tab Gestión de Proveedores")
            .located(By.xpath("//a[contains(normalize-space(.), 'Gestión de Proveedores') or contains(normalize-space(.), 'Proveedor') or contains(@href, 'gestion') and contains(@href, 'proveedor')] | //button[contains(normalize-space(.), 'Gestión de Proveedores') or contains(normalize-space(.), 'Proveedor')]"));

    public static final Target TAB_GESTION_PROVEEDORES_FALLBACK = Target.the("Tab Gestión de Proveedores (Fallback)")
            .located(By.xpath("//a[contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'gestión') or contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'proveedor')]"));

    // ============================================================
    // SECCIÓN 2: BOTÓN CREAR PROVEEDOR
    // ============================================================

    /**
     * Botón "Crear Proveedor" que abre el dialog de creación
     * CONTEXTO: DENTRO del iframe, en la tab de Gestión de Proveedores
     */
    public static final Target BOTON_CREAR_PROVEEDOR = Target.the("Botón Crear Proveedor")
            .located(By.xpath("//button[contains(normalize-space(.), 'Crear') and contains(@ref, 'gestion_proveedor')]"));

    public static final Target BOTON_CREAR_PROVEEDOR_FALLBACK = Target.the("Botón Crear Proveedor (Fallback)")
            .located(By.xpath("//button[contains(normalize-space(.), 'Crear') and contains(@class, 'btn-primary')]"));

    // ============================================================
    // SECCIÓN 3: DIALOG MODAL DE PROVEEDOR
    // ============================================================

    /**
     * Dialog Modal que contiene el formulario de proveedor
     * CONTEXTO: DENTRO del iframe, es un div con class formio-dialog
     */
    public static final Target PROVEEDOR_DIALOG = Target.the("Proveedor dialog")
            .located(By.xpath("//div[contains(@class,'formio-dialog') and descendant::label[normalize-space()='Nombre'] and descendant::label[normalize-space()='Respuesta de proveedor']]"));

    // ============================================================
    // SECCIÓN 4: CUSTOM DROPDOWN CONTROLS DENTRO DEL DIALOG
    // ============================================================

    /**
     * Dropdown Control: Nombre del Proveedor
     * Es un custom-dropdown-control dentro del dialog
     * CONTEXTO: DENTRO del dialog modal
     */
    public static final Target NOMBRE_PROVEEDOR_DROPDOWN_CONTROL = Target.the("Nombre Proveedor Dropdown Control")
            .located(By.xpath("//div[contains(@class,'formio-dialog')]//div[contains(@class,'formio-component-custom-select') and contains(@class,'formio-component-nombre')]//div[contains(@class,'custom-dropdown-control')]"));

    /**
     * Search input dentro del dropdown de Nombre
     * CONTEXTO: DENTRO del dialog, cuando el dropdown está abierto
     */
    public static final Target NOMBRE_PROVEEDOR_DROPDOWN_SEARCH = Target.the("Nombre Proveedor Dropdown Search")
            .located(By.xpath("//div[contains(@class,'formio-dialog')]//div[contains(@class,'formio-component-custom-select') and contains(@class,'formio-component-nombre')]//input[contains(@class,'custom-dropdown-search') or contains(translate(@placeholder,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'buscar')]"));

    /**
     * Dropdown Control: Respuesta de Proveedor (Servicio)
     * CONTEXTO: DENTRO del dialog modal
     */
    public static final Target RESPUESTA_PROVEEDOR_DROPDOWN_CONTROL = Target.the("Respuesta Proveedor Dropdown Control")
            .located(By.xpath("//div[contains(@class,'formio-dialog')]//div[contains(@class,'formio-component-custom-select') and contains(@class,'formio-component-respuesta_de_proveedor')]//div[contains(@class,'custom-dropdown-control')]"));

    /**
     * Search input dentro del dropdown de Respuesta
     * CONTEXTO: DENTRO del dialog, cuando el dropdown está abierto
     */
    public static final Target RESPUESTA_PROVEEDOR_DROPDOWN_SEARCH = Target.the("Respuesta Proveedor Dropdown Search")
            .located(By.xpath("//div[contains(@class,'formio-dialog')]//div[contains(@class,'formio-component-custom-select') and contains(@class,'formio-component-respuesta_de_proveedor')]//input[contains(@class,'custom-dropdown-search') or contains(translate(@placeholder,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'buscar')]"));

    // ============================================================
    // SECCIÓN 5: CAMPOS NUMÉRICOS Y DE TEXTO
    // ============================================================

    /**
     * Campo: Tiempo de Monitoreo en Sitio (minutos)
     * Tipo: input[type=number] o input[type=text]
     * CONTEXTO: DENTRO del dialog
     */
    public static final Target TIEMPO_MONITOREO_SITIO_MINUTOS = Target.the("Tiempo Monitoreo Sitio (Minutos)")
            .located(By.cssSelector("input[name*='tiempo_monitoreo_en_sitio'], input[name*='tiempo_monitoreo_sitio']"));

    /**
     * Campo: Tiempo de Monitoreo en Destino (minutos)
     * Tipo: input[type=number] o input[type=text]
     * CONTEXTO: DENTRO del dialog
     */
    public static final Target TIEMPO_MONITOREO_DESTINO_MINUTOS = Target.the("Tiempo Monitoreo Destino (Minutos)")
            .located(By.cssSelector("input[name*='tiempo_monitoreo_destino_minutos'], input[name*='tiempo_monitoreo_destino']"));

    /**
     * Campo: Celular del Técnico Proveedor
     * Tipo: input[type=tel] o input[type=text]
     * CONTEXTO: DENTRO del dialog
     */
    public static final Target CELULAR_TECNICO_PROVEEDOR = Target.the("Celular Técnico Proveedor")
            .located(By.cssSelector("input[name*='celular_tecnico'], input[name*='celular']"));

    // ============================================================
    // SECCIÓN 6: BOTONES DE ACCIÓN EN EL DIALOG
    // ============================================================

    /**
     * Botón "Guardar" dentro del dialog de proveedor
     * Aparece al final del formulario dentro del dialog
     * CONTEXTO: DENTRO del dialog modal
     */
    public static final Target GUARDAR_PROVEEDOR = Target.the("Guardar Proveedor")
            .located(By.xpath("//div[@role='dialog']//button[contains(@class, 'btn-primary') and contains(normalize-space(text()), 'Guard')]"));

    public static final Target GUARDAR_PROVEEDOR_FALLBACK = Target.the("Guardar Proveedor (Fallback)")
            .located(By.xpath("//div[contains(@class,'formio-dialog')]//button[contains(normalize-space(.), 'Guardar')]"));

    /**
     * Botón "Guardar General" (flotante) que guarda toda la página
     * Aparece fuera del dialog, en el formulario principal
     * CONTEXTO: DENTRO del iframe, pero fuera del dialog
     */
    public static final Target GUARDAR_GENERAL_FLOTANTE = Target.the("Guardar General Flotante")
            .located(By.cssSelector("button[name='data[kaceCustomSubmit]'], button[class*='floating-save']"));

    // ============================================================
    // SECCIÓN 7: HELPERS PARA OPCIONES DE DROPDOWN
    // ============================================================

    /**
     * Helper: Opción de custom dropdown por texto exacto
     * Usado para seleccionar opciones después de abrir dropdown
     * {0} = valor/texto de la opción
     */
    public static final Target OPCION_DROPDOWN = Target.the("Opción dropdown {0}")
            .locatedBy("//div[@role='option' and normalize-space(.)='{0}'] | //li[normalize-space(.)='{0}'] | //span[normalize-space(.)='{0}']");

    /**
     * Helper: Opción de custom dropdown por búsqueda parcial
     * {0} = parte del texto de la opción
     */
    public static final Target OPCION_DROPDOWN_CONTIENE = Target.the("Opción dropdown contiene {0}")
            .locatedBy("//div[@role='option' and contains(normalize-space(.),'{0}')] | //li[contains(normalize-space(.),'{0}')] | //span[contains(normalize-space(.),'{0}')]");
}
