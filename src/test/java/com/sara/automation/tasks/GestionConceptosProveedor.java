package com.sara.automation.tasks;

import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.List;
import java.util.Random;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Gestión de conceptos del proveedor sobre el expediente en edición:
 *   1. Espera y entra al iframe del formulario.
 *   2. Marca el check "no acepta conceptos" (data[no_acepta_conceptos_check]),
 *      que habilita los demás campos.
 *   3. Llena los campos NUMÉRICOS habilitados (inputmode='decimal' o pattern numérico)
 *      con un número de máximo 2 dígitos (limpia antes). Cubre los que se vayan habilitando.
 *   4. Click en Guardar (data[kaceCustomSubmit]) y espera.
 */
public class GestionConceptosProveedor implements Task {

    private static final By CHECK_NO_ACEPTA = By.cssSelector("input[name='data[no_acepta_conceptos_check]']");
    // Inputs numéricos habilitados del formulario (excluye deshabilitados/readonly más abajo).
    private static final By INPUTS_NUMERICOS = By.cssSelector(
            "input.form-control[type='text'][name^='data['][inputmode='decimal'],"
          + "input.form-control[type='text'][name^='data['][pattern='[0-9.]*']");
    private static final By BTN_GUARDAR = By.cssSelector("button[name='data[kaceCustomSubmit]']");

    private static final Random RANDOM = new Random();

    public static Performable now() {
        return instrumented(GestionConceptosProveedor.class);
    }

    @Override
    @Step("Gestionar los conceptos del proveedor (marcar check y llenar campos numéricos)")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        JavascriptExecutor js = (JavascriptExecutor) driver;
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(40));

        System.out.println("\n  [GestionConceptosProveedor] ==================== GESTIÓN DE CONCEPTOS ====================");

        // 1. Entrar al iframe que contiene el formulario (esperando a que cargue).
        entrarAlFrameDelFormulario(driver, wait);

        // 2. Marcar el check "no acepta conceptos" (baja con JS hasta él y lo clickea).
        WebElement check = wait.until(ExpectedConditions.presenceOfElementLocated(CHECK_NO_ACEPTA));
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", check);
        if (!check.isSelected()) {
            clickResiliente(js, check);
        }
        // Disparar change para que Form.io habilite los campos dependientes.
        js.executeScript("arguments[0].dispatchEvent(new Event('change', {bubbles:true}));", check);
        System.out.println("  [GestionConceptosProveedor] ✓ Check 'no acepta conceptos' marcado");

        // 3. Esperar a que se habiliten campos numéricos y llenarlos.
        int llenados = llenarCamposNumericosHabilitados(driver, js, wait);
        System.out.println("  [GestionConceptosProveedor] ✓ Campos numéricos llenados: " + llenados);

        // 4. Guardar.
        WebElement guardar = wait.until(ExpectedConditions.elementToBeClickable(BTN_GUARDAR));
        clickResiliente(js, guardar);
        System.out.println("  [GestionConceptosProveedor] ✓ Click en 'Guardar'");

        // Espera de asentado tras guardar.
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        System.out.println("  [GestionConceptosProveedor] ==================== ✓ CONCEPTOS GUARDADOS - FIN DEL FLUJO ====================\n");
    }

    /**
     * Llena cada input numérico visible y habilitado con un número de máx. 2 dígitos.
     * Reintenta una vez para capturar campos que Form.io habilita tras el re-render.
     * @return número de campos llenados.
     */
    private int llenarCamposNumericosHabilitados(WebDriver driver, JavascriptExecutor js, WebDriverWait wait) {
        // Esperar a que aparezca al menos un campo numérico habilitado.
        try {
            wait.until(d -> d.findElements(INPUTS_NUMERICOS).stream()
                    .anyMatch(el -> el.isDisplayed() && el.isEnabled()));
        } catch (Exception e) {
            System.out.println("  [GestionConceptosProveedor] ⚠ No se detectaron campos numéricos habilitados tras el check.");
        }

        int total = 0;
        // Dos pasadas: la segunda recoge campos que se habilitaron tras llenar los primeros.
        for (int pasada = 1; pasada <= 2; pasada++) {
            List<WebElement> campos = driver.findElements(INPUTS_NUMERICOS);
            for (WebElement campo : campos) {
                try {
                    if (!campo.isDisplayed() || !campo.isEnabled()) {
                        continue;
                    }
                    String readonly = campo.getAttribute("readonly");
                    if (readonly != null && !readonly.equals("false")) {
                        continue;
                    }
                    String name = campo.getAttribute("name");
                    String valor = String.valueOf(RANDOM.nextInt(99) + 1); // 1..99 (máx 2 dígitos)
                    escribirEnFormio(js, campo, valor);
                    System.out.println("  [GestionConceptosProveedor]   - " + name + " = " + valor);
                    total++;
                } catch (org.openqa.selenium.StaleElementReferenceException ignored) {
                    // El formulario se re-renderizó; la siguiente pasada lo recoge.
                }
            }
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
        return total;
    }

    private void entrarAlFrameDelFormulario(WebDriver driver, WebDriverWait wait) {
        boolean encontrado = wait.until(d -> {
            d.switchTo().defaultContent();
            if (!d.findElements(CHECK_NO_ACEPTA).isEmpty()) {
                return true;
            }
            List<WebElement> conocido = d.findElements(By.id("form_onescript_iframe"));
            if (!conocido.isEmpty()) {
                try {
                    d.switchTo().frame(conocido.get(0));
                    if (!d.findElements(CHECK_NO_ACEPTA).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
                d.switchTo().defaultContent();
            }
            for (WebElement frame : d.findElements(By.tagName("iframe"))) {
                try {
                    d.switchTo().defaultContent();
                    d.switchTo().frame(frame);
                    if (!d.findElements(CHECK_NO_ACEPTA).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
            }
            d.switchTo().defaultContent();
            return false;
        });
        if (!encontrado) {
            throw new AssertionError("No se encontró el check 'no acepta conceptos' (data[no_acepta_conceptos_check]) en la página ni en sus iframes.");
        }
        System.out.println("  [GestionConceptosProveedor] ✓ Formulario de conceptos localizado");
    }

    private void escribirEnFormio(JavascriptExecutor js, WebElement input, String valor) {
        try {
            input.clear();
            input.sendKeys(valor);
        } catch (Exception ignored) {
        }
        String actual = input.getAttribute("value");
        if (actual == null || !actual.equals(valor)) {
            js.executeScript(
                    "arguments[0].value = arguments[1];"
                  + "arguments[0].dispatchEvent(new Event('input', {bubbles:true}));"
                  + "arguments[0].dispatchEvent(new Event('change', {bubbles:true}));",
                    input, valor);
        } else {
            js.executeScript(
                    "arguments[0].dispatchEvent(new Event('input', {bubbles:true}));"
                  + "arguments[0].dispatchEvent(new Event('change', {bubbles:true}));",
                    input);
        }
    }

    private void clickResiliente(JavascriptExecutor js, WebElement elemento) {
        try {
            elemento.click();
        } catch (Exception e1) {
            try {
                js.executeScript("arguments[0].click();", elemento);
            } catch (Exception e2) {
                js.executeScript(
                        "var evt = new MouseEvent('click', { bubbles: true, cancelable: true, view: window });"
                      + "arguments[0].dispatchEvent(evt);",
                        elemento);
            }
        }
    }
}
