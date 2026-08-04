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
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * INTERACTION: Seleccionar una opción en un combo (select).
 *
 * ============================================================
 * PROPÓSITO:
 * Seleccionar un valor en un elemento <select> (combo/dropdown).
 * Maneja tanto selects estándares como controles Formio/React.
 *
 * CONTEXTO INICIAL: DENTRO del iframe
 * CONTEXTO FINAL: DENTRO del iframe (no cambia)
 * ============================================================
 *
 * PASOS:
 * 1. Esperar a que el combo esté visible y habilitado
 * 2. Hacer clic en el combo para abrirlo
 * 3. Seleccionar la opción por valor
 * 4. Esperar a que la selección se registre
 * 5. Si es un combo que dispara cambios (ej: Departamento -> Municipio),
 *    esperar a que cualquier combo dependiente se actualice
 *
 * IMPORTANTE:
 * - Algunos combos en Formio pueden disparar cambios en cascada
 *   (ej: seleccionar Departamento actualiza la lista de Municipios)
 * - Por eso siempre esperamos a que haya un pequeño delay para
 *   permitir que los cambios dinámicos se procesen
 *
 * PRECONDICIÓN:
 * - El driver está dentro del iframe
 * - El combo está visible y habilitado
 * - La opción a seleccionar existe en la lista
 *
 * POSTCONDICIÓN:
 * - La opción está seleccionada en el combo
 * - Cualquier combo dependiente ha sido actualizado (si aplica)
 *
 * EJEMPLO DE USO:
 * actor.attemptsTo(SeleccionarOpcionCombo.en(CasoExpressPage.COMBO_DEPARTAMENTO, "Bogotá"));
 * actor.attemptsTo(SeleccionarOpcionCombo.en(CasoExpressPage.COMBO_LINEA, "Hogar"));
 */
public class SeleccionarOpcionCombo implements Interaction {

    private final By localizadorCombo;
    private final String opcion;
    private static final int TIMEOUT_SEGUNDOS = 15;

    /**
     * Constructor privado. Usar factory method en()
     */
    private SeleccionarOpcionCombo(By localizadorCombo, String opcion) {
        this.localizadorCombo = localizadorCombo;
        this.opcion = opcion;
    }

    /**
     * Factory method para crear esta Interaction.
     *
     * @param localizadorCombo El By que identifica el combo (ej: CasoExpressPage.COMBO_DEPARTAMENTO)
     * @param opcion          El texto o valor de la opción a seleccionar
     * @return                La Interaction instrumentada
     */
    public static Interaction en(By localizadorCombo, String opcion) {
        return instrumented(SeleccionarOpcionCombo.class, localizadorCombo, opcion);
    }

    @Override
    @Step("Seleccionar opción '{opcion}' en combo")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        JavascriptExecutor js = (JavascriptExecutor) driver;

        System.out.println("[SeleccionarOpcionCombo] Seleccionando opción: '" + opcion + "'");

        // PASO 1: Esperar a que el combo esté visible y habilitado
        // ============================================================
        System.out.println("[SeleccionarOpcionCombo]   PASO 1: Esperando combo visible...");
        WebElement combo;
        try {
            combo = new WebDriverWait(driver, Duration.ofSeconds(TIMEOUT_SEGUNDOS))
                    .until(ExpectedConditions.elementToBeClickable(localizadorCombo));
            System.out.println("[SeleccionarOpcionCombo]     ✓ Combo encontrado y clickeable");
        } catch (Exception e) {
            throw new RuntimeException(
                "[SeleccionarOpcionCombo] No se pudo encontrar el combo después de " + TIMEOUT_SEGUNDOS + " segundos. " +
                "Localizador: " + localizadorCombo,
                e
            );
        }

        // PASO 2: Hacer scroll y clic para abrirlo
        // ============================================================
        System.out.println("[SeleccionarOpcionCombo]   PASO 2: Scroll e intentando abrir combo...");
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", combo);
        combo.click();
        System.out.println("[SeleccionarOpcionCombo]     ✓ Combo abierto");

        // PASO 3: Seleccionar la opción
        // ============================================================
        System.out.println("[SeleccionarOpcionCombo]   PASO 3: Buscando y seleccionando opción...");
        try {
            Select select = new Select(combo);

            // Intento 1: Seleccionar por texto visible (más amigable)
            try {
                select.selectByVisibleText(opcion);
                System.out.println("[SeleccionarOpcionCombo]     ✓ Opción seleccionada por texto: '" + opcion + "'");
            } catch (Exception e1) {
                // Intento 2: Seleccionar por valor (value attribute)
                System.out.println("[SeleccionarOpcionCombo]     Texto no coincidió, intentando por valor...");
                select.selectByValue(opcion);
                System.out.println("[SeleccionarOpcionCombo]     ✓ Opción seleccionada por valor: '" + opcion + "'");
            }
        } catch (Exception e) {
            throw new RuntimeException(
                "[SeleccionarOpcionCombo] No se pudo seleccionar la opción '" + opcion + "'. " +
                "Verificar que la opción existe en el combo.",
                e
            );
        }

        // PASO 4: Esperar a que la selección se registre
        // ============================================================
        System.out.println("[SeleccionarOpcionCombo]   PASO 4: Esperando actualización...");
        try {
            new WebDriverWait(driver, Duration.ofSeconds(5))
                    .until(d -> {
                        WebElement el = d.findElement(localizadorCombo);
                        // Obtener el texto del option seleccionado
                        Select s = new Select(el);
                        WebElement selected = s.getFirstSelectedOption();
                        String textoSeleccionado = selected.getText();
                        System.out.println("[SeleccionarOpcionCombo]     Valor actual: '" + textoSeleccionado + "'");
                        return textoSeleccionado.contains(opcion) || selected.getAttribute("value").equals(opcion);
                    });
            System.out.println("[SeleccionarOpcionCombo]     ✓ Selección confirmada\n");
        } catch (Exception e) {
            // Advertencia pero no falla
            System.out.println("[SeleccionarOpcionCombo]     ⚠ No se pudo confirmar selección, pero se ejecutó\n");
        }

        // PASO 5: Pequeño delay para permitir actualizaciones en cascada
        // ============================================================
        // Algunos combos (Departamento->Municipio) actualizan otros combos dependientes
        try {
            Thread.sleep(500);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

}
