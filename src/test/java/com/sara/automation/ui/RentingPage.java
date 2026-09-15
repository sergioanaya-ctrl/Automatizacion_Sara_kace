package com.sara.automation.ui;

import org.openqa.selenium.By;

/**
 * Selectores del submódulo "Renting" del formulario de Creación/Edición de Casos.
 *
 * IMPORTANTE: esta pestaña SOLO se renderiza cuando el caso se creó con la línea "RENTING"
 * (y uno de sus servicios: GRUA, GRUA MOTOS, GRUA PESADOS PEQUENO/MEDIANO/GRANDE). Si el caso
 * se creó con otra línea (p. ej. AUTOS), la pestaña no existe en el DOM.
 */
public class RentingPage {

    /** Nombre del editGrid, visto en name="data[renting_asistencia_movilidad][0][...]". */
    public static final String EDITGRID = "renting_asistencia_movilidad";

    /** Contenedor del dialog de Form.io: acota TODAS las búsquedas de campos al modal abierto. */
    public static final String SCOPE_DIALOG = ".formio-dialog-content";

    // ---------------------------------------------------------------------------------------
    // Pestaña
    // ---------------------------------------------------------------------------------------
    public static final By TAB = By.cssSelector("a[href='#renting']");

    // ---------------------------------------------------------------------------------------
    // Botón "Crear" del editGrid
    // ---------------------------------------------------------------------------------------
    public static final By BTN_CREAR = By.cssSelector("[ref='editgrid-" + EDITGRID + "-addRow']");
    public static final By BTN_CREAR_FALLBACK = By.xpath(
            "//div[contains(@class,'formio-component-" + EDITGRID + "')]"
                    + "//button[contains(normalize-space(.),'Crear')]");

    // ---------------------------------------------------------------------------------------
    // Dropdowns custom del dialog.
    // Se usan las CLASES de componente Form.io (formio-component-<key>) y no los ids generados
    // (#custom-select-e240owf, #custom-select-ea9dh3, ...) porque esos ids cambian cada vez que
    // el formulario se vuelve a publicar; la clase de componente deriva de la key del campo y
    // se mantiene estable.
    // Los 4 son REQUERIDOS en el formulario.
    // ---------------------------------------------------------------------------------------
    public static final String COMP_RESPONSABLE = "formio-component-responsable";
    public static final String COMP_MOTIVO = "formio-component-motivo";
    public static final String COMP_TIPO_LLAMADA = "formio-component-tipo_de_llamada";
    public static final String COMP_ESTADO_ESCALAMIENTO = "formio-component-estado_del_escalamiento";

    // ---------------------------------------------------------------------------------------
    // Campos NO diligenciables por diseño del formulario:
    //   - "Grupo del escalamiento" (rol_usuario_creador): input disabled, precargado con
    //     "Administrators Group".
    //   - fecha_hora_de_registro / usuario / logica_de_edicion: componentes ocultos.
    // ---------------------------------------------------------------------------------------

    /**
     * "Fecha y hora compromiso" (flatpickr). Llega DESHABILITADA y NO es requerida, así que solo
     * se diligencia si el formulario llegara a habilitarla (p. ej. por una regla condicional
     * asociada al estado del escalamiento). Se apunta al input hidden real, que es el que lleva
     * adjunta la instancia de flatpickr.
     */
    public static final By INPUT_FECHA_COMPROMISO = By.cssSelector(
            SCOPE_DIALOG + " .formio-component-fecha_hora_de_compromiso input.flatpickr-input");

    // ---------------------------------------------------------------------------------------
    // Observación
    // ---------------------------------------------------------------------------------------
    public static final By TEXTAREA_OBSERVACION = By.cssSelector(
            SCOPE_DIALOG + " .formio-component-observacion textarea");
    public static final By TEXTAREA_OBSERVACION_FALLBACK = By.cssSelector(
            SCOPE_DIALOG + " textarea.form-control");

    // ---------------------------------------------------------------------------------------
    // Guardado
    // ---------------------------------------------------------------------------------------
    public static final By BTN_GUARDAR_DIALOG = By.xpath(
            "//div[contains(@class,'formio-dialog-content')]"
                    + "//button[contains(@class,'btn-primary') and normalize-space(.)='Guardar']");
    public static final By BTN_GUARDAR_DIALOG_FALLBACK = By.xpath(
            "//div[contains(@class,'formio-dialog-content')]//button[contains(@class,'btn-primary')]");

    /** Guardado general del formulario (id estable). */
    public static final By BTN_GUARDAR_GENERAL = By.id("kaceCustomSubmit");
    public static final By BTN_GUARDAR_GENERAL_FALLBACK = By.cssSelector("button[name^='data[kaceCustomSubmit']");
}
