package com.sara.automation.ui;

import net.serenitybdd.screenplay.targets.Target;
import org.openqa.selenium.By;

/**
 * Page Object para la creación de Casos Express en Sara.
 *
 * Estructura:
 * 1. MENU - Elementos del menú principal (fuera del iframe)
 * 2. IFRAME - Elemento del iframe donde vive el formulario
 * 3. FORMULARIO - Elementos dentro del iframe
 * 4. HELPERS - XPaths genéricos para elementos dinámicos
 */
public class CasoExpressPage {

    // ============================================================
    // SECCIÓN 1: MENU (FUERA DEL IFRAME)
    // Estos elementos están en el documento principal,
    // antes de entrar al iframe form_onescript_iframe
    // ============================================================

    /**
     * Botón "Caso Express" en el menú principal.
     * Abre el dropdown con opciones de formularios.
     * CONTEXTO: Fuera del iframe - documento principal
     */
    public static final Target BOTON_CASO_EXPRESS = Target.the("Botón Caso Express")
            .locatedBy("//button[contains(normalize-space(.), 'Caso Express')]");

    /**
     * Fallback si el selector anterior falla.
     */
    public static final Target BOTON_CASO_EXPRESS_FALLBACK = Target.the("Botón Caso Express (Fallback)")
            .located(By.xpath("//span[contains(text(), 'Caso Express')]//ancestor::button"));

    /**
     * Opción "Formulario Creación de Casos (ASISTENCIA)" en el dropdown.
     * Se selecciona después de abrir el menú Caso Express.
     * CONTEXTO: Fuera del iframe - dentro del dropdown del menú
     * Nota: Es un div con role="menuitem", no un button
     */
    public static final Target FORMULARIO_ASISTENCIA = Target.the("Formulario Creación de Casos (ASISTENCIA)")
            .locatedBy("//div[@role='menuitem']//span[contains(normalize-space(.), 'Formulario Creación de Casos (ASISTENCIA)')]/ancestor::div[@role='menuitem']");

    /**
     * Opción "Formulario Creación de Casos (RECLAMACIONES)" en el dropdown.
     * Se selecciona después de abrir el menú Caso Express.
     * CONTEXTO: Fuera del iframe - dentro del dropdown del menú
     * Nota: Es un div con role="menuitem", no un button
     */
    public static final Target FORMULARIO_CREACION_RECLAMACIONES = Target.the("Formulario Creación de Casos (RECLAMACIONES)")
            .locatedBy("//div[@role='menuitem']//span[contains(normalize-space(.), 'Formulario Creación de Casos (RECLAMACIONES)')]/ancestor::div[@role='menuitem']");

    // ============================================================
    // SECCIÓN 2: IFRAME
    // El contenedor que encapsula el formulario dinámico
    // CONTEXTO: Este elemento está en el documento principal
    // pero una vez dentro de él, no podemos acceder a elementos del documento principal
    // ============================================================

    /**
     * Iframe que contiene el formulario dinámico de Formio/OneScript.
     * ID: form_onescript_iframe
     *
     * IMPORTANTE:
     * - Para acceder a elementos dentro de este iframe,
     *   PRIMERO debes hacer: driver.switchTo().frameToBeAvailableAndSwitchToIt(By.id("form_onescript_iframe"))
     * - Para salir del iframe: driver.switchTo().defaultContent()
     * - Los Target de Screenplay NO funcionan bien con iframes, por eso usamos WebDriver directo
     */
    public static final By IFRAME_ONESCRIPT = By.id("form_onescript_iframe");

    // ============================================================
    // SECCIÓN 3: FORMULARIO (DENTRO DEL IFRAME)
    // Estos elementos están DENTRO del iframe form_onescript_iframe
    // Solo son accesibles después de switchTo().frame()
    // ============================================================

    /**
     * Botón "Habilitar Formulario" que permite la edición del formulario.
     * Debe hacerse clic DENTRO del iframe.
     * Aparece cuando el formulario está cargado pero en modo lectura.
     *
     * CONTEXTO: DENTRO del iframe
     * PRECONDICIÓN: driver.switchTo().frameToBeAvailableAndSwitchToIt(IFRAME_ONESCRIPT)
     */
    public static final By BOTON_HABILITAR_FORMULARIO = By.cssSelector("button[name*='habilitar_edicion_del_caso']");

