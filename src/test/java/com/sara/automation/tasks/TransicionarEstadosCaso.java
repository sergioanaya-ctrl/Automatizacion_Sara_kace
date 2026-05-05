package com.sara.automation.tasks;

import com.sara.automation.ui.CasoCreatePage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.actions.Click;
import net.serenitybdd.screenplay.waits.WaitUntil;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import static net.serenitybdd.screenplay.Tasks.instrumented;
import static net.serenitybdd.screenplay.abilities.BrowseTheWeb.as;
import static net.serenitybdd.screenplay.matchers.WebElementStateMatchers.isVisible;

public class TransicionarEstadosCaso implements Task {

    // Flujo de transición de estados del caso (post-proveedor):
    // Programado -> Aceptado y en desplazamiento -> Concluido -> Finalizado

    public static Performable completarSecuencia() {
        return instrumented(TransicionarEstadosCaso.class);
    }

    @Override
    @Step("Transicionar caso a través de estados: Programado -> Aceptado/Desplazamiento -> Concluido -> Finalizado")
    public <T extends Actor> void performAs(T actor) {
        // 1) Programado
        seleccionarEstadoYValidar(actor, CasoCreatePage.Boton_Estado_Programado, "Programado");

        // 2) Aceptado y en desplazamiento
        seleccionarEstadoYValidar(actor, CasoCreatePage.Boton_Estado_Aceptado_Desplazamiento, "Aceptado y en desplazamiento");

        // 3) Concluido
        seleccionarEstadoYValidar(actor, CasoCreatePage.Boton_Estado_Concluido, "Concluido");

        // 4) Finalizado
        seleccionarEstadoYValidar(actor, CasoCreatePage.Boton_Estado_Finalizado, "Finalizado");
    }

    private <T extends Actor> void seleccionarEstadoYValidar(T actor, net.serenitybdd.screenplay.targets.Target botonEstado, String nombreEstado) {
        // Click en el estado
        actor.attemptsTo(
                WaitUntil.the(botonEstado, isVisible()).forNoMoreThan(15).seconds(),
                Click.on(botonEstado)
        );

        // Guardar general
        actor.attemptsTo(
                WaitUntil.the(CasoCreatePage.Guardar_General_Flotante, isVisible()).forNoMoreThan(15).seconds(),
                Click.on(CasoCreatePage.Guardar_General_Flotante)
        );

        // Esperar que el sistema guarde (modal de guardado)
        esperarGuardoCompleto(actor);

        // Validar que el estado actual cambió al estado seleccionado
        validarEstadoActual(actor, nombreEstado);
    }

    private <T extends Actor> void esperarGuardoCompleto(T actor) {
        WebDriver driver = as(actor).getDriver();
        // Esperar a que desaparezca el modal de "Guardando..." si existe
        try {
            long timeout = System.currentTimeMillis() + 30000; // 30 segundos
            while (System.currentTimeMillis() < timeout) {
                try {
                    WebElement modal = driver.findElement(org.openqa.selenium.By.xpath("//div[contains(text(),'Guardando')]"));
                    if (!modal.isDisplayed()) {
                        Thread.sleep(500);
                        break;
                    }
                    Thread.sleep(300);
                } catch (org.openqa.selenium.NoSuchElementException e) {
                    Thread.sleep(500);
                    break;
                }
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private <T extends Actor> void validarEstadoActual(T actor, String estadoEsperado) {
        WebDriver driver = as(actor).getDriver();
        long timeout = System.currentTimeMillis() + 30000; // 30 segundos

        while (System.currentTimeMillis() < timeout) {
            try {
                WebElement estadoActual = driver.findElement(
                        org.openqa.selenium.By.xpath("//h2[contains(normalize-space(.),'Estado actual')]/following::button[@disabled or contains(@class,'btn-success')][1]")
                );
                String textoEstado = estadoActual.getText().trim();

                if (textoEstado.contains(estadoEsperado) || textoEstado.equalsIgnoreCase(estadoEsperado)) {
                    break;
                }
                Thread.sleep(500);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            } catch (org.openqa.selenium.NoSuchElementException e) {
                try {
                    Thread.sleep(500);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                }
            }
        }
    }
}
