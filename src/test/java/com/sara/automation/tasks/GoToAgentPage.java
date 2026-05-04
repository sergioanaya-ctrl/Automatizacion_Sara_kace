package com.sara.automation.tasks;

import com.sara.automation.ui.AgentPage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.actions.Open;
import net.thucydides.core.annotations.Step;

import static net.serenitybdd.screenplay.Tasks.instrumented;

public class GoToAgentPage implements Task {

    public static Performable now() {
        return instrumented(GoToAgentPage.class);
    }

    @Override
    @Step("Navega a la pagina de agent")
    public <T extends Actor> void performAs(T actor) {
        actor.attemptsTo(Open.url(AgentPage.URL));
    }
}
