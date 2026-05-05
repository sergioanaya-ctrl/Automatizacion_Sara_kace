package com.sara.automation.interactions;

import com.sara.automation.ui.CasoCreatePage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Interaction;
import net.serenitybdd.screenplay.Performable;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static net.serenitybdd.screenplay.Tasks.instrumented;
import static net.serenitybdd.screenplay.abilities.BrowseTheWeb.as;

public class SwitchToOneScriptIframe implements Interaction {

    // Esta interacción solo cambia el contexto del navegador.
    // No llena campos: su responsabilidad es dejar al actor 'dentro' del iframe OneScript
    // para que las siguientes interacciones sí puedan ver el formulario.

    private static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(8);

    private final boolean required;

    public SwitchToOneScriptIframe(boolean required) {
        this.required = required;
    }

    public static Performable required() {
        return instrumented(SwitchToOneScriptIframe.class, true);
    }

    public static Performable ifPresent() {
        return instrumented(SwitchToOneScriptIframe.class, false);
    }

    @Override
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = as(actor).getDriver();

        // Primero vuelve al documento principal y luego busca el iframe del formulario.
        driver.switchTo().defaultContent();

        try {
            new WebDriverWait(driver, DEFAULT_TIMEOUT)
                    .until(ExpectedConditions.frameToBeAvailableAndSwitchToIt(CasoCreatePage.Form_OneScript_Iframe_By));
        } catch (TimeoutException e) {
            if (required) {
                throw new RuntimeException("No se encontro el iframe OneScript para continuar con el formulario", e);
            }
        }
    }
}

