package com.sara.automation.interactions;

import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Interaction;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Interaction para clickear el estado "Finalizado" dentro del iframe OneScript
 * Cierra Timer popup, busca botón con XPath simple, clickea y guarda
 */
public class ClickEstadoFinalizado implements Interaction {

    public static ClickEstadoFinalizado clickEstadoFinalizado() {
        return instrumented(ClickEstadoFinalizado.class);
    }

    @Override
    public <T extends Actor> void performAs(T actor) {
        try {
            System.out.println("\n  [ClickEstadoFinalizado] ========== TRANSICIÓN A Finalizado ==========");
            
            WebDriver driver = net.serenitybdd.screenplay.abilities.BrowseTheWeb.as(actor).getDriver();
            JavascriptExecutor js = (JavascriptExecutor) driver;
            
            // Cambiar al iframe
            driver.switchTo().defaultContent();
            WebElement iframeElement = driver.findElement(By.id("form_onescript_iframe"));
            driver.switchTo().frame(iframeElement);
            System.out.println("  [ClickEstadoFinalizado] ✓ Iframe OK");
            
            // PASO 1: Cerrar Timer
            System.out.println("  [ClickEstadoFinalizado] Paso 1: Cerrando popup Timer si existe...");
            cerrarTimerPopup(driver, js);
            
            WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
            
            // PASO 2: Buscar botón Finalizado
            System.out.println("  [ClickEstadoFinalizado] Paso 2: Buscando botón 'Finalizado'...");
            
            WebElement estado = wait.until(
                ExpectedConditions.presenceOfElementLocated(
                    By.xpath("//button[contains(text(), 'Finalizado')]")
                )
            );
            
            // Scroll y visibilidad
            js.executeScript("arguments[0].scrollIntoView({behavior: 'auto', block: 'center'});", estado);
            Thread.sleep(500);
            
            // Esperar clickeable
            estado = wait.until(
                ExpectedConditions.elementToBeClickable(
                    By.xpath("//button[contains(text(), 'Finalizado')]")
                )
            );
            
            System.out.println("  [ClickEstadoFinalizado] ✓ Botón 'Finalizado' encontrado");
            
            // PASO 3: Clickear
            System.out.println("  [ClickEstadoFinalizado] Paso 3: Clickeando 'Finalizado'...");
            ejecutarClickConReintentos(js, estado, "Finalizado");
            
            Thread.sleep(500);
            System.out.println("  [ClickEstadoFinalizado] ✓ 'Finalizado' seleccionado");
            
            // PASO 4: Buscar y clickear botón de guardado
            System.out.println("  [ClickEstadoFinalizado] Paso 4: Buscando botón guardado...");
            
            WebElement guardarButton = wait.until(
                ExpectedConditions.presenceOfElementLocated(
                    By.id("kaceCustomSubmit")
                )
            );
            
            js.executeScript("arguments[0].scrollIntoView({behavior: 'auto', block: 'center'});", guardarButton);
            Thread.sleep(500);
            
            guardarButton = wait.until(
                ExpectedConditions.elementToBeClickable(
                    By.id("kaceCustomSubmit")
                )
            );
            
            System.out.println("  [ClickEstadoFinalizado] ✓ Botón guardado encontrado");
            
            // PASO 5: Clickear guardado
            System.out.println("  [ClickEstadoFinalizado] Paso 5: Clickeando guardado...");
            ejecutarClickConReintentos(js, guardarButton, "Guardado");
            
            Thread.sleep(500);
            System.out.println("  [ClickEstadoFinalizado] ✓✓ 'Finalizado' guardado exitosamente");
            
            driver.switchTo().defaultContent();
            System.out.println("  [ClickEstadoFinalizado] ========== COMPLETADO ==========\n");
            
        } catch (TimeoutException e) {
            System.out.println("  [ClickEstadoFinalizado] ✗ TIMEOUT: " + e.getMessage());
            try {
                WebDriver driver = net.serenitybdd.screenplay.abilities.BrowseTheWeb.as(actor).getDriver();
                driver.switchTo().defaultContent();
            } catch (Exception ignored) {}
        } catch (Exception e) {
            System.out.println("  [ClickEstadoFinalizado] ✗ Error: " + e.getMessage());
            try {
                WebDriver driver = net.serenitybdd.screenplay.abilities.BrowseTheWeb.as(actor).getDriver();
                driver.switchTo().defaultContent();
            } catch (Exception ignored) {}
        }
    }
    
