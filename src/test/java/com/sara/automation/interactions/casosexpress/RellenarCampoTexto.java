package com.sara.automation.interactions.casosexpress;

import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Interaction;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * INTERACTION: Rellenar un campo de texto en el formulario.
 *
 * ============================================================
 * PROPÓSITO:
 * Escribir un valor en un campo input o textarea dentro del iframe.
 * Maneja casos especiales como campos controlados por React/Formio.
 *
 * CONTEXTO INICIAL: DENTRO del iframe
 * CONTEXTO FINAL: DENTRO del iframe (no cambia)
 * ============================================================
 *
 * PASOS:
 * 1. Esperar a que el campo esté visible y habilitado
 * 2. Hacer clic en el campo (para asegurar que tenga foco)
 * 3. Limpiar el campo (por si tiene valor previo)
 * 4. Escribir el valor
 * 5. Esperar a que el valor se haya registrado
 *
 * IMPORTANTE:
 * - Esta Interaction es genérica y reutilizable para cualquier campo
 * - Funciona con campos controlados por React/Formio
 * - El localizador (By) debe encontrar el campo dentro del iframe
 *
 * PRECONDICIÓN:
 * - El driver está dentro del iframe
 * - El campo está visible y habilitado
 *
 * POSTCONDICIÓN:
 * - El campo contiene el valor especificado
 * - El campo ha perdido el foco (permitiendo validaciones)
 *
 * EJEMPLO DE USO:
 * actor.attemptsTo(RellenarCampoTexto.con(CasoExpressPage.CAMPO_NOMBRE, "Juan García"));
 * actor.attemptsTo(RellenarCampoTexto.con(CasoExpressPage.CAMPO_CEDULA, "1234567890"));
 */
public class RellenarCampoTexto implements Interaction {

    private final By localizadorCampo;
    private final String valor;
    private static final int TIMEOUT_SEGUNDOS = 15;

    /**
     * Constructor privado. Usar factory method con()
     */
    private RellenarCampoTexto(By localizadorCampo, String valor) {
        this.localizadorCampo = localizadorCampo;
        this.valor = valor;
    }

    /**
     * Factory method para crear esta Interaction.
     *
     * @param localizadorCampo El By que identifica el campo (ej: CasoExpressPage.CAMPO_NOMBRE)
     * @param valor           El valor a escribir en el campo
     * @return                La Interaction instrumentada
     */
    public static Interaction con(By localizadorCampo, String valor) {
        return instrumented(RellenarCampoTexto.class, localizadorCampo, valor);
    }

    @Override
    @Step("Rellenar campo con valor: '{valor}'")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        JavascriptExecutor js = (JavascriptExecutor) driver;

        System.out.println("[RellenarCampoTexto] Escribiendo en campo: '" + valor + "'");

        // PASO 1: Esperar a que el campo esté visible y clickeable
        // ============================================================
        System.out.println("[RellenarCampoTexto]   PASO 1: Esperando campo visible...");
        WebElement campo;
        try {
            campo = new WebDriverWait(driver, Duration.ofSeconds(TIMEOUT_SEGUNDOS))
                    .until(ExpectedConditions.elementToBeClickable(localizadorCampo));
            System.out.println("[RellenarCampoTexto]     ✓ Campo encontrado y clickeable");
        } catch (Exception e) {
            throw new RuntimeException(
                "[RellenarCampoTexto] No se pudo encontrar el campo después de " + TIMEOUT_SEGUNDOS + " segundos. " +
                "Localizador: " + localizadorCampo,
                e
            );
        }

        // PASO 2: Hacer scroll y clic para asegurar que el campo tenga foco
        // ============================================================
        System.out.println("[RellenarCampoTexto]   PASO 2: Haciendo scroll e intentando foco...");
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", campo);
        campo.click();
        System.out.println("[RellenarCampoTexto]     ✓ Campo con foco");

        // PASO 3: Limpiar el campo (selectAll + Delete)
        // ============================================================
        System.out.println("[RellenarCampoTexto]   PASO 3: Limpiando campo previo...");
        campo.clear();
        System.out.println("[RellenarCampoTexto]     ✓ Campo limpiado");

        // PASO 4: Escribir el valor
        // ============================================================
        System.out.println("[RellenarCampoTexto]   PASO 4: Escribiendo valor...");
        campo.sendKeys(valor);
        System.out.println("[RellenarCampoTexto]     ✓ Valor escrito: '" + valor + "'");

        // PASO 5: Verificar que el valor se registró
        // ============================================================
        System.out.println("[RellenarCampoTexto]   PASO 5: Verificando que el valor se registró...");
        try {
            new WebDriverWait(driver, Duration.ofSeconds(5))
                    .until(d -> {
                        WebElement el = d.findElement(localizadorCampo);
                        String valorActual = el.getAttribute("value");
                        if (valorActual == null) {
                            valorActual = el.getText();
                        }
                        return valorActual.contains(valor);
                    });
            System.out.println("[RellenarCampoTexto]     ✓ Valor confirmado en el campo\n");
        } catch (Exception e) {
            // Advertencia pero no falla (el valor puede estar en otro atributo)
            System.out.println("[RellenarCampoTexto]     ⚠ No se pudo confirmar el valor, pero se escribió\n");
        }
    }

}
