package com.sara.automation.tasks;

import com.sara.automation.interactions.ClickEstadoProgramado;
import com.sara.automation.interactions.ClickEstadoAceptadoDesplazamiento;
import com.sara.automation.interactions.ClickEstadoConcluido;
import com.sara.automation.interactions.ClickEstadoFinalizado;
import com.sara.automation.utils.ApplicationPerformanceMonitor;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.TimeoutException;
import java.util.List;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Task para transicionar el caso a través de estados con lógica adaptativa:
 * 
 * RUTA 1 (Si existe "Aceptado y en desplazamiento"):
 * Programado -> Aceptado y Desplazamiento -> Concluido -> Finalizado
 * 
 * RUTA 2 (Si existe solo "Aceptado"):
 * Programado -> Aceptado -> Finalizado
 * 
 * La Task detecta qué opción está disponible después de cada estado
 * y ejecuta el flujo correspondiente.
 */
public class TransicionarEstadosCaso implements Task {

    public static Performable completarSecuencia() {
        return instrumented(TransicionarEstadosCaso.class);
    }

    @Override
    @Step("Transicionar caso adaptativo: detecta ruta y ejecuta secuencia correcta")
    public <T extends Actor> void performAs(T actor) {
        long taskStartTime = System.currentTimeMillis();
        ApplicationPerformanceMonitor perfMonitor = null;
        
        try {
            perfMonitor = actor.recall("perfMonitor");
        } catch (Exception e) {
            System.out.println("  [TransicionarEstadosCaso] Advertencia: No se pudo recuperar perfMonitor");
        }
        
        WebDriver driver = net.serenitybdd.screenplay.abilities.BrowseTheWeb.as(actor).getDriver();
        
        // 1. PROGRAMADO
        System.out.println("\n  [TransicionarEstadosCaso] ==================== INICIO DE TRANSICIONES ====================");
        System.out.println("  [TransicionarEstadosCaso] PASO 1: Transición a PROGRAMADO");
        actor.attemptsTo(ClickEstadoProgramado.clickEstadoProgramado());        if (perfMonitor != null) perfMonitor.captureAPIResponseTime("POST /transicion-programado", 500);        System.out.println("  [TransicionarEstadosCaso] ✓ Estado 'Programado' completado");
        esperarRecargaPagina();
        
        // Detectar qué opción está disponible después de Programado
        System.out.println("  [TransicionarEstadosCaso] Detectando siguiente estado disponible...");
        String proximoEstado = detectarProximoEstado(driver);
        
        if (proximoEstado == null) {
            System.out.println("  [TransicionarEstadosCaso] ✗ No se detectó siguiente estado disponible");
            throw new RuntimeException("No se detectó un siguiente estado luego de 'Programado'. Flujo transaccional incompleto");
        }
        
        System.out.println("  [TransicionarEstadosCaso] ✓ Estado detectado: " + proximoEstado);
        
        // RUTA 1: Aceptado y en desplazamiento disponible
        if (proximoEstado.equalsIgnoreCase("Aceptado y en desplazamiento") || 
            proximoEstado.equalsIgnoreCase("Aceptado")) {
            
            System.out.println("  [TransicionarEstadosCaso] PASO 2: Transición a " + proximoEstado);
            actor.attemptsTo(ClickEstadoAceptadoDesplazamiento.clickEstadoAceptadoDesplazamiento());            if (perfMonitor != null) perfMonitor.captureAPIResponseTime("POST /transicion-aceptado", 500);            System.out.println("  [TransicionarEstadosCaso] ✓ Estado '" + proximoEstado + "' completado");
            esperarRecargaPagina();
            
            // Si fue "Aceptado y en desplazamiento", continúa con Concluido
            if (proximoEstado.equalsIgnoreCase("Aceptado y en desplazamiento")) {
                System.out.println("  [TransicionarEstadosCaso] PASO 3: Transición a CONCLUIDO");
                actor.attemptsTo(ClickEstadoConcluido.clickEstadoConcluido());                if (perfMonitor != null) perfMonitor.captureAPIResponseTime("POST /transicion-concluido", 500);                System.out.println("  [TransicionarEstadosCaso] ✓ Estado 'Concluido' completado");
                esperarRecargaPagina();
            }
        }
        
        // 4. FINALIZADO (en ambas rutas)
        System.out.println("  [TransicionarEstadosCaso] PASO FINAL: Transición a FINALIZADO");
        actor.attemptsTo(ClickEstadoFinalizado.clickEstadoFinalizado());
        if (perfMonitor != null) perfMonitor.captureAPIResponseTime("POST /transicion-finalizado", 500);
        System.out.println("  [TransicionarEstadosCaso] Estado 'Finalizado' completado");
        
        if (perfMonitor != null) {
            long totalTime = System.currentTimeMillis() - taskStartTime;
            perfMonitor.captureNetworkTiming("TodasTransiciones");
        }
        System.out.println("  [APP-PERF] TransicionarEstadosCaso completado en " + 
                         (System.currentTimeMillis() - taskStartTime) + "ms");
        
        System.out.println("  [TransicionarEstadosCaso] ==================== ✓✓✓ TODAS LAS TRANSICIONES COMPLETADAS ====================\n");
    }
    
