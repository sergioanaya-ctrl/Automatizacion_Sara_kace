package com.sara.automation.tasks;

import com.sara.automation.ui.AgentPage;
import com.sara.automation.ui.LoginPage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import net.serenitybdd.screenplay.actions.Click;
import net.serenitybdd.screenplay.actions.Enter;
import net.serenitybdd.screenplay.actions.Open;
import net.serenitybdd.screenplay.waits.WaitUntil;
import net.thucydides.core.annotations.Step;
import org.hamcrest.Matchers;

import static net.serenitybdd.screenplay.matchers.WebElementStateMatchers.isVisible;
import static net.serenitybdd.screenplay.Tasks.instrumented;

public class LoginWithCognito implements Task {

    private final String username;
    private final String password;

    public LoginWithCognito(String username, String password) {
        this.username = username;
        this.password = password;
    }

    public static Performable with(String username, String password) {
        return instrumented(LoginWithCognito.class, username, password);
    }

    @Override
    @Step("Login con Cognito usando credenciales")
    public <T extends Actor> void performAs(T actor) {
        // 1. Abrir URL de Cognito
        actor.attemptsTo(
                Open.url(LoginPage.COGNITO_LOGIN_URL)
        );

        // 2. Llenar username y click Next
        actor.attemptsTo(
                WaitUntil.the(LoginPage.COGNITO_USERNAME, isVisible()).forNoMoreThan(10).seconds(),
                Enter.theValue(username).into(LoginPage.COGNITO_USERNAME),
                Click.on(LoginPage.COGNITO_NEXT_BUTTON)
        );

        // 3. Llenar password y click Continue
        actor.attemptsTo(
                WaitUntil.the(LoginPage.COGNITO_PASSWORD, isVisible()).forNoMoreThan(10).seconds(),
                Enter.theValue(password).into(LoginPage.COGNITO_PASSWORD),
                Click.on(LoginPage.COGNITO_CONTINUE_BUTTON)
        );

        // 4. Esperar a estar en Agent page (verificar URL contiene "/agent")
        esperarEnAgentPage(actor);
    }

    private void esperarEnAgentPage(Actor actor) {
        long startTime = System.currentTimeMillis();
        long timeout = 8000; // 8 segundos

        while (System.currentTimeMillis() - startTime < timeout) {
            try {
                String currentUrl = BrowseTheWeb.as(actor).getDriver().getCurrentUrl();
                if (currentUrl.contains("/agent")) {
                    return;
                }
                Thread.sleep(500);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }

        // Si no llegó automáticamente a /agent, fuerza la navegación a la URL de Agent.
        actor.attemptsTo(Open.url(AgentPage.URL));

        long retryStart = System.currentTimeMillis();
        long retryTimeout = 20000; // 20 segundos
        while (System.currentTimeMillis() - retryStart < retryTimeout) {
            try {
                String currentUrl = BrowseTheWeb.as(actor).getDriver().getCurrentUrl();
                if (currentUrl.contains("/agent")) {
                    return;
                }
                Thread.sleep(500);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }

        throw new AssertionError("Timeout esperando a llegar a AgentPage. URL actual: " + 
                BrowseTheWeb.as(actor).getDriver().getCurrentUrl());
    }
}
