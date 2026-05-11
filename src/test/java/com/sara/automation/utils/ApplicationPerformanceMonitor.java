package com.sara.automation.utils;

import net.serenitybdd.screenplay.Actor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.JavascriptExecutor;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * Monitor de PERFORMANCE DE LA APLICACIÓN Sara3
 * Mide: Response times de la app, render times, network latency
 * NO mide: CPU/Memory de la máquina de test
 */
public class ApplicationPerformanceMonitor {
    
    private static final String APP_PERF_LOG_DIR = "target/app_performance_logs";
    private WebDriver driver;
    private Map<String, NetworkMetric> networkMetrics = new LinkedHashMap<>();
    private Map<String, RenderMetric> renderMetrics = new LinkedHashMap<>();
    private String testName;
    private long testStartTime;
    
    public ApplicationPerformanceMonitor(String testName, WebDriver driver) {
        this.testName = testName;
        this.driver = driver;
        this.testStartTime = System.currentTimeMillis();
        ensureLogDirectory();
    }
    
    /**
     * MÉTRICA 1: Captura Network Timing (cuánto tarda la app en responder)
     * Ejecuta JavaScript para leer Performance API del navegador
     */
    public void captureNetworkTiming(String actionName) {
        try {
            JavascriptExecutor js = (JavascriptExecutor) driver;
            
            // Obtener todas las requests realizadas
            String script = "return window.performance.getEntriesByType('resource').map(e => (" +
                    "{" +
                    "  name: e.name," +
                    "  duration: e.duration," +
                    "  startTime: e.startTime," +
                    "  method: 'GET/POST'," +
                    "  responseEnd: e.responseEnd," +
                    "  fetchStart: e.fetchStart" +
                    "}" +
                    "))";
            
            Object result = js.executeScript(script);
            if (result instanceof List) {
                List<?> resources = (List<?>) result;
                for (Object resource : resources) {
                    if (resource instanceof Map) {
                        @SuppressWarnings("unchecked")
                        Map<String, Object> resourceMap = (Map<String, Object>) resource;
                        String url = String.valueOf(resourceMap.get("name"));
                        Double duration = ((Number) resourceMap.get("duration")).doubleValue();
                        
                        // Solo registrar APIs y endpoints de Sara3 (no librerías externas)
                        if (url.contains("sara") || url.contains("api") || url.contains("endpoint")) {
                            networkMetrics.put(actionName + " - " + url, 
                                new NetworkMetric(url, duration, System.currentTimeMillis()));
                            
                            System.out.println("  [APP-PERF] Network - " + url + ": " + 
                                String.format("%.0f", duration) + "ms");
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("  [APP-PERF] Warning: No se pudo capturar network timing - " + e.getMessage());
        }
    }
    
    /**
     * MÉTRICA 2: Captura Web Vitals (FCP, LCP, CLS, TTFB)
     * Métrica estándar de performance del navegador
     */
    public void captureWebVitals(String pageIdentifier) {
        try {
            JavascriptExecutor js = (JavascriptExecutor) driver;
            
            // Capturar Core Web Vitals usando Performance API
            String script = 
                "return {" +
                "  fcp: performance.getEntriesByName('first-contentful-paint')[0]?.startTime || 0," +
                "  lcp: (function() {" +
                "    const entries = performance.getEntriesByType('largest-contentful-paint');" +
                "    return entries.length > 0 ? entries[entries.length - 1].renderTime : 0;" +
                "  })()," +
                "  cls: 0," +
                "  ttfb: performance.getEntriesByType('navigation')[0]?.responseEnd || 0," +
                "  domContentLoaded: performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart," +
                "  loadComplete: performance.timing.loadEventEnd - performance.timing.navigationStart" +
                "}";
            
            Object result = js.executeScript(script);
            if (result instanceof Map) {
                @SuppressWarnings("unchecked")
                Map<String, Object> vitals = (Map<String, Object>) result;
                
                double fcp = ((Number) vitals.get("fcp")).doubleValue();
                double lcp = ((Number) vitals.get("lcp")).doubleValue();
                double ttfb = ((Number) vitals.get("ttfb")).doubleValue();
                double domContentLoaded = ((Number) vitals.get("domContentLoaded")).doubleValue();
                double loadComplete = ((Number) vitals.get("loadComplete")).doubleValue();
                
                renderMetrics.put(pageIdentifier + " - FCP", 
                    new RenderMetric("First Contentful Paint", fcp));
                renderMetrics.put(pageIdentifier + " - LCP", 
                    new RenderMetric("Largest Contentful Paint", lcp));
                renderMetrics.put(pageIdentifier + " - TTFB", 
                    new RenderMetric("Time to First Byte", ttfb));
                renderMetrics.put(pageIdentifier + " - DOM Load", 
                    new RenderMetric("DOM Content Loaded", domContentLoaded));
                renderMetrics.put(pageIdentifier + " - Load Complete", 
                    new RenderMetric("Load Complete", loadComplete));
                
                System.out.println("  [APP-PERF] Web Vitals - " + pageIdentifier + ":");
                System.out.println("    FCP: " + String.format("%.0f", fcp) + "ms");
                System.out.println("    LCP: " + String.format("%.0f", lcp) + "ms");
                System.out.println("    DOM Loaded: " + String.format("%.0f", domContentLoaded) + "ms");
            }
        } catch (Exception e) {
            System.out.println("  [APP-PERF] Warning: No se pudo capturar Web Vitals - " + e.getMessage());
        }
    }
    
    /**
     * MÉTRICA 3: Captura JavaScript Execution Time
     * Mide cuánto tiempo tarda JavaScript en ejecutarse (no el test, sino la app)
     */
    public void captureJSExecutionTime(String actionName) {
        try {
            JavascriptExecutor js = (JavascriptExecutor) driver;
            
            // Capturar JS execution time usando PerformanceLongTaskTiming
            String script = 
                "return {" +
                "  jsHeapSizeLimit: performance.memory?.jsHeapSizeLimit || 0," +
                "  jsHeapUsed: performance.memory?.jsHeapUsed || 0," +
                "  jsHeapSizeLimit_mb: (performance.memory?.jsHeapSizeLimit || 0) / 1048576" +
                "}";
            
            Object result = js.executeScript(script);
            if (result instanceof Map) {
                @SuppressWarnings("unchecked")
                Map<String, Object> memory = (Map<String, Object>) result;
                
                double heapUsed = ((Number) memory.get("jsHeapUsed")).doubleValue() / 1048576;
                
                System.out.println("  [APP-PERF] JS Heap - " + actionName + ": " + 
                    String.format("%.2f MB", heapUsed));
            }
        } catch (Exception e) {
            System.out.println("  [APP-PERF] Info: Memory profiling no disponible en este navegador");
        }
    }
    
    /**
     * MÉTRICA 4: Captura API Response Times (endpoints específicos de Sara3)
     */
    public void captureAPIResponseTime(String endpoint, long responseTimeMs) {
        networkMetrics.put("API - " + endpoint, 
            new NetworkMetric(endpoint, (double) responseTimeMs, System.currentTimeMillis()));
        
        System.out.println("  [APP-PERF] API Response - " + endpoint + ": " + responseTimeMs + "ms");
    }
    
    /**
     * MÉTRICA 5: Captura Form Submission Time (cuánto tarda en procesar un formulario)
     */
    public void captureFormSubmissionTime(String formName, long submitTimeMs) {
        networkMetrics.put("Form - " + formName, 
            new NetworkMetric(formName, (double) submitTimeMs, System.currentTimeMillis()));
        
        System.out.println("  [APP-PERF] Form Submission - " + formName + ": " + submitTimeMs + "ms");
    }
    
    /**
     * Genera reporte CSV con TODAS las métricas de performance de la app
     */
    public void generateReport() throws IOException {
        ensureLogDirectory();
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String reportPath = APP_PERF_LOG_DIR + "/" + testName + "_" + timestamp + ".csv";
        
        try (FileWriter writer = new FileWriter(reportPath)) {
            // Encabezado
            writer.append("Tipo,Métrica,Endpoint/Acción,Tiempo_ms,Timestamp\n");
            
            // Network Metrics
            for (Map.Entry<String, NetworkMetric> entry : networkMetrics.entrySet()) {
                NetworkMetric metric = entry.getValue();
                writer.append("NETWORK,Response Time,").append(metric.endpoint).append(",")
                    .append(String.format("%.0f", metric.durationMs)).append(",")
                    .append(String.valueOf(metric.timestamp)).append("\n");
            }
            
            // Render Metrics (Web Vitals)
            for (Map.Entry<String, RenderMetric> entry : renderMetrics.entrySet()) {
                RenderMetric metric = entry.getValue();
                writer.append("RENDER,").append(metric.metricName).append(",")
                    .append(entry.getKey()).append(",")
                    .append(String.format("%.0f", metric.timeMs)).append(",")
                    .append(String.valueOf(System.currentTimeMillis())).append("\n");
            }
            
            // Total test time
            long totalTime = System.currentTimeMillis() - testStartTime;
            writer.append("TOTAL,Test Duration,N/A,").append(String.valueOf(totalTime))
                .append(",").append(String.valueOf(System.currentTimeMillis())).append("\n");
            
            writer.flush();
        }
        
        System.out.println("[APP-PERF] Reporte guardado: " + reportPath);
    }
    
    /**
     * Obtiene resumen de performance de la app
     */
    public String getSummary() {
        StringBuilder sb = new StringBuilder();
        sb.append("\n========== APPLICATION PERFORMANCE SUMMARY ==========\n");
        sb.append("Test: ").append(testName).append("\n");
        
        // Network summary
        if (!networkMetrics.isEmpty()) {
            double avgNetworkTime = networkMetrics.values().stream()
                .mapToDouble(m -> m.durationMs).average().orElse(0);
            long slowestNetwork = Math.round(networkMetrics.values().stream()
                .mapToDouble(m -> m.durationMs).max().orElse(0));
            
            sb.append("\nNetwork Timing:\n");
            sb.append("  Promedio Response: ").append(String.format("%.0f", avgNetworkTime)).append("ms\n");
            sb.append("  Slowest Response: ").append(slowestNetwork).append("ms\n");
            sb.append("  Total Requests: ").append(networkMetrics.size()).append("\n");
        }
        
        // Render summary
        if (!renderMetrics.isEmpty()) {
            Map<String, Double> vitalsByType = new HashMap<>();
            for (RenderMetric metric : renderMetrics.values()) {
                vitalsByType.merge(metric.metricName, metric.timeMs, Math::max);
            }
            
            sb.append("\nWeb Vitals:\n");
            for (Map.Entry<String, Double> entry : vitalsByType.entrySet()) {
                sb.append("  ").append(entry.getKey()).append(": ")
                    .append(String.format("%.0f", entry.getValue())).append("ms\n");
            }
        }
        
        sb.append("======================================================\n");
        return sb.toString();
    }
    
    private void ensureLogDirectory() {
        java.io.File dir = new java.io.File(APP_PERF_LOG_DIR);
        if (!dir.exists()) {
            dir.mkdirs();
        }
    }
    
    // Inner classes
    public static class NetworkMetric {
        String endpoint;
        double durationMs;
        long timestamp;
        
        public NetworkMetric(String endpoint, double durationMs, long timestamp) {
            this.endpoint = endpoint;
            this.durationMs = durationMs;
            this.timestamp = timestamp;
        }
    }
    
    public static class RenderMetric {
        String metricName;
        double timeMs;
        
        public RenderMetric(String metricName, double timeMs) {
            this.metricName = metricName;
            this.timeMs = timeMs;
        }
    }
}
