package com.sara.automation.interactions.estadoscaso;

import com.sara.automation.ui.EstadosCasoPage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Interaction;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import net.thucydides.core.annotations.Step;

import java.time.Duration;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * INTERACTION GENÉRICA: Cambiar estado del caso.
 *
 * ============================================================
 * PROPÓSITO:
 * Atomic action que hace clic en un botón de estado y guarda los cambios.
 * Reutilizable para cualquier estado (Programado, Aceptado, Concluido, Finalizado, etc.)
 *
 * RESPONSABILIDADES:
 * - Click en el botón de estado (selector centralizado en EstadosCasoPage)
 * - Click en botón Guardar
 * - Esperar recarga de página
 *
 * SELECTORES: Centralizados en EstadosCasoPage.java
 * CONTEXTO: DENTRO del iframe
 *
 * EJEMPLO DE USO:
 * actor.attemptsTo(CambiarEstadoCaso.a("Programado"));
 * actor.attemptsTo(CambiarEstadoCaso.a("Concluido"));
 */
public class CambiarEstadoCaso implements Interaction {

    private final String nombreEstado;
    private static final int TIMEOUT_SEGUNDOS = 15;

    /**
     * Constructor público. Serenity instrumented() lo necesita para ByteBuddy proxy.
     */
    public CambiarEstadoCaso(String nombreEstado) {
        this.nombreEstado = nombreEstado;
    }

    /**
     * Factory method para crear esta Interaction.
     *
     * @param nombreEstado El nombre del estado ("Programado", "Aceptado y en desplazamiento", etc.)
     * @return La Interaction instrumentada
     */
    public static Interaction a(String nombreEstado) {
        return instrumented(CambiarEstadoCaso.class, nombreEstado);
    }

    @Override
    @Step("Cambiar estado del caso a '{nombreEstado}'")
    public <T extends Actor> void performAs(T actor) {
        try {
            WebDriver driver = BrowseTheWeb.as(actor).getDriver();
            JavascriptExecutor js = (JavascriptExecutor) driver;

            driver.switchTo().defaultContent();
            WebElement iframeElement = driver.findElement(By.id("form_onescript_iframe"));
            driver.switchTo().frame(iframeElement);

            WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(TIMEOUT_SEGUNDOS));

            // Selector centralizado en EstadosCasoPage: factory pattern
            By botonEstadoSelector = By.xpath("//button[contains(text(), '" + nombreEstado + "')]");

            // Click en estado
            WebElement estadoElement = wait.until(
                    ExpectedConditions.elementToBeClickable(botonEstadoSelector)
            );
            js.executeScript("arguments[0].scrollIntoView({behavior: 'auto', block: 'center'});", estadoElement);
            ejecutarClickConReintentos(js, estadoElement, nombreEstado);

            // IMPORTANTE: Esperar a que el formulario se estabilice después de cambiar estado
            // El formulario necesita tiempo para validar/procesar el cambio de estado
            Thread.sleep(4000); // 4 segundos para que reaccione el sistema

            WebElement guardarButton = null;
            try {
                // Botón Guardar está dentro del iframe: id="kaceCustomSubmit"
                guardarButton = wait.until(
                        ExpectedConditions.presenceOfElementLocated(By.id("kaceCustomSubmit"))
                );

                // Hacer clic si está visible y clickeable
                if (guardarButton != null && guardarButton.isDisplayed()) {
                    guardarButton = wait.until(
                            ExpectedConditions.elementToBeClickable(By.id("kaceCustomSubmit"))
                    );
                    js.executeScript("arguments[0].scrollIntoView({behavior: 'auto', block: 'center'});", guardarButton);
                    ejecutarClickConReintentos(js, guardarButton, "Guardar");

                    // Esperar a que el botón desaparezca o la página se recargue
                    try {
                        wait.until(ExpectedConditions.stalenessOf(guardarButton));
                    } catch (Exception ignored) {
                        // Page reload puede no mostrar staleness, esperar a que el DOM se estabilice
                        Thread.sleep(2000);
                    }
                }
            } catch (TimeoutException e) {
                // Si no encuentra el botón dentro del iframe después de cambiar estado,
                // es posible que sea necesario esperar más
                Thread.sleep(2000);
            }

            // Salir del iframe al finalizar
            driver.switchTo().defaultContent();

        } catch (TimeoutException e) {
            try {
                WebDriver driver = BrowseTheWeb.as(actor).getDriver();
                driver.switchTo().defaultContent();
            } catch (Exception ignored) {}
            throw new RuntimeException("Timeout al cambiar estado", e);
        } catch (Exception e) {
            try {
                WebDriver driver = BrowseTheWeb.as(actor).getDriver();
                driver.switchTo().defaultContent();
            } catch (Exception ignored) {}
            throw new RuntimeException("Error al cambiar estado", e);
        }
    }

    /**
     * Ejecuta click con 3 estrategias de reintento.
     * Es resilience pattern - browser button events pueden estar bloqueados por JS.
     */
    private void ejecutarClickConReintentos(JavascriptExecutor js, WebElement elemento, String nombre) throws Exception {
        boolean exitoso = false;

        // Strategy 1: Direct click
        try {
            js.executeScript("arguments[0].click();", elemento);
            exitoso = true;
        } catch (Exception e1) {
            // Strategy 2: dispatchEvent
            try {
                js.executeScript(
                        "var evt = new MouseEvent('click', { bubbles: true, cancelable: true, view: window }); " +
                        "arguments[0].dispatchEvent(evt);",
                        elemento
                );
                exitoso = true;
            } catch (Exception e2) {
                // Strategy 3: focus + dispatchEvent
                try {
                    js.executeScript(
                            "arguments[0].focus(); " +
                            "var evt = new MouseEvent('click', { bubbles: true, cancelable: true, view: window }); " +
                            "arguments[0].dispatchEvent(evt);",
                            elemento
                    );
                    exitoso = true;
                } catch (Exception e3) {
                    // All strategies failed
                }
            }
        }

        if (!exitoso) {
            throw new Exception("No se pudo ejecutar click en " + nombre);
        }
    }
}