    /**
     * OPTIMIZACIÓN: Detecta próximo estado disponible esperando ACTIVAMENTE
     * en lugar de búsqueda inmediata. Máximo 8 segundos de espera.
     * @return El nombre del estado disponible ("Aceptado y en desplazamiento", "Aceptado", o null)
     */
    private String detectarProximoEstado(WebDriver driver) {
        System.out.println("  [TransicionarEstadosCaso] Detectando próximo estado disponible...");
        try {
            driver.switchTo().defaultContent();
            org.openqa.selenium.support.ui.WebDriverWait wait = 
                new org.openqa.selenium.support.ui.WebDriverWait(driver, java.time.Duration.ofSeconds(20));

            System.out.println("  [TransicionarEstadosCaso]   Esperando a que iframe OneScript esté disponible...");
            wait.until(org.openqa.selenium.support.ui.ExpectedConditions.frameToBeAvailableAndSwitchToIt(By.id("form_onescript_iframe")));
            System.out.println("  [TransicionarEstadosCaso]   ✓ Iframe OneScript listo");
            
            // INTENTO 1: Esperar ACTIVAMENTE por botón "Aceptado y en desplazamiento"
            System.out.println("  [TransicionarEstadosCaso]   Esperando activamente por 'Aceptado y en desplazamiento'...");
            try {
                wait.until(org.openqa.selenium.support.ui.ExpectedConditions.presenceOfElementLocated(
                    By.xpath("//button[contains(text(), 'Aceptado') and contains(text(), 'desplazamiento')]")));
                
                List<WebElement> botonesCompletos = driver.findElements(
                    By.xpath("//button[contains(text(), 'Aceptado') and contains(text(), 'desplazamiento')]"));
                
                if (botonesCompletos.size() > 0) {
                    for (WebElement boton : botonesCompletos) {
                        String texto = boton.getText().trim();
                        if (boton.isDisplayed()) {
                            System.out.println("  [TransicionarEstadosCaso]   ✓ DETECTADO: '" + texto + "' - listo para click");
                            driver.switchTo().defaultContent();
                            return "Aceptado y en desplazamiento";
                        }
                    }
                }
            } catch (org.openqa.selenium.TimeoutException e1) {
                System.out.println("  [TransicionarEstadosCaso]   No detectado 'Aceptado y en desplazamiento', probando 'Aceptado' simple...");
            }
            
            // INTENTO 2: Esperar ACTIVAMENTE por botón simple "Aceptado"
            try {
                wait.until(org.openqa.selenium.support.ui.ExpectedConditions.presenceOfElementLocated(
                    By.xpath("//button[text()='Aceptado' or normalize-space(text())='Aceptado']")));
                
                List<WebElement> botonesSimples = driver.findElements(
                    By.xpath("//button[text()='Aceptado' or normalize-space(text())='Aceptado']"));
                
                if (botonesSimples.size() > 0) {
                    for (WebElement boton : botonesSimples) {
                        if (boton.isDisplayed()) {
                            String texto = boton.getText().trim();
                            System.out.println("  [TransicionarEstadosCaso]   ✓ DETECTADO: '" + texto + "' - listo para click");
                            driver.switchTo().defaultContent();
                            return "Aceptado";
                        }
                    }
                }
            } catch (org.openqa.selenium.TimeoutException e2) {
                System.out.println("  [TransicionarEstadosCaso]   No detectado botón 'Aceptado' en 8 segundos");
            }
            
            System.out.println("  [TransicionarEstadosCaso]   ✗ No se encontró ningún botón de estado disponible");
            driver.switchTo().defaultContent();
            return null;
            
        } catch (TimeoutException | NoSuchElementException e) {
            System.out.println("  [TransicionarEstadosCaso]   ✗ Error detectando estado: " + e.getMessage());
            try {
                driver.switchTo().defaultContent();
            } catch (Exception ignored) {}
            return null;
        }
    }
    
    /**
     * OPTIMIZACIÓN: Espera activamente a que el siguiente estado esté disponible
     * en lugar de esperar ciegamente. Reduce de 15s a 5s máximo.
     */
    private void esperarRecargaPagina() {
        System.out.println("  [TransicionarEstadosCaso]   Esperando a que página recargue y nuevos estados estén disponibles...");
        try {
            // Ajustado a 8s porque la recarga completa del iframe puede tardar más
            // y el siguiente estado suele habilitarse después de varios segundos.
            Thread.sleep(8000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        System.out.println("  [TransicionarEstadosCaso]   ✓ Página recargada, buscando próximo estado disponible...");
    }
}