    /**
     * Fallback: buscar por texto visible en caso que el selector CSS falle.
     */
    public static final By BOTON_HABILITAR_FORMULARIO_XPATH = By.xpath(
            "//button[contains(normalize-space(.), 'Habilitar Formulario')]"
    );

    /**
     * Botón "Guardar" general del formulario (después de llenar todos los campos).
     * Está al final del formulario dentro del iframe.
     *
     * CONTEXTO: DENTRO del iframe
     * PRECONDICIÓN: driver.switchTo().frameToBeAvailableAndSwitchToIt(IFRAME_ONESCRIPT)
     */
    public static final By BOTON_GUARDAR_FORMULARIO = By.cssSelector("button[name='data[kaceCustomSubmit]']");

    /**
     * Botón "Guardar" - fallback con Target para casos donde el By anterior no funciona.
     * Usado con Screenplay para operaciones de Wait/Click.
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target GUARDAR_FORMULARIO_FALLBACK = Target.the("Guardar Formulario (Fallback)")
            .locatedBy("//button[contains(normalize-space(.), 'Guardar') and contains(@class, 'btn-primary')]");

    // ============================================================
    // SECCIÓN 3A: CAMPOS BÁSICOS (DENTRO DEL IFRAME)
    // Información personal del cliente
    // ============================================================

    /**
     * Campo: Nombre Completo del solicitante.
     * Tipo: text input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_NOMBRE = By.cssSelector("input[name='data[nombre_solicitante_c]']");

    /**
     * Campo: Cédula o documento de identidad.
     * Tipo: text input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_CEDULA = By.cssSelector("input[name='data[cedula_solicitante_c]']");

    /**
     * Campo: Email de contacto.
     * Tipo: email input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_EMAIL = By.cssSelector("input[name='data[email_solicitante_c]']");

    /**
     * Campo: Teléfono de contacto.
     * Tipo: tel input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_TELEFONO = By.cssSelector("input[name='data[telefono_solicitante_c]']");

    /**
     * Campo: Descripción/Problema del caso.
     * Tipo: textarea
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_DESCRIPCION = By.cssSelector("textarea[name='data[descripcion_caso_c]']");

    // ============================================================
    // SECCIÓN 3B: COMBOS (SELECT) - DENTRO DEL IFRAME
    // Selecciones de listas desplegables
    // ============================================================

    /**
     * Combo: Departamento.
     * Tipo: Select formio
     * CONTEXTO: DENTRO del iframe
     * NOTA: Formio usa div.form-group con selectores específicos
     */
    public static final By COMBO_DEPARTAMENTO = By.cssSelector("select[name='data[departamento]']");

    /**
     * Combo: Municipio (depende del departamento seleccionado).
     * Tipo: Select formio
     * CONTEXTO: DENTRO del iframe
     */
    public static final By COMBO_MUNICIPIO = By.cssSelector("select[name='data[municipio]']");

    /**
     * Combo: Línea de Servicio.
     * Tipo: Select formio
     * CONTEXTO: DENTRO del iframe
     */
    public static final By COMBO_LINEA = By.cssSelector("select[name='data[linea_servicio]']");

    /**
     * Combo: Servicio específico (depende de la línea).
     * Tipo: Select formio
     * CONTEXTO: DENTRO del iframe
     */
    public static final By COMBO_SERVICIO = By.cssSelector("select[name='data[servicio]']");

    /**
     * Combo: Gestor asignado al caso.
     * Tipo: Select formio
     * CONTEXTO: DENTRO del iframe
     */
    public static final By COMBO_GESTOR = By.cssSelector("select[name='data[gestor_asignado]']");

    // ============================================================
    // SECCIÓN 4: HELPERS Y SELECTORES GENÉRICOS
    // XPaths reutilizables para buscar elementos dinámicos
    // ============================================================

