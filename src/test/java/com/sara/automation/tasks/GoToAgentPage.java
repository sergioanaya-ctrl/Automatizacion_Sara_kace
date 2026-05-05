package com.sara.automation.tasks;

import com.sara.automation.ui.AgentPage;
import com.sara.automation.ui.CasoCreatePage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.actions.Open;
import net.serenitybdd.screenplay.waits.WaitUntil;
import net.thucydides.core.annotations.Step;

import static net.serenitybdd.screenplay.Tasks.instrumented;
import static net.serenitybdd.screenplay.matchers.WebElementStateMatchers.isVisible;

public class GoToAgentPage implements Task {

    public static Performable now() {
        return instrumented(GoToAgentPage.class);
    }

    @Override
    @Step("Navega a la pagina de agent")
    public <T extends Actor> void performAs(T actor) {
        actor.attemptsTo(Open.url(AgentPage.URL));
        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Caso_Express, isVisible()).forNoMoreThan(20).seconds());
    }
}
