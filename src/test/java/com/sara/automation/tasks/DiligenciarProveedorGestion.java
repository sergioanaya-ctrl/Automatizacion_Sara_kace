package com.sara.automation.tasks;

import com.sara.automation.interactions.SwitchToOneScriptIframe;
import com.sara.automation.ui.CasoCreatePage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.actions.Click;
import net.serenitybdd.screenplay.actions.Enter;
import net.serenitybdd.screenplay.actions.Scroll;
import net.serenitybdd.screenplay.targets.Target;
import net.serenitybdd.screenplay.waits.WaitUntil;
import net.thucydides.core.annotations.Step;

import static net.serenitybdd.screenplay.Tasks.instrumented;
import static net.serenitybdd.screenplay.matchers.WebElementStateMatchers.isVisible;

public class DiligenciarProveedorGestion implements Task {

    private static final String TIEMPO_MONITOREO_SITIO_DEFAULT = "60";
    private static final String TIEMPO_MONITOREO_DESTINO_DEFAULT = "120";
    private static final String CELULAR_TECNICO_DEFAULT = "3103904286";

    private final String nombreProveedor;
    private final String servicio;

    public DiligenciarProveedorGestion(String nombreProveedor, String servicio) {
        this.nombreProveedor = nombreProveedor;
        this.servicio = servicio;
    }

    public static Performable conDatos(String nombreProveedor, String servicio) {
        return instrumented(DiligenciarProveedorGestion.class, nombreProveedor, servicio);
    }

    @Override
    @Step("Gestionar proveedor: abrir tab, crear, seleccionar nombre/respuesta y guardar")
    public <T extends Actor> void performAs(T actor) {
        // Este paso ocurre dentro del formulario OneScript luego de crear el caso.
        actor.attemptsTo(SwitchToOneScriptIframe.required());

        // Esperar a que la página se recargue completamente después de guardar
        // La página hace reload y vuelve a mostrar los elementos del formulario
        try {
            Thread.sleep(8000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // El tab "Gestión de proveedores" está en los tabs de la sección de creación/edición
        // Primero, hacer scroll para encontrar el tab
        actor.attemptsTo(Scroll.to(CasoCreatePage.Tab_Gestion_Proveedores));
        
        // Esperar a que el tab sea visible y clickeable
        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Tab_Gestion_Proveedores, isVisible()).forNoMoreThan(30).seconds());
        
        // Hacer clic en el tab de Gestión de Proveedores
        actor.attemptsTo(Click.on(CasoCreatePage.Tab_Gestion_Proveedores));
        
        // Después de hacer clic en el tab, esperar a que los elementos dentro del tab estén visibles
        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Boton_Crear_Proveedor, isVisible()).forNoMoreThan(30).seconds());
        
        // Finalmente, hacer clic en el botón Crear del grid de proveedores
        actor.attemptsTo(Click.on(CasoCreatePage.Boton_Crear_Proveedor));

        seleccionarDesdeDropdownCustom(
                actor,
                CasoCreatePage.Nombre_Proveedor_Dropdown_Control,
                CasoCreatePage.Nombre_Proveedor_Dropdown_Search,
                nombreProveedor
        );

        seleccionarDesdeDropdownCustom(
                actor,
                CasoCreatePage.Respuesta_Proveedor_Dropdown_Control,
                CasoCreatePage.Respuesta_Proveedor_Dropdown_Search,
                servicio
        );

        // Estos campos se habilitan después de elegir la respuesta del proveedor (ej. TOMA SERVICIO).
        llenarCampo(actor, CasoCreatePage.Tiempo_Monitoreo_Sitio_Minutos, TIEMPO_MONITOREO_SITIO_DEFAULT);
        llenarCampo(actor, CasoCreatePage.Tiempo_Monitoreo_Destino_Minutos, TIEMPO_MONITOREO_DESTINO_DEFAULT);
        llenarCampo(actor, CasoCreatePage.Celular_Tecnico_Proveedor, CELULAR_TECNICO_DEFAULT);

        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Guardar_Proveedor, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(Click.on(CasoCreatePage.Guardar_Proveedor));

        // Después de guardar el proveedor, hacer click en el guardado general flotante para aplicar cambios.
        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Guardar_General_Flotante, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(Click.on(CasoCreatePage.Guardar_General_Flotante));
    }

    private <T extends Actor> void llenarCampo(T actor, Target campo, String valor) {
        actor.attemptsTo(Scroll.to(campo));
        actor.attemptsTo(WaitUntil.the(campo, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(Enter.theValue(valor).into(campo));
    }

    private <T extends Actor> void seleccionarDesdeDropdownCustom(T actor, Target control, Target searchInput, String valor) {
        actor.attemptsTo(WaitUntil.the(control, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(Click.on(control));

        actor.attemptsTo(WaitUntil.the(searchInput, isVisible()).forNoMoreThan(10).seconds());
        actor.attemptsTo(Enter.theValue(valor).into(searchInput));

        actor.attemptsTo(WaitUntil.the(CasoCreatePage.CustomDropdownListItem.of(valor), isVisible()).forNoMoreThan(10).seconds());
        actor.attemptsTo(Click.on(CasoCreatePage.CustomDropdownListItem.of(valor)));
    }
}
