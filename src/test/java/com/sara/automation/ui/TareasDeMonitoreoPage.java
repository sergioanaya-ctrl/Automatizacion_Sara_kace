package com.sara.automation.ui;

import org.openqa.selenium.By;

/**
 * Page Object para la pestaña "Tareas de monitoreo".
 * Centraliza todos los selectores usados para validar, editar y crear tareas.
 *
 * Elementos principales:
 * - TAB_TAREAS: botón para abrir la pestaña
 * - TABLA_TAREAS: tabla que lista todas las tareas
 * - BTN_EDITAR_PRIMERA: botón Editar de la primera tarea
 * - DROPDOWN_ESTADO: campo de estado en el modal de edición
 * - BTN_GUARDAR_MODAL: botón Guardar del modal
 */
public class TareasDeMonitoreoPage {

    // Pestaña
    public static final By TAB_TAREAS = By.cssSelector("a[href='#tareasDeMonitoreo']");

    // Tabla de tareas (lista)
    public static final By TABLA_TAREAS = By.cssSelector(".data-table__table tbody");
    public static final By FILAS_TABLA = By.cssSelector(".data-table__table tbody tr");

    // Botón Editar de la primera fila
    public static final By BTN_EDITAR_PRIMERA = By.cssSelector(".data-table__table tbody tr:first-child button[title='Editar']");
    public static final By BTN_EDITAR_PRIMERA_FALLBACK = By.xpath(
            "//div[contains(@class, 'data-table')]//tbody//tr[1]//button[contains(@title, 'Editar')]");

    // Modal de edición
    public static final By MODAL_EDICION = By.cssSelector(".modal, [role='dialog']");

    // Dropdown de estado en el modal
    // Intenta múltiples variantes: select con aria-label, select simple, input
    public static final By DROPDOWN_ESTADO = By.cssSelector(
            "select[aria-label*='estado siguiente'], select[aria-label*='estado'], select.form-control");
    public static final By DROPDOWN_ESTADO_FALLBACK = By.xpath(
            "//select[contains(@aria-label, 'estado') or contains(@name, 'estado')]");

    // Opciones del dropdown de estado
    public static By opcionEstado(String nombreEstado) {
        return By.xpath("//option[contains(text(), '" + nombreEstado + "')]");
    }

    // Botón Guardar en el modal
    public static final By BTN_GUARDAR_MODAL = By.xpath(
            "//button[contains(text(), 'Guardar') and contains(@class, 'btn-primary')]");
    public static final By BTN_GUARDAR_MODAL_FALLBACK = By.xpath(
            "//div[contains(@class, 'modal') or @role='dialog']//button[contains(@class, 'btn-primary')]");

    // Validación: tabla vacía o con mensaje de "no hay datos"
    public static final By TEXTO_TABLA_VACIA = By.xpath(
            "//*[contains(text(), 'No hay') or contains(text(), 'disponibles')]");

    private TareasDeMonitoreoPage() {
        // No instantiar
    }
}