    /**
     * Helper: Buscar cualquier input text dentro del iframe.
     * Usado cuando no conocemos el nombre exacto del campo.
     * {0} = nombre o parte del nombre del campo
     * Ejemplo: String.format(XPATH_INPUT_TEXT, "cedula")
     */
    public static final String XPATH_INPUT_TEXT = "//input[@type='text' and contains(@name, '%s')]";

    /**
     * Helper: Buscar cualquier textarea dentro del iframe.
     * {0} = nombre o parte del nombre del campo
     */
    public static final String XPATH_TEXTAREA = "//textarea[contains(@name, '%s')]";

    /**
     * Helper: Buscar cualquier select (combo) dentro del iframe.
     * {0} = nombre o parte del nombre del campo
     */
    public static final String XPATH_SELECT = "//select[contains(@name, '%s')]";

    /**
     * Helper: Buscar cualquier botón por texto visible dentro del iframe.
     * {0} = texto visible en el botón
     * Ejemplo: String.format(XPATH_BOTON_POR_TEXTO, "Siguiente")
     */
    public static final String XPATH_BOTON_POR_TEXTO = "//button[contains(normalize-space(.), '%s')]";

    // ============================================================
    // SECCIÓN 5: CAMPOS ADICIONALES DE DILIGENCIAMIENTO
    // Campos vehiculares, direcciones, ubicaciones
    // CONTEXTO: DENTRO del iframe
    // ============================================================

    /**
     * Campo: Número de expediente.
     * Tipo: text input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_NUMERO_EXPEDIENTE = By.cssSelector("input[name='data[numero_expediente]']");

    /**
     * Campo: Teléfono 2 de contacto.
     * Tipo: tel input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_TELEFONO_2 = By.cssSelector("input[name='data[telefono_2]']");

    /**
     * Campo: Placa del vehículo.
     * Tipo: text input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_PLACA = By.cssSelector("input[name='data[placa]']");

    /**
     * Campo: Marca del vehículo.
     * Tipo: text input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_MARCA_VEHICULO = By.cssSelector("input[name='data[marca_vehiculo]']");

    /**
     * Campo: Dirección de servicio.
     * Tipo: text input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_DIRECCION_SERVICIO = By.cssSelector("input[name='data[direccion_servicio]']");

    /**
     * Campo: Dirección del destino.
     * Tipo: text input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_DIRECCION_DESTINO = By.cssSelector("input[name='data[direccion_del_destino]']");

    /**
     * Campo: Detalle dirección servicio.
     * Tipo: text input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_DETALLE_DIRECCION_SERVICIO = By.cssSelector("input[name='data[detalle_direccion_servicio]']");

    /**
     * Campo: Detalle dirección destino.
     * Tipo: text input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_DETALLE_DIRECCION_DESTINO = By.cssSelector("input[name='data[detalle_direccion_destino]']");

    /**
     * Campo: Ubicación del servicio.
     * Tipo: text input
     * CONTEXTO: DENTRO del iframe
     */
    public static final By CAMPO_UBICACION_SERVICIO = By.cssSelector("input[name='data[ubicacion_servicio]']");

    /**
     * Campo: Observación final del caso.
     * Tipo: textarea
     * CONTEXTO: DENTRO del iframe
     * Ubicado al final del formulario antes de guardar
     */
    public static final By CAMPO_OBSERVACION_FINAL = By.xpath(
            "//button[contains(@class,'mic-button')]/ancestor::div[contains(@class,'form-group')][1]//textarea[@maxlength='1024' and @rows='6'] | " +
            "//textarea[contains(@class,'form-control') and @maxlength='1024' and @rows='6']"
    );

    // ============================================================
    // SECCIÓN 6: SERVICIOS ESPECIALES
    // CONTEXTO: DENTRO del iframe
    // ============================================================

    /**
     * Combo: Servicios especiales (NO/YES).
     * Tipo: Select formio
     * CONTEXTO: DENTRO del iframe
     */
    public static final By COMBO_SERVICIOS_ESPECIALES = By.cssSelector("select[name='data[servicios_especiales]'], input[name='data[servicios_especiales]'], div[data-name='servicios_especiales']");