    private void cerrarTimerPopup(WebDriver driver, JavascriptExecutor js) {
        try {
            try {
                WebElement timerCancel = driver.findElement(
                    By.xpath("//div[contains(@class, 'timer') or contains(@class, 'modal')]//button[contains(text(), 'Cancelar')]")
                );
                if (timerCancel.isDisplayed()) {
                    System.out.println("  [ClickEstadoFinalizado]   Popup Timer encontrado, cerrando...");
                    js.executeScript("arguments[0].click();", timerCancel);
                    Thread.sleep(800);
                    System.out.println("  [ClickEstadoFinalizado]   ✓ Timer cerrado");
                    return;
                }
            } catch (Exception e) {
                System.out.println("  [ClickEstadoFinalizado]   Intento 1 falló, probando otra estrategia...");
            }
            
            try {
                WebElement anyCancel = driver.findElement(By.xpath("//button[contains(text(), 'Cancelar')]"));
                if (anyCancel.isDisplayed()) {
                    System.out.println("  [ClickEstadoFinalizado]   Botón Cancelar encontrado, clickeando...");
                    js.executeScript("arguments[0].click();", anyCancel);
                    Thread.sleep(800);
                    System.out.println("  [ClickEstadoFinalizado]   ✓ Timer cerrado");
                    return;
                }
            } catch (Exception e) {
                System.out.println("  [ClickEstadoFinalizado]   ✓ No hay Timer visible");
            }
        } catch (Exception e) {
            System.out.println("  [ClickEstadoFinalizado]   ✓ No se encontró Timer popup");
        }
    }
    
    private void ejecutarClickConReintentos(JavascriptExecutor js, WebElement elemento, String nombre) throws Exception {
        boolean exitoso = false;
        
        try {
            System.out.println("  [ClickEstadoFinalizado]   Intento 1: click() directo en " + nombre + "...");
            js.executeScript("arguments[0].click();", elemento);
            System.out.println("  [ClickEstadoFinalizado]   ✓ Click exitoso");
            exitoso = true;
        } catch (Exception e1) {
            try {
                System.out.println("  [ClickEstadoFinalizado]   Intento 2: dispatchEvent en " + nombre + "...");
                js.executeScript(
                    "var evt = new MouseEvent('click', { bubbles: true, cancelable: true, view: window }); " +
                    "arguments[0].dispatchEvent(evt);",
                    elemento
                );
                System.out.println("  [ClickEstadoFinalizado]   ✓ dispatchEvent exitoso");
                exitoso = true;
            } catch (Exception e2) {
                try {
                    System.out.println("  [ClickEstadoFinalizado]   Intento 3: focus + click en " + nombre + "...");
                    js.executeScript(
                        "arguments[0].focus(); " +
                        "var evt = new MouseEvent('click', { bubbles: true, cancelable: true, view: window }); " +
                        "arguments[0].dispatchEvent(evt);",
                        elemento
                    );
                    System.out.println("  [ClickEstadoFinalizado]   ✓ focus + click exitoso");
                    exitoso = true;
                } catch (Exception e3) {
                    System.out.println("  [ClickEstadoFinalizado]   ✗ Todos los intentos fallaron para " + nombre);
                }
            }
        }
        
        if (!exitoso) {
            throw new Exception("No se pudo hacer click en " + nombre);
        }
    }
}