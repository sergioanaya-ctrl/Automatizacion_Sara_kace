package com.sara.automation.ui;

import net.serenitybdd.screenplay.targets.Target;
import org.openqa.selenium.By;

/**
 * Consolidated Page Object para Caso Express y Reclamaciones.
 * Fusiona selectores de CasoCreatePage y CasoExpressPage.
 * Single Source of Truth para todos los localizadores.
 */
public class CasoExpressPage {

    // ============================================================
    // SECCIÓN 1: MENU PRINCIPAL (FUERA DEL IFRAME)
    // ============================================================

    public static final Target BOTON_CASO_EXPRESS = Target.the("Boton Caso Express / Express Case")
            .located(By.xpath("//button[contains(normalize-space(.), 'Express Case') or contains(normalize-space(.), 'Caso Express')] | " +
                             "//a[contains(normalize-space(.), 'Express Case') or contains(normalize-space(.), 'Caso Express')]"));

    public static final Target BOTON_CASO_EXPRESS_FALLBACK = Target.the("Boton Express Case / Caso Express (fallback)")
            .located(By.xpath("//button[contains(., 'Express Case') or contains(., 'Caso Express')] | " +
                             "//a[contains(., 'Express Case') or contains(., 'Caso Express')] | " +
                             "//*[contains(@class, 'menu-item') and (contains(., 'Express Case') or contains(., 'Caso Express'))]"));

    public static final Target BOTON_CASO_EXPRESS_FALLBACK2 = Target.the("Boton Express Case por testid")
            .located(By.xpath("//button[contains(@data-testid, 'express') or contains(@data-testid, 'caso') or contains(@id, 'express') or contains(@id, 'caso')] | " +
                             "//*[@role='tab' and (contains(., 'Express') or contains(., 'Caso'))]"));

    public static final Target BOTON_CASO_EXPRESS_FALLBACK3 = Target.the("Boton por contenido flexible")
            .located(By.xpath("//div[@role='menuitem' or @class='menu-item']//span[contains(., 'Express') or contains(., 'Caso')]/ancestor::*[self::button or self::a or self::div[@role='menuitem' or @role='tab']]"));

    // Formulario de Casos - ASISTENCIA (selector CORRECTO del original)
    public static final Target FORMULARIO_ASISTENCIA = Target.the("Formulario Creación de Casos (ASISTENCIA)")
            .located(By.xpath("//div[.//span[normalize-space(text())='Formulario Creación de Casos (ASISTENCIA)'] and @role='menuitem']"));

    // Formulario de Casos - RECLAMACIONES
    public static final Target FORMULARIO_CREACION_RECLAMACIONES = Target.the("Formulario Creación de Casos (RECLAMACIONES)")
            .located(By.xpath("//div[@role='menuitem'][.//span[contains(normalize-space(.),'RECLAMACIONES')]]"));

    // ============================================================
    // SECCIÓN 2: IFRAME
    // ============================================================

    public static final By IFRAME_ONESCRIPT = By.id("form_onescript_iframe");

    // ============================================================
    // SECCIÓN 3: BOTONES Y CONTROLES DENTRO DEL IFRAME
    // ============================================================

    public static final Target HABILITAR_FORMULARIO = Target.the("Boton Habilitar Formulario")
            .located(By.cssSelector("button[name*='habilitar_edicion_del_caso']"));

    public static final Target HABILITAR_FORMULARIO_FALLBACK = Target.the("Boton Habilitar Formulario (ref button)")
            .located(By.xpath("//div[@id='eoq0dnq-habilitar_edicion_del_caso_panel']//button[@ref='button']"));

    public static final Target HABILITAR_FORMULARIO_FALLBACK2 = Target.the("Boton Habilitar Formulario (flexible)")
            .located(By.xpath("//div[contains(@class, 'card-body') and .//button[contains(normalize-space(.), 'Habilitar')]]//button[contains(@class, 'btn-primary')]"));

    public static final Target HABILITAR_FORMULARIO_FALLBACK3 = Target.the("Boton Habilitar Formulario (genérico)")
            .located(By.xpath("//button[contains(normalize-space(.), 'Habilitar Formulario')]"));

    // ============================================================
    // SECCIÓN 4: CAMPOS BÁSICOS DEL FORMULARIO (DENTRO IFRAME)
    // ============================================================

    public static final By BOTON_HABILITAR_FORMULARIO = By.cssSelector("button[name*='habilitar_edicion_del_caso']");
    public static final By BOTON_HABILITAR_FORMULARIO_XPATH = By.xpath("//button[contains(normalize-space(.), 'Habilitar Formulario')]");
    public static final By BOTON_GUARDAR_FORMULARIO = By.cssSelector("button[name='data[kaceCustomSubmit]']");

