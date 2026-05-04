package com.sara.automation.ui;

import net.serenitybdd.screenplay.targets.Target;
import org.openqa.selenium.By;

public class CasoCreatePage {
    // Localizador principal: busca el botón que contiene un span con el texto "Caso Express"
    public static final Target Caso_Express = Target.the("Boton Caso Express")
            .located(By.xpath("//button[.//span[normalize-space(text())='Caso Express']]"));

    // Fallback (antiguo), por si la estructura cambia y hace falta un localizador más específico
    public static final Target Caso_Express_FALLBACK = Target.the("Boton Caso Express (fallback)")
            .located(By.xpath("/html/body/div[5]/div/div[1]/div/a[2]"));

    // Nuevo: item de menú que aparece al abrir Caso Express
    public static final Target Formulario_Creacion_ASISTENCIA = Target.the("Formulario Creación de Casos (ASISTENCIA)")
            .located(By.xpath("//div[.//span[normalize-space(text())='Formulario Creación de Casos (ASISTENCIA)'] and @role='menuitem']"));

    // Boton que aparece en la pantalla de creación/edición para habilitar el formulario
    public static final Target Habilitar_Formulario = Target.the("Boton Habilitar Formulario")
            .located(By.cssSelector("button[name='data[habilitar_edicion_del_caso]']"));

    // Fallback por texto visible
    public static final Target Habilitar_Formulario_FALLBACK = Target.the("Boton Habilitar Formulario (texto)")
            .located(By.xpath("//button[contains(normalize-space(.), 'Habilitar Formulario')]"));

    // Campos a diligenciar automaticamente (selectores por atributo name para mayor estabilidad)
    public static final Target Numero_Expediente = Target.the("Número expediente")
            .located(By.cssSelector("input[name='data[numero_expediente]']"));

    public static final Target Nombre_Solicitante = Target.the("Nombre solicitante")
            .located(By.cssSelector("input[name='data[nombre_solicitante]']"));

    public static final Target Cedula_Solicitante = Target.the("Cédula del solicitante")
            .located(By.cssSelector("input[name='data[cedula_solicitante]']"));

    public static final Target Telefono_1 = Target.the("Teléfono 1")
            .located(By.cssSelector("input[name='data[telefono_1]']"));

    public static final Target Telefono_2 = Target.the("Teléfono 2")
            .located(By.cssSelector("input[name='data[telefono_2]']"));

    public static final Target Placa = Target.the("Placa")
            .located(By.cssSelector("input[name='data[placa]']"));

    public static final Target Direccion_Servicio = Target.the("Dirección servicio")
            .located(By.cssSelector("input[name='data[direccion_servicio]']"));

    public static final Target Detalle_Direccion_Servicio = Target.the("Detalle dirección servicio")
            .located(By.cssSelector("input[name='data[detalle_direccion_servicio]']"));

    public static final Target Detalle_Direccion_Destino = Target.the("Detalle dirección destino")
            .located(By.cssSelector("input[name='data[detalle_direccion_destino]']"));

    public static final Target Ubicacion_Servicio = Target.the("Ubicación servicio")
            .located(By.cssSelector("input[name='data[ubicacion_servicio]']"));

    // Seccion inferior para anclar combos dependientes
    public static final Target Seccion_Asignacion = Target.the("Sección Asignación")
            .located(By.xpath("//div[contains(@class,'panel') or contains(@class,'card')][.//*[normalize-space(.)='Asignación'] or .//h3[normalize-space(.)='Asignación']]"));

    // Combos en seccion General (listas dependientes)
    public static final Target Departamento_Solicita_Combo = Target.the("Departamento solicita")
            .located(By.xpath("//label[contains(normalize-space(.),'Departamento solicita')]/following::div[contains(@class,'input-group') or contains(@class,'form-group') or self::div][1]//*[self::input or self::button or self::div[contains(@class,'select')]][1]"));

    public static final Target Municipio_Solicita_Combo = Target.the("Municipio solicita")
            .located(By.xpath("//label[contains(normalize-space(.),'Municipio solicita')]/following::div[contains(@class,'input-group') or contains(@class,'form-group') or self::div][1]//*[self::input or self::button or self::div[contains(@class,'select')]][1]"));

    // Municipio por name (si existe como input/select estándar)
    public static final Target Municipio_Solicita_Input = Target.the("Municipio solicita (input/select by name)")
            .located(By.cssSelector("select[name='data[municipio_solicita]'], input[name='data[municipio_solicita]']"));

    // Combos en seccion Asignacion
    public static final Target Gestor_Coordinacion_Combo = Target.the("Gestor de coordinación")
            .located(By.xpath("//div[.//*[normalize-space(.)='Asignación']]//label[contains(normalize-space(.),'Gestor de coordinación')]/following::*[(self::button or self::input or self::div[contains(@class,'select')]) and not(self::input[@type='hidden'])][1]"));

    public static final Target Linea_Combo = Target.the("Línea")
            .located(By.xpath("//div[.//*[normalize-space(.)='Asignación']]//label[normalize-space()='Línea *' or normalize-space()='Línea']/following::*[(self::button or self::input or self::div[contains(@class,'select')]) and not(self::input[@type='hidden'])][1]"));

    public static final Target Servicio_Combo = Target.the("Servicio")
            .located(By.xpath("//div[.//*[normalize-space(.)='Asignación']]//label[normalize-space()='Servicio *' or normalize-space()='Servicio']/following::*[(self::button or self::input or self::div[contains(@class,'select')]) and not(self::input[@type='hidden'])][1]"));

    // Servicios especiales (combo) — suele ser un select con opciones NO/YES
    public static final Target Servicios_Especiales_Combo = Target.the("Servicios especiales")
            .located(By.cssSelector("select[name='data[servicios_especiales]'], input[name='data[servicios_especiales]'], div[data-name='servicios_especiales']"));

    public static final Target Opcion_Lista = Target.the("Opcion lista {0}")
            .locatedBy("//div[@role='option' and normalize-space(.)='{0}'] | //li[normalize-space(.)='{0}'] | //span[normalize-space(.)='{0}']");

    public static final Target Opcion_Lista_Contiene = Target.the("Opcion lista contiene {0}")
            .locatedBy("//div[@role='option' and contains(normalize-space(.),'{0}')] | //li[contains(normalize-space(.),'{0}')] | //span[contains(normalize-space(.),'{0}')]");

    // Custom dropdown helpers (visibles cuando el combo es del tipo custom)
    public static final Target CustomDropdownSearch = Target.the("Custom dropdown search input")
            .located(By.cssSelector(".custom-dropdown-search"));

    public static final Target CustomDropdownListItem = Target.the("Custom dropdown item {0}")
            .locatedBy("//ul[contains(@class,'custom-dropdown-list')]//li[normalize-space(.)='{0}']");

    // Iframe del formulario OneScript
    public static final Target Form_OneScript_Iframe = Target.the("Iframe formulario OneScript")
            .located(By.cssSelector("iframe#form_onescript_iframe, iframe[data-testid='form_onescript_iframe']"));
}
