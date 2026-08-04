package com.sara.automation.tasks;

import com.sara.automation.ui.CasoExpressPage;
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

public class SelectManualLists implements Task {

    private final String departamento;
    private final String municipio;
    private final String serviciosEspeciales;
    private final String gestor;
    private final String linea;
    private final String servicio;

    public SelectManualLists(String departamento, String municipio, String serviciosEspeciales, String gestor, String linea, String servicio) {
        this.departamento = departamento;
        this.municipio = municipio;
        this.serviciosEspeciales = serviciosEspeciales;
        this.gestor = gestor;
        this.linea = linea;
        this.servicio = servicio;
    }

    public static Performable withValues(String departamento, String municipio, String serviciosEspeciales, String gestor, String linea, String servicio) {
        return instrumented(SelectManualLists.class, departamento, municipio, serviciosEspeciales, gestor, linea, servicio);
    }

    @Override
    @Step("Selecciona listas manuales respetando la secuencia de la pantalla")
    public <T extends Actor> void performAs(T actor) {
        // Esta tarea asume que ya estamos dentro del iframe OneScript.

        // 1) Seccion General
        seleccionar(actor, CasoExpressPage.DEPARTAMENTO_COMBO_CUSTOM, departamento);
        seleccionar(actor, CasoExpressPage.MUNICIPIO_COMBO_CUSTOM, municipio);

        if (serviciosEspeciales != null && !serviciosEspeciales.isEmpty()) {
            seleccionar(actor, CasoExpressPage.SERVICIOS_ESPECIALES_COMBO, serviciosEspeciales);
        }

        // 2) Seccion Asignacion
        actor.attemptsTo(Scroll.to(CasoExpressPage.SECCION_ASIGNACION));
        actor.attemptsTo(WaitUntil.the(CasoExpressPage.GESTOR_COMBO_CUSTOM, isVisible()).forNoMoreThan(15).seconds());

        seleccionar(actor, CasoExpressPage.GESTOR_COMBO_CUSTOM, gestor);
        seleccionar(actor, CasoExpressPage.LINEA_COMBO_CUSTOM, linea);
        seleccionar(actor, CasoExpressPage.SERVICIO_COMBO_CUSTOM, servicio);
    }

    private <T extends Actor> void seleccionar(T actor, Target combo, String valor) {
        actor.attemptsTo(WaitUntil.the(combo, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(Click.on(combo));

        try {
            actor.attemptsTo(WaitUntil.the(CasoExpressPage.CUSTOM_DROPDOWN_SEARCH, isVisible()).forNoMoreThan(3).seconds());
            actor.attemptsTo(Enter.theValue(valor).into(CasoExpressPage.CUSTOM_DROPDOWN_SEARCH));
            actor.attemptsTo(WaitUntil.the(CasoExpressPage.CUSTOM_DROPDOWN_ITEM.of(valor), isVisible()).forNoMoreThan(10).seconds());
            actor.attemptsTo(Click.on(CasoExpressPage.CUSTOM_DROPDOWN_ITEM.of(valor)));
            return;
        } catch (Exception ignore) {
            // Continua a estrategia estandar.
        }

        try {
            actor.attemptsTo(WaitUntil.the(CasoExpressPage.OPCION_LISTA.of(valor), isVisible()).forNoMoreThan(10).seconds());
            actor.attemptsTo(Click.on(CasoExpressPage.OPCION_LISTA.of(valor)));
        } catch (Exception e) {
            actor.attemptsTo(WaitUntil.the(CasoExpressPage.OPCION_LISTA_CONTIENE.of(valor), isVisible()).forNoMoreThan(10).seconds());
            actor.attemptsTo(Click.on(CasoExpressPage.OPCION_LISTA_CONTIENE.of(valor)));
        }
    }
}
