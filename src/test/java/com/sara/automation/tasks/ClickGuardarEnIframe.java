package com.sara.automation.tasks;

import net.serenitybdd.core.Serenity;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Task;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import static net.serenitybdd.screenplay.Tasks.instrumented;

public class ClickGuardarEnIframe implements Task {

    @Override
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = Serenity.getDriver();

        try {
            // Intentar cambiar al iframe
            driver.switchTo().frame("form_onescript_iframe");
            System.out.println("[ClickGuardarEnIframe] Cambiado al iframe exitosamente");
        } catch (Exception e) {
            System.out.println("[ClickGuardarEnIframe] No se pudo cambiar al iframe: " + e.getMessage());
            driver.switchTo().defaultContent();
        }

        try {
            WebElement btn = driver.findElement(By.id("kaceCustomSubmit"));
            ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", btn);
            try {
                // Clic NATIVO (isTrusted=true) primero: el guardado real puede depender de un
                // gesto de usuario confiable, igual que se detectó en la carga de opciones del
                // dropdown de proveedores. Un click() vía JS puede "funcionar" visualmente sin
                // disparar el submit real, dejando el registro sin persistir en el backend.
                btn.click();
                System.out.println("[ClickGuardarEnIframe] Resultado del click: SUCCESS (nativo)");
            } catch (Exception eNativo) {
                System.out.println("[ClickGuardarEnIframe] Click nativo falló (" + eNativo.getMessage()
                        + "), usando fallback JS...");
                Object result = ((JavascriptExecutor) driver).executeScript("arguments[0].click(); return 'SUCCESS';", btn);
                System.out.println("[ClickGuardarEnIframe] Resultado del click: " + result + " (JS)");
            }
        } catch (org.openqa.selenium.NoSuchElementException e) {
            System.out.println("[ClickGuardarEnIframe] ERROR: Botón no encontrado en el DOM");
            throw new AssertionError("Botón kaceCustomSubmit no encontrado en el iframe");
        } catch (Exception e) {
            System.out.println("[ClickGuardarEnIframe] Error haciendo click: " + e.getMessage());
            throw new AssertionError("No se pudo hacer click al botón: " + e.getMessage());
        } finally {
            // Volver al contenido principal
            try {
                driver.switchTo().defaultContent();
                System.out.println("[ClickGuardarEnIframe] Vuelto al contenido principal");
            } catch (Exception e) {
                System.out.println("[ClickGuardarEnIframe] Error al volver al contenido principal: " + e.getMessage());
            }
        }
    }
    
    public static ClickGuardarEnIframe clickGuardarEnIframe() {
        return instrumented(ClickGuardarEnIframe.class);
    }
}