    public static final By CAMPO_NUMERO_EXPEDIENTE = By.cssSelector("input[name='data[numero_expediente]']");
    public static final By CAMPO_NOMBRE = By.cssSelector("input[name='data[nombre_solicitante_c]']");
    public static final By CAMPO_CEDULA = By.cssSelector("input[name='data[cedula_solicitante_c]']");
    public static final By CAMPO_EMAIL = By.cssSelector("input[name='data[email_solicitante_c]']");
    public static final By CAMPO_TELEFONO = By.cssSelector("input[name='data[telefono_solicitante_c]']");
    public static final By CAMPO_DESCRIPCION = By.cssSelector("textarea[name='data[descripcion_caso_c]']");
    public static final By CAMPO_TELEFONO_2 = By.cssSelector("input[name='data[telefono_2]']");
    public static final By CAMPO_PLACA = By.cssSelector("input[name='data[placa]']");
    public static final By CAMPO_MARCA_VEHICULO = By.cssSelector("input[name='data[marca_vehiculo]']");
    public static final By CAMPO_DIRECCION_SERVICIO = By.cssSelector("input[name='data[direccion_servicio]']");
    public static final By CAMPO_DIRECCION_DESTINO = By.cssSelector("input[name='data[direccion_del_destino]']");
    public static final By CAMPO_DETALLE_DIRECCION_SERVICIO = By.cssSelector("input[name='data[detalle_direccion_servicio]']");
    public static final By CAMPO_DETALLE_DIRECCION_DESTINO = By.cssSelector("input[name='data[detalle_direccion_destino]']");
    public static final By CAMPO_UBICACION_SERVICIO = By.cssSelector("input[name='data[ubicacion_servicio]']");
    public static final By CAMPO_OBSERVACION_FINAL = By.xpath(
            "//button[contains(@class,'mic-button')]/ancestor::div[contains(@class,'form-group')][1]//textarea[@maxlength='1024' and @rows='6'] | " +
            "//textarea[contains(@class,'form-control') and @maxlength='1024' and @rows='6']");

    // ============================================================
    // SECCIÓN 5: COMBOS (LISTAS DESPLEGABLES)
    // ============================================================

    public static final By COMBO_DEPARTAMENTO = By.cssSelector("select[name='data[departamento]']");
    public static final By COMBO_MUNICIPIO = By.cssSelector("select[name='data[municipio]']");
    public static final By COMBO_LINEA = By.cssSelector("select[name='data[linea_servicio]']");
    public static final By COMBO_SERVICIO = By.cssSelector("select[name='data[servicio]']");
    public static final By COMBO_GESTOR = By.cssSelector("select[name='data[gestor_asignado]']");
    public static final By COMBO_SERVICIOS_ESPECIALES = By.cssSelector("select[name='data[servicios_especiales]'], input[name='data[servicios_especiales]'], div[data-name='servicios_especiales']");

    // ============================================================
    // SECCIÓN 6: CUSTOM DROPDOWN CONTROLS
    // ============================================================

    public static final Target DEPARTAMENTO_COMBO_CUSTOM = Target.the("Departamento Solicita (Custom)")
            .located(By.xpath("//div[contains(@class,'formio-component-departamento_solicita')]//div[contains(@class,'custom-dropdown-control')]"));

    public static final Target MUNICIPIO_COMBO_CUSTOM = Target.the("Municipio Solicita (Custom)")
            .located(By.xpath("//div[contains(@class,'formio-component-municipio_solicita')]//div[contains(@class,'custom-dropdown-control')]"));

    public static final Target MUNICIPIO_COMBO_SELECT = Target.the("Municipio Solicita (Select)")
            .located(By.cssSelector("select[name='data[municipio_solicita]'], input[name='data[municipio_solicita]']"));

    public static final Target SECCION_ASIGNACION = Target.the("Sección Asignación")
            .located(By.xpath("//div[contains(@class,'panel') or contains(@class,'card')][.//*[normalize-space(.)='Asignación'] or .//h3[normalize-space(.)='Asignación']]"));

    public static final Target GESTOR_COMBO_CUSTOM = Target.the("Gestor de coordinación (Custom)")
            .located(By.xpath("//div[.//*[normalize-space(.)='Asignación']]//label[contains(normalize-space(),'Gestor de coordinación')]/following::*[(self::button or self::input or self::div[contains(@class,'select')]) and not(self::input[@type='hidden'])][1]"));