    /**
     * Target wrapper para Servicios especiales.
     * Usado por: Scroll.to(), WaitUntil.the(), Click.on()
     */
    public static final Target SERVICIOS_ESPECIALES_COMBO = Target.the("Servicios Especiales")
            .located(By.cssSelector("select[name='data[servicios_especiales]'], input[name='data[servicios_especiales]'], div[data-name='servicios_especiales']"));

    // ============================================================
    // SECCIÓN 7: CUSTOM DROPDOWN SELECTORS (PARA FORMIO DIALOGS)
    // Selectores complejos para dropdowns customizados
    // CONTEXTO: DENTRO del iframe
    // ============================================================

    /**
     * Combo: Departamento - versión custom dropdown (Formio).
     * Tipo: div con custom-dropdown-control
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target DEPARTAMENTO_COMBO_CUSTOM = Target.the("Departamento Solicita (Custom)")
            .located(By.xpath("//div[contains(@class,'formio-component-departamento_solicita')]//div[contains(@class,'custom-dropdown-control')]"));

    /**
     * Combo: Municipio - versión custom dropdown (Formio).
     * Tipo: div con custom-dropdown-control
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target MUNICIPIO_COMBO_CUSTOM = Target.the("Municipio Solicita (Custom)")
            .located(By.xpath("//div[contains(@class,'formio-component-municipio_solicita')]//div[contains(@class,'custom-dropdown-control')]"));

    /**
     * Combo: Municipio - versión select standard.
     * Tipo: select input
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target MUNICIPIO_COMBO_SELECT = Target.the("Municipio Solicita (Select)")
            .located(By.cssSelector("select[name='data[municipio_solicita]'], input[name='data[municipio_solicita]']"));

    /**
     * Sección: Asignación.
     * Punto de anclaje para encontrar combos dependientes en la sección de asignación.
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target SECCION_ASIGNACION = Target.the("Sección Asignación")
            .located(By.xpath("//div[contains(@class,'panel') or contains(@class,'card')][.//*[normalize-space(.)='Asignación'] or .//h3[normalize-space(.)='Asignación']]"));

    /**
     * Combo: Gestor de coordinación - versión custom.
     * Tipo: div/button con custom-dropdown-control
     * CONTEXTO: DENTRO del iframe, dentro de la sección de Asignación
     */
    public static final Target GESTOR_COMBO_CUSTOM = Target.the("Gestor de coordinación (Custom)")
            .located(By.xpath("//div[.//*[normalize-space(.)='Asignación']]//label[contains(normalize-space(),'Gestor de coordinación')]/following::*[(self::button or self::input or self::div[contains(@class,'select')]) and not(self::input[@type='hidden'])][1]"));

    /**
     * Combo: Línea - versión custom.
     * Tipo: div/button con custom-dropdown-control
     * CONTEXTO: DENTRO del iframe, dentro de la sección de Asignación
     */
    public static final Target LINEA_COMBO_CUSTOM = Target.the("Línea (Custom)")
            .located(By.xpath("//div[.//*[normalize-space(.)='Asignación']]//label[normalize-space()='Línea *' or normalize-space()='Línea']/following::*[(self::button or self::input or self::div[contains(@class,'select')]) and not(self::input[@type='hidden'])][1]"));

    /**
     * Combo: Servicio - versión custom.
     * Tipo: div/button con custom-dropdown-control
     * CONTEXTO: DENTRO del iframe, dentro de la sección de Asignación
     */
    public static final Target SERVICIO_COMBO_CUSTOM = Target.the("Servicio (Custom)")
            .located(By.xpath("//div[.//*[normalize-space(.)='Asignación']]//label[normalize-space()='Servicio *' or normalize-space()='Servicio']/following::*[(self::button or self::input or self::div[contains(@class,'select')]) and not(self::input[@type='hidden'])][1]"));

