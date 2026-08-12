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

    // ===== PESTAÑA =====
    public static final By TAB_TAREAS = By.cssSelector("a[href='#tareasDeMonitoreo']");

    // ===== TABLA DE TAREAS (lista principal) =====
    public static final By TABLA_TAREAS = By.cssSelector(".data-table__table tbody");
    public static final By FILAS_TABLA = By.cssSelector(".data-table__table tbody tr");

    // Botón "Crear Tarea" (en la parte superior de la tabla)
    public static final By BTN_CREAR_TAREA = By.xpath(
            "//button[contains(text(), 'Crear Tarea') or contains(text(), 'crear tarea')]");
    public static final By BTN_CREAR_TAREA_FALLBACK = By.cssSelector(".kace-subcases-edit-root button.btn-primary");

    // ===== EDICIÓN: BOTONES EN TABLA =====
    public static final By BTN_EDITAR_PRIMERA = By.cssSelector(".data-table__table tbody tr:first-child button[title='Editar']");
    public static final By BTN_EDITAR_PRIMERA_FALLBACK = By.xpath(
            "//div[contains(@class, 'data-table')]//tbody//tr[1]//button[contains(@title, 'Editar')]");

    public static final By BTN_VER = By.xpath("//button[contains(@title, 'Ver')]");

    // ===== MODAL DE EDICIÓN/CREACIÓN =====
    public static final By MODAL_EDICION = By.cssSelector(".modal, [role='dialog']");
    public static final By MODAL_TITLE = By.id("subcaseModalTitle");

    // ===== DROPDOWN CLASIFICACIÓN (en modal de creación) =====
    public static final By DROPDOWN_CLASIFICACION = By.id("subcase-classification-select");
    public static final By OPCIONES_CLASIFICACION = By.cssSelector("#subcase-classification-select option[value!='']");

    // ===== SELECT DE ESTADO SIGUIENTE (en el modal) =====
    public static final By DROPDOWN_ESTADO = By.id("subcase-state-select");
    public static final By DROPDOWN_ESTADO_FALLBACK = By.cssSelector(
            "select[aria-label*='estado siguiente'], select[aria-label*='estado']");

    public static By opcionEstado(String nombreEstado) {
        return By.xpath("//option[contains(text(), '" + nombreEstado + "')]");
    }

    // ===== PANEL DE TAREAS DE MONITOREO (dentro del modal) =====
    public static final By PANEL_TAREAS_MONITOREO = By.cssSelector(".formio-component-tareasDeMonitoreo");
    public static final By PANEL_HEADER = By.cssSelector(".formio-component-tareasDeMonitoreo .card-header");

    // ===== EDITGRID: BOTÓN CREAR FILA =====
    public static final By BTN_CREAR_FILA_EDITGRID = By.xpath(
            "//button[@ref='editgrid-monitoreo_proveedor_asistencia_movilidad-addRow']");
    public static final By BTN_CREAR_FILA_EDITGRID_FALLBACK = By.xpath(
            "//div[contains(@class, 'formio-component-monitoreo_proveedor_asistencia_movilidad')]//button[contains(text(), 'Crear')]");

    // ===== DIALOG (modal dentro del modal para crear fila) =====
    public static final By DIALOG_CONTENIDO = By.cssSelector(".formio-dialog-content");
    public static final By DIALOG_CLOSE = By.cssSelector(".formio-dialog-close");

    // Campos del dialog para crear fila:
    public static final By DROPDOWN_MONITOREO_CON = By.id("custom-select-ehshd4");
    public static final By DROPDOWN_MOMENTO_SERVICIO = By.id("custom-select-ecxhl4l");
    public static final By DROPDOWN_RESPUESTA_MONITOREO = By.id("custom-select-esi7kdj");
    public static final By DROPDOWN_QUEJA = By.id("custom-select-esfdm2m");
    public static final By TEXTAREA_OBSERVACION_ASESOR = By.cssSelector(
            "textarea[placeholder*='']"); // dentro del dialog
    public static final By TEXTAREA_OBSERVACION_PROVEEDOR = By.xpath(
            "//textarea[@placeholder='']");

    public static final By BTN_GUARDAR_DIALOG = By.xpath(
            "//div[contains(@class, 'formio-dialog-content')]//button[contains(text(), 'Guardar')]");

    // ===== PANEL: HABILITAR FORMULARIO =====
    public static final By PANEL_HABILITAR_FORMULARIO = By.cssSelector(".formio-component-habilitar_tarea_monitoreo_panel");
    public static final By BTN_HABILITAR_FORMULARIO = By.xpath(
            "//button[contains(text(), 'Habilitar Formulario')]");

    // ===== FORMULARIO DE TAREA (después de habilitar) =====
    public static final By DROPDOWN_NOMBRE_TAREA = By.id("custom-select-e2cy7mj");
    public static final By DROPDOWN_USUARIO_ASIGNADO = By.id("custom-select-usuario_asignado_nombre_select");
    public static final By INPUT_DESCRIPCION_TAREA = By.id("eh8fm45-descripcion_tipo_tarea");
    public static final By INPUT_FECHA_VENCIMIENTO = By.xpath(
            "//input[@class='form-control form-control input'][@placeholder='']");

    // ===== EDITGRID DENTRO DEL MODAL: DROPDOWNS PARA CREAR FILA =====
    public static final By DROPDOWN_MONITOREO_CON_EDITGRID = By.id("custom-select-ehshd4");
    public static final By DROPDOWN_MOMENTO_SERVICIO_EDITGRID = By.id("custom-select-ecxhl4l");
    public static final By DROPDOWN_RESPUESTA_MONITOREO_EDITGRID = By.id("custom-select-esi7kdj");
    public static final By DROPDOWN_QUEJA_EDITGRID = By.id("custom-select-esfdm2m");

    // ===== TEXTAREAS DE OBSERVACIÓN =====
    public static final By TEXTAREA_OBSERVACION_ASESOR_EDITGRID = By.xpath(
            "//label[contains(text(), 'Observación Asesor')]/..//textarea");
    public static final By TEXTAREA_OBSERVACION_PROVEEDOR_EDITGRID = By.xpath(
            "//label[contains(text(), 'Observación Proveedor')]/..//textarea");

    // ===== BOTONES PRINCIPALES DEL MODAL =====
    public static final By BTN_GUARDAR_MODAL = By.xpath(
            "//div[@class='modal-footer']//button[contains(text(), 'Guardar')]");
    public static final By BTN_GUARDAR_MODAL_FALLBACK = By.xpath(
            "//button[contains(text(), 'Guardar') and contains(@class, 'btn-primary')]");
    public static final By BTN_CANCELAR_MODAL = By.xpath(
            "//div[@class='modal-footer']//button[contains(text(), 'Cancelar')]");

    // ===== VALIDACIÓN =====
    public static final By TEXTO_TABLA_VACIA = By.xpath(
            "//*[contains(text(), 'No hay') or contains(text(), 'disponibles')]");

    private TareasDeMonitoreoPage() {
        // No instantiar
    }
}