    public static final Target LINEA_COMBO_CUSTOM = Target.the("Línea (Custom)")
            .located(By.xpath("//div[.//*[normalize-space(.)='Asignación']]//label[normalize-space()='Línea *' or normalize-space()='Línea']/following::*[(self::button or self::input or self::div[contains(@class,'select')]) and not(self::input[@type='hidden'])][1]"));

    public static final Target SERVICIO_COMBO_CUSTOM = Target.the("Servicio (Custom)")
            .located(By.xpath("//div[.//*[normalize-space(.)='Asignación']]//label[normalize-space()='Servicio *' or normalize-space()='Servicio']/following::*[(self::button or self::input or self::div[contains(@class,'select')]) and not(self::input[@type='hidden'])][1]"));

    // ============================================================
    // SECCIÓN 7: CUSTOM DROPDOWN HELPERS
    // ============================================================

    public static final String XPATH_INPUT_TEXT = "//input[@type='text' and contains(@name, '%s')]";
    public static final String XPATH_TEXTAREA = "//textarea[contains(@name, '%s')]";
    public static final String XPATH_SELECT = "//select[contains(@name, '%s')]";
    public static final String XPATH_BOTON_POR_TEXTO = "//button[contains(normalize-space(.), '%s')]";

    public static final Target CUSTOM_DROPDOWN_SEARCH = Target.the("Custom dropdown search input")
            .located(By.cssSelector("input.custom-dropdown-search, input[placeholder*='buscar']"));

    public static final Target CUSTOM_DROPDOWN_ITEM = Target.the("Custom dropdown list item {0}")
            .locatedBy("//div[@class='custom-dropdown-item' and contains(normalize-space(), '{0}')] | //div[@role='option' and contains(normalize-space(), '{0}')]");

    public static final Target OPCION_LISTA = Target.the("Opcion lista {0}")
            .locatedBy("//div[@role='option' and normalize-space(.)='{0}'] | //li[normalize-space(.)='{0}'] | //span[normalize-space(.)='{0}']");

    public static final Target OPCION_LISTA_CONTIENE = Target.the("Opcion lista contiene {0}")
            .locatedBy("//div[@role='option' and contains(normalize-space(.),'{0}')] | //li[contains(normalize-space(.),'{0}')] | //span[contains(normalize-space(.),'{0}')]");

    // ============================================================
    // SECCIÓN 8: TARGET WRAPPERS PARA SCROLL/WAIT
    // ============================================================

    public static final Target NUMERO_EXPEDIENTE = Target.the("Número expediente")
            .located(By.cssSelector("input[name='data[numero_expediente]']"));

    public static final Target DIRECCION_SERVICIO = Target.the("Dirección servicio")
            .located(By.cssSelector("input[name='data[direccion_servicio]']"));

    public static final Target DIRECCION_DESTINO = Target.the("Dirección del destino")
            .located(By.cssSelector("input[name='data[direccion_del_destino]']"));

    public static final Target DETALLE_DIRECCION_SERVICIO = Target.the("Detalle dirección servicio")
            .located(By.cssSelector("input[name='data[detalle_direccion_servicio]']"));

    public static final Target DETALLE_DIRECCION_DESTINO = Target.the("Detalle dirección destino")
            .located(By.cssSelector("input[name='data[detalle_direccion_destino]']"));

    public static final Target UBICACION_SERVICIO = Target.the("Ubicación servicio")
            .located(By.cssSelector("input[name='data[ubicacion_servicio]']"));

    public static final Target OBSERVACION_FINAL = Target.the("Observación final del caso")
            .located(By.xpath(
                "//button[contains(@class,'mic-button')]/ancestor::div[contains(@class,'form-group')][1]//textarea[@maxlength='1024' and @rows='6'] | " +
                "//textarea[contains(@class,'form-control') and @maxlength='1024' and @rows='6']"));

    public static final Target GUARDAR_FORMULARIO = Target.the("Guardar Formulario")
            .located(By.xpath("//button[@name='data[kaceCustomSubmit]' or contains(normalize-space(.), 'Guardar')]"));

    public static final Target GUARDAR_FORMULARIO_FALLBACK = Target.the("Guardar Formulario (Fallback)")
            .located(By.xpath("//button[contains(@class, 'btn-primary') and contains(normalize-space(.), 'Guardar')]"));

    public static final Target SERVICIOS_ESPECIALES_COMBO = Target.the("Servicios Especiales")
            .located(By.cssSelector("select[name='data[servicios_especiales]'], input[name='data[servicios_especiales]'], div[data-name='servicios_especiales']"));
}