    /**
     * Helper: Búsqueda en custom dropdown.
     * Input para escribir/filtrar opciones.
     * CONTEXTO: DENTRO del iframe, cuando está abierto un custom dropdown
     */
    public static final Target CUSTOM_DROPDOWN_SEARCH = Target.the("Custom dropdown search input")
            .located(By.cssSelector("input.custom-dropdown-search, input[placeholder*='buscar']"));

    /**
     * Helper: Item de custom dropdown.
     * {0} = valor/texto del item a seleccionar
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target CUSTOM_DROPDOWN_ITEM = Target.the("Custom dropdown list item {0}")
            .locatedBy("//div[@class='custom-dropdown-item' and contains(normalize-space(), '{0}')] | //div[@role='option' and contains(normalize-space(), '{0}')]");

    /**
     * Helper: Opción de lista.
     * {0} = texto exacto de la opción
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target OPCION_LISTA = Target.the("Opcion lista {0}")
            .locatedBy("//div[@role='option' and normalize-space(.)='{0}'] | //li[normalize-space(.)='{0}'] | //span[normalize-space(.)='{0}']");

    /**
     * Helper: Opción de lista (búsqueda parcial).
     * {0} = parte del texto de la opción
     * CONTEXTO: DENTRO del iframe
     */
    public static final Target OPCION_LISTA_CONTIENE = Target.the("Opcion lista contiene {0}")
            .locatedBy("//div[@role='option' and contains(normalize-space(.),'{0}')] | //li[contains(normalize-space(.),'{0}')] | //span[contains(normalize-space(.),'{0}')]");

    // ============================================================
    // SECCIÓN 8: TARGET WRAPPERS PARA SCROLL Y WAIT
    // Versiones Target de los campos para usar con Scroll.to() y WaitUntil
    // CONTEXTO: DENTRO del iframe
    // ============================================================

    /**
     * Target wrapper para Dirección del servicio.
     * Usado por: Scroll.to(), WaitUntil.the()
     */
    public static final Target DIRECCION_SERVICIO = Target.the("Dirección servicio")
            .located(By.cssSelector("input[name='data[direccion_servicio]']"));

    /**
     * Target wrapper para Dirección del destino.
     * Usado por: Scroll.to(), WaitUntil.the()
     */
    public static final Target DIRECCION_DESTINO = Target.the("Dirección del destino")
            .located(By.cssSelector("input[name='data[direccion_del_destino]']"));

    /**
     * Target wrapper para Detalle dirección servicio.
     * Usado por: Scroll.to(), WaitUntil.the()
     */
    public static final Target DETALLE_DIRECCION_SERVICIO = Target.the("Detalle dirección servicio")
            .located(By.cssSelector("input[name='data[detalle_direccion_servicio]']"));

    /**
     * Target wrapper para Detalle dirección destino.
     * Usado por: Scroll.to(), WaitUntil.the()
     */
    public static final Target DETALLE_DIRECCION_DESTINO = Target.the("Detalle dirección destino")
            .located(By.cssSelector("input[name='data[detalle_direccion_destino]']"));

    /**
     * Target wrapper para Ubicación servicio.
     * Usado por: Scroll.to(), WaitUntil.the()
     */
    public static final Target UBICACION_SERVICIO = Target.the("Ubicación servicio")
            .located(By.cssSelector("input[name='data[ubicacion_servicio]']"));

    /**
     * Target wrapper para Observación final.
     * Usado por: Scroll.to(), WaitUntil.the()
     */
    public static final Target OBSERVACION_FINAL = Target.the("Observación final del caso")
            .located(By.xpath(
                "//button[contains(@class,'mic-button')]/ancestor::div[contains(@class,'form-group')][1]//textarea[@maxlength='1024' and @rows='6'] | " +
                "//textarea[contains(@class,'form-control') and @maxlength='1024' and @rows='6']"
            ));

    /**
     * Target wrapper para Botón Guardar Formulario.
     * Usado por: Scroll.to(), WaitUntil.the(), Click.on()
     */
    public static final Target GUARDAR_FORMULARIO = Target.the("Guardar Formulario")
            .located(By.xpath("//button[@name='data[kaceCustomSubmit]' or contains(normalize-space(.), 'Guardar')]"));

}
