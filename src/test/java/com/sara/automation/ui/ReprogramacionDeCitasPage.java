package com.sara.automation.ui;

import org.openqa.selenium.By;

/**
 * Page Object para la pestaña "Reprogramación de citas".
 * Centraliza los selectores para crear una reprogramación: pestaña, botón "Crear",
 * confirmación SweetAlert2 opcional y campos del formulario del dialog.
 */
public class ReprogramacionDeCitasPage {

    // ===== PESTAÑA =====
    public static final By TAB = By.cssSelector("a[href='#reprogramacionDeCitas']");

    // ===== BOTÓN "Crear" =====
    // NO es el botón nativo del editGrid (oculto vía CSS: [ref="editgrid-reprogramacion_de_citas_asistencia_movilidad-addRow"]
    // { display: none !important; }), sino un botón independiente en el componente
    // "formio-component-btnCrearReprogramacion", ubicado DESPUÉS del editGrid dentro del mismo
    // tab-pane (el tab-pane en sí no tiene id="reprogramacionDeCitas", ese id solo existe como
    // href-anchor del link de la pestaña).
    public static final By BTN_CREAR = By.cssSelector(
            ".formio-component-btnCrearReprogramacion button[ref='button']");
    public static final By BTN_CREAR_FALLBACK = By.xpath(
            "//div[contains(@class, 'formio-component-btnCrearReprogramacion')]//button[contains(., 'Crear')]");

    // ===== CONFIRMACIÓN SWEETALERT2 ("Hay tareas pendientes por gestionar, deseas continuar?") =====
    public static final By SWAL_POPUP = By.cssSelector(".swal2-popup.swal2-show");
    public static final By SWAL_BTN_SI = By.cssSelector(".swal2-popup.swal2-show button.swal2-confirm");

    // ===== DIALOG DE CREACIÓN =====
    public static final By DIALOG_CONTENIDO = By.cssSelector(".formio-dialog-content");
    public static final By BTN_GUARDAR_DIALOG = By.xpath(
            "//div[contains(@class, 'formio-dialog-content')]//button[contains(text(), 'Guardar')]");

    // ===== CAMPOS DEL DIALOG =====
    public static final String SELECTOR_MOTIVO = "#custom-select-e2xtts6";
    public static final String SELECTOR_QUIEN_SOLICITA = "#custom-select-ekxxymd";
    public static final By TEXTAREA_OBSERVACION = By.id("e67ycme-observacion");
    // Input hidden controlado por flatpickr; se fija su valor vía la API _flatpickr.setDate().
    public static final String ID_INPUT_FECHA_HIDDEN = "eqsgdd-fecha_y_hora_nueva_cita";

    private ReprogramacionDeCitasPage() {
        // No instanciar
    }
}
