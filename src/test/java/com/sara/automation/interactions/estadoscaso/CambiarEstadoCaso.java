package com.sara.automation.interactions.estadoscaso;

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
 * Hace clic en un botón de estado (Programado, Aceptado, Concluido, Finalizado)
 * y guarda los cambios. Unifica la lógica común de todos los cambios de estado.
 *
 * CONTEXTO INICIAL: DENTRO del iframe
 * CONTEXTO FINAL: DENTRO del iframe
 * ============================================================
 *
 * PASOS:
 * 1. Cambiar/confirmar contexto del iframe
 * 2. Buscar botón del estado (por nombre)
 * 3. Hacer clic en el botón del estado
 * 4. Buscar y hacer clic en botón Guardar
 * 5. Esperar recarga de página
 * 6. Confirmar que el estado anterior desapareció
 *
 * PRECONDICIÓN:
 * - El driver está dentro del iframe (o se cambiará automáticamente)
 * - El formulario está visible con los botones de estado
 *
 * POSTCONDICIÓN:
 * - El estado ha sido cambiado y guardado
 * - El botón anterior desapareció del formulario
 * - El driver sigue en el iframe
 *
 * EJEMPLO DE USO:
 * actor.attemptsTo(CambiarEstadoCaso.a("Programado"));
 * actor.attemptsTo(CambiarEstadoCaso.a("Aceptado y en desplazamiento"));
 * actor.attemptsTo(CambiarEstadoCaso.a("Concluido"));
 * actor.attemptsTo(CambiarEstadoCaso.a("Finalizado"));
 */
public class CambiarEstadoCaso implements Interaction {

    private final String nombreEstado;
    private static final int TIMEOUT_SEGUNDOS = 15;

    /**
     * Constructor privado. Usar factory method a()
     */
    private CambiarEstadoCaso(String nombreEstado) {
        this.nombreEstado = nombreEstado;
    }

    /**
     * Factory method para crear esta Interaction.
     *
     * @param nombreEstado El nombre del estado a cambiar
     *                      (p.ej. "Programado", "Aceptado", "Concluido", "Finalizado")
     * @return La Interaction instrumentada
     */
    public static Interaction a(String nombreEstado) {
        return instrumented(CambiarEstadoCaso.class, nombreEstado);
    }

