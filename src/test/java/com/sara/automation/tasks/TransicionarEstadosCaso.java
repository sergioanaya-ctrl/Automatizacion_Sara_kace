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
            return;
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
     * Detecta qué estados están disponibles después de la transición actual
     * PRIMERO busca "Aceptado y en desplazamiento" exactamente
     * LUEGO busca solo "Aceptado"
     * @return El nombre del estado disponible ("Aceptado y en desplazamiento", "Aceptado", o null)
     */
    private String detectarProximoEstado(WebDriver driver) {
        try {
            driver.switchTo().defaultContent();
            WebElement iframeElement = driver.findElement(By.id("form_onescript_iframe"));
            driver.switchTo().frame(iframeElement);
            
            // INTENTO 1: Buscar botón EXACTO "Aceptado y en desplazamiento"
            System.out.println("  [TransicionarEstadosCaso]   Intento 1: Buscando 'Aceptado y en desplazamiento'...");
            try {
                List<WebElement> botonesCompletos = driver.findElements(
                    By.xpath("//button[contains(text(), 'Aceptado') and contains(text(), 'desplazamiento')]"));
                
                if (botonesCompletos.size() > 0) {
                    for (WebElement boton : botonesCompletos) {
                        String texto = boton.getText().trim();
                        if (boton.isDisplayed()) {
                            System.out.println("  [TransicionarEstadosCaso]   ✓ ENCONTRADO: '" + texto + "'");
                            driver.switchTo().defaultContent();
                            return "Aceptado y en desplazamiento";
                        }
                    }
                }
            } catch (Exception e1) {
                System.out.println("  [TransicionarEstadosCaso]   No encontrado en intento 1");
            }
            
            // INTENTO 2: Buscar solo botón "Aceptado" (sin "desplazamiento")
            System.out.println("  [TransicionarEstadosCaso]   Intento 2: Buscando botón simple 'Aceptado'...");
            try {
                List<WebElement> botonesSimples = driver.findElements(
                    By.xpath("//button[text()='Aceptado' or normalize-space(text())='Aceptado']"));
                
                if (botonesSimples.size() > 0) {
                    for (WebElement boton : botonesSimples) {
                        if (boton.isDisplayed()) {
                            String texto = boton.getText().trim();
                            System.out.println("  [TransicionarEstadosCaso]   ✓ ENCONTRADO: '" + texto + "'");
                            driver.switchTo().defaultContent();
                            return "Aceptado";
                        }
                    }
                }
            } catch (Exception e2) {
                System.out.println("  [TransicionarEstadosCaso]   No encontrado en intento 2");
            }
            
            System.out.println("  [TransicionarEstadosCaso]   ✗ No se encontró ningún botón 'Aceptado'");
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
     * Espera 15 segundos para que la página se recargue completamente
     * entre cada transición de estado
     */
    private void esperarRecargaPagina() {
        System.out.println("  [TransicionarEstadosCaso]   Esperando 15 segundos para recarga de página...");
        try {
            Thread.sleep(15000); // 15 segundos
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        System.out.println("  [TransicionarEstadosCaso]   ✓ Página recargada, listo para siguiente estado");
    }
}