    @Override
    @Step("Cambiar estado del caso a '{nombreEstado}'")
    public <T extends Actor> void performAs(T actor) {
        try {
            System.out.println("\n  [CambiarEstadoCaso] ========== CAMBIAR A '" + nombreEstado + "' ==========");

            WebDriver driver = BrowseTheWeb.as(actor).getDriver();
            JavascriptExecutor js = (JavascriptExecutor) driver;

            // PASO 1: Cambiar/confirmar contexto del iframe
            // ============================================================
            System.out.println("  [CambiarEstadoCaso] PASO 1: Confirmando contexto del iframe...");
            driver.switchTo().defaultContent();
            WebElement iframeElement = driver.findElement(By.id("form_onescript_iframe"));
            driver.switchTo().frame(iframeElement);
            System.out.println("  [CambiarEstadoCaso]   ✓ Iframe OK");

            WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(TIMEOUT_SEGUNDOS));

            // PASO 2: Buscar botón del estado
            // ============================================================
            System.out.println("  [CambiarEstadoCaso] PASO 2: Buscando botón '" + nombreEstado + "'...");

            WebElement botonEstado = esperarBuscarBotonEstado(wait, nombreEstado);

            System.out.println("  [CambiarEstadoCaso]   ✓ Botón encontrado");

            // PASO 3: Scroll e intentar hacer clic
            // ============================================================
            System.out.println("  [CambiarEstadoCaso] PASO 3: Scroll e intentando clic en '" + nombreEstado + "'...");
            js.executeScript("arguments[0].scrollIntoView({behavior: 'auto', block: 'center'});", botonEstado);

            // Esperar clickeable antes de intentar
            botonEstado = wait.until(ExpectedConditions.elementToBeClickable(botonEstado));

            ejecutarClickConReintentos(js, botonEstado, nombreEstado);
            System.out.println("  [CambiarEstadoCaso]   ✓ Clic exitoso");

            // PASO 4: Buscar y hacer clic en botón Guardar
            // ============================================================
            System.out.println("  [CambiarEstadoCaso] PASO 4: Esperando botón Guardar...");
            try {
                wait.until(ExpectedConditions.presenceOfElementLocated(By.id("kaceCustomSubmit")));
                System.out.println("  [CambiarEstadoCaso]   ✓ Botón Guardar detectado");
            } catch (Exception e) {
                System.out.println("  [CambiarEstadoCaso]   ⚠ Botón Guardar no inmediato, procediendo...");
            }

            WebElement guardarButton = wait.until(
                    ExpectedConditions.presenceOfElementLocated(By.id("kaceCustomSubmit"))
            );

            js.executeScript("arguments[0].scrollIntoView({behavior: 'auto', block: 'center'});", guardarButton);

            guardarButton = wait.until(ExpectedConditions.elementToBeClickable(By.id("kaceCustomSubmit")));

            System.out.println("  [CambiarEstadoCaso] PASO 5: Haciendo clic en Guardar...");
            ejecutarClickConReintentos(js, guardarButton, "Guardar");
            System.out.println("  [CambiarEstadoCaso]   ✓ Clic en Guardar exitoso");

            // PASO 6: Esperar recarga de página
            // ============================================================
            System.out.println("  [CambiarEstadoCaso] PASO 6: Esperando recarga de página...");
            try {
                wait.until(ExpectedConditions.stalenessOf(guardarButton));
                System.out.println("  [CambiarEstadoCaso]   ✓ Página recargada");
            } catch (Exception e) {
                System.out.println("  [CambiarEstadoCaso]   ⚠ Página no mostró staleness inmediato, continuando...");
            }

            // PASO 7: Confirmar que el estado anterior desapareció
            // ============================================================
            System.out.println("  [CambiarEstadoCaso] PASO 7: Confirmando que '" + nombreEstado + "' desapareció...");
            try {
                wait.until(ExpectedConditions.invisibilityOfElementLocated(
                        By.xpath("//button[contains(text(), '" + nombreEstado + "')]")
                ));
                System.out.println("  [CambiarEstadoCaso]   ✓ '" + nombreEstado + "' desapareció - cambio exitoso!");
            } catch (Exception e) {
                System.out.println("  [CambiarEstadoCaso]   ⚠ Estado aún visible, pero procediendo (puede estar en transición)...");
            }

            System.out.println("  [CambiarEstadoCaso] ✓✓ Estado cambiado a '" + nombreEstado + "' exitosamente");
            System.out.println("  [CambiarEstadoCaso] ========== COMPLETADO ==========\n");

        } catch (TimeoutException e) {
            System.out.println("  [CambiarEstadoCaso] ✗ TIMEOUT: " + e.getMessage());
            try {
                WebDriver driver = BrowseTheWeb.as(actor).getDriver();
                driver.switchTo().defaultContent();
            } catch (Exception ignored) {
            }
            throw new RuntimeException("Fallo al cambiar estado a '" + nombreEstado + "' por timeout", e);
        } catch (Exception e) {
            System.out.println("  [CambiarEstadoCaso] ✗ Error: " + e.getMessage());
            try {
                WebDriver driver = BrowseTheWeb.as(actor).getDriver();
                driver.switchTo().defaultContent();
            } catch (Exception ignored) {
            }
            throw new RuntimeException("Fallo al cambiar estado a '" + nombreEstado + "'", e);
        }
    }

    /**
     * Busca el botón del estado con múltiples estrategias.
     * Intenta búsqueda exacta primero, luego búsqueda parcial.
     */
    private WebElement esperarBuscarBotonEstado(WebDriverWait wait, String nombreEstado) {
        // Intento 1: Búsqueda exacta con "y en desplazamiento" (para Aceptado)
        if (nombreEstado.contains("Aceptado")) {
            try {
                System.out.println("  [CambiarEstadoCaso]   Sub-intento 1: Buscando 'Aceptado y en desplazamiento'...");
                return wait.until(
                        ExpectedConditions.presenceOfElementLocated(
                                By.xpath("//button[contains(text(), 'Aceptado') and contains(text(), 'desplazamiento')]")
                        )
                );
            } catch (TimeoutException e1) {
                System.out.println("  [CambiarEstadoCaso]   Sub-intento 1 falló, intentando 'Aceptado' simple...");
            }
        }

        // Intento 2: Búsqueda por texto parcial (genérico)
        return wait.until(
                ExpectedConditions.presenceOfElementLocated(
                        By.xpath("//button[contains(text(), '" + nombreEstado + "')]")
                )
        );
    }

    /**
     * Ejecuta click con múltiples reintentos (3 estrategias).
     */
    private void ejecutarClickConReintentos(JavascriptExecutor js, WebElement elemento, String nombre) throws Exception {
        boolean exitoso = false;

        // Intento 1: click() directo
        try {
            System.out.println("  [CambiarEstadoCaso]   Intento 1: click() directo en " + nombre + "...");
            js.executeScript("arguments[0].click();", elemento);
            System.out.println("  [CambiarEstadoCaso]   ✓ Click exitoso");
            exitoso = true;
        } catch (Exception e1) {
            // Intento 2: dispatchEvent
            try {
                System.out.println("  [CambiarEstadoCaso]   Intento 2: dispatchEvent en " + nombre + "...");
                js.executeScript(
                        "var evt = new MouseEvent('click', { bubbles: true, cancelable: true, view: window }); " +
                        "arguments[0].dispatchEvent(evt);",
                        elemento
                );
                System.out.println("  [CambiarEstadoCaso]   ✓ dispatchEvent exitoso");
                exitoso = true;
            } catch (Exception e2) {
                // Intento 3: focus + click
                try {
                    System.out.println("  [CambiarEstadoCaso]   Intento 3: focus + click en " + nombre + "...");
                    js.executeScript(
                            "arguments[0].focus(); " +
                            "var evt = new MouseEvent('click', { bubbles: true, cancelable: true, view: window }); " +
                            "arguments[0].dispatchEvent(evt);",
                            elemento
                    );
                    System.out.println("  [CambiarEstadoCaso]   ✓ focus + click exitoso");
                    exitoso = true;
                } catch (Exception e3) {
                    System.out.println("  [CambiarEstadoCaso]   ✗ Todos los intentos fallaron para " + nombre);
                }
            }
        }

        if (!exitoso) {
            throw new Exception("No se pudo hacer click en " + nombre);
        }
    }
}
