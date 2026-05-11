# SARA3 Application Performance Testing Strategy
## Ejecución Paralela Escalable: N máquinas × M scenarios

> **🎯 OBJETIVO: Medir PERFORMANCE DE LA APLICACIÓN Sara3 bajo carga paralela**

> **Flexible:** 2 máquinas × 4 tests = 8 paralelos | 5 máquinas × 5 tests = 25 paralelos | 10 máquinas × 4 tests = 40 paralelos

---

## 📊 Visión General

Para medir cómo responde el **frontend de Sara3** bajo carga paralela, te propongo una estrategia **5-capa** que captura métricas 100% de la aplicación:

```
┌─────────────────────────────────────────────────────────────┐
│ LAYER 1: Web Vitals (FCP, LCP, TTFB, CLS)                   │
│   Métricas estándar del navegador sobre rendering            │
│   Target: FCP < 2s, LCP < 2.5s incluso bajo carga paralela  │
├─────────────────────────────────────────────────────────────┤
│ LAYER 2: Step Performance (Network + JavaScript timing)      │
│   Cada step del test (Login, Navigate, Fill Form, etc.)      │
│   Captura: Tiempo real desde app, no del test               │
├─────────────────────────────────────────────────────────────┤
│ LAYER 3: API Response Times (Endpoints de Sara3)            │
│   POST /cases/add, POST /state/transition, GET /providers    │
│   Medición: Request completion desde API                     │
├─────────────────────────────────────────────────────────────┤
│ LAYER 4: Network Timing (Latencia, Throughput)              │
│   Connection time, request time, response time               │
│   Cómo afecta la latencia bajo carga paralela                │
├─────────────────────────────────────────────────────────────┤
│ LAYER 5: Load Degradation (Scalability)                      │
│   Cómo responde la app con 1 usuario vs N×M usuarios         │
│   Degradation Curve: Scalability Index >= 50% (objetivo)    │
└─────────────────────────────────────────────────────────────┘

🔴 IMPORTANTE: NO medimos CPU/RAM de la máquina test
🟢 ENFOQUE: Response times reales de la APLICACIÓN Sara3
```

---

## 🛠️ Componentes Implementados

### 1. **ApplicationPerformanceMonitor.java** 
Clase Java que captura **performance de la APP Sara3** automáticamente:

```java
// Uso en tus tests:
ApplicationPerformanceMonitor appMonitor = new ApplicationPerformanceMonitor("CasesRunner01", driver);

// MÉTRICA 1: Capturar Web Vitals (FCP, LCP, TTFB)
appMonitor.captureWebVitals("After Login");
appMonitor.captureWebVitals("Agent Section");
appMonitor.captureWebVitals("Form Rendered");

// MÉTRICA 2: Capturar Network Timing (endpoints de la app)
appMonitor.captureNetworkTiming("During Caso Express");

// MÉTRICA 3: Capturar JavaScript Execution
appMonitor.captureJSExecutionTime("Form Validation");

// MÉTRICA 4: Capturar API Response específica
appMonitor.captureAPIResponseTime("POST /cases/add", 1200);  // ms

// MÉTRICA 5: Capturar Form Submission Time
appMonitor.captureFormSubmissionTime("Caso Express", 4200);  // ms

// Generar reporte
appMonitor.generateReport();  // → target/app_performance_logs/{testName}_{timestamp}.csv

// Ver resumen
System.out.println(appMonitor.getSummary());
```

**Output:** CSV con TODAS las métricas de la app

```
Tipo,Métrica,Endpoint/Acción,Tiempo_ms,Timestamp
NETWORK,Response Time,POST /cases/add,1200,1715420000000
NETWORK,Response Time,GET /providers/search,850,1715420002000
RENDER,First Contentful Paint,After Login,1800,1715420003000
RENDER,Largest Contentful Paint,After Login,2300,1715420004000
RENDER,Time to First Byte,After Login,900,1715420005000
TOTAL,Test Duration,N/A,8500,1715420010000
```

---

### 2. **generate_app_performance_report.ps1**
Script PowerShell que **agrega datos de 40 tests** y genera Excel con **5 hojas**:

**Hoja 1: App Performance Summary**
- Resumen de métricas generales
- FCP, LCP, TTFB, Form Submission, State Transition
- Status: ✓ OK o ⚠ WARNING

**Hoja 2: Network Timing**
- Response time de cada endpoint (POST /cases/add, GET /departments, etc.)
- Comparación: Baseline vs Under Load
- Degradation % (cómo empeora bajo carga)

**Hoja 3: Web Vitals Under Load**
- FCP, LCP, TTI con 1 usuario vs 40 usuarios paralelos
- Degradation % esperado vs actual
- Color coding: Green (< 20%), Yellow (20-35%), Red (> 35%)

**Hoja 4: Bottleneck Analysis**
- Componentes más lentos de la app
- Impacto en los tests
- Recomendaciones de optimización

**Hoja 5: Load Degradation Curve**
- Cómo escala la app con 1, 5, 10, 20, 40, 80 usuarios
- Scalability Index: 100% (baseline) → degradación progresiva

**Uso:**
```powershell
.\generate_app_performance_report.ps1 -appPerfLogsPath "target/app_performance_logs"
# Output: target\reports\app_performance_report_20260511_143022.xlsx
```

---

### 3. **PERFORMANCE_TESTING_STRATEGY.json**
Documento técnico detallado (5 layers) con:
- Definición de cada métrica de la APP
- Targets de performance esperado
- Método de recolección (Chrome DevTools Protocol)
- Criterios de éxito (Scalability >= 50%)

---

## 📋 Workflow Recomendado

### **FASE 1: Pre-Testing Setup** ✓

En CADA una de las 10 máquinas:

```powershell
# 1. Sincronizar reloj
w32tm /resync /force

# 2. Limpiar reports previos
.\clean_reports.bat

# 3. Asegurar conectividad a Sara3
ping [servidor-sara3]

# 4. Verificar que WebDriver va a Chrome (para capturar métricas)
# Verificar en serenity.conf: browser=chrome
```

---

### **FASE 2: Execution (Durante Tests)** 🚀

En cada máquina, ejecutar M scenarios con ApplicationPerformanceMonitor activado:

```batch
# Ejecutar M tests en paralelo (N máquinas x M = Total paralelos)
# Ejemplo: 4 tests en paralelo
gradle test -Dcucumber.filter.tags="@batch1 or @batch2 or @batch3 or @batch4" \
            -DmaxParallelForks=4

# O personalizar: 5 tests en paralelo
gradle test -Dcucumber.filter.tags="@batch1 or @batch2 or @batch3 or @batch4 or @batch5" \
            -DmaxParallelForks=5
```

**Lo que sucede automáticamente:**
- ApplicationPerformanceMonitor captura Web Vitals (FCP, LCP, TTFB)
- Captura Network Timing de TODOS los endpoints Sara3
- Captura API Response Times (POST /cases/add, POST /state/transition, etc.)
- Genera CSV: `target/app_performance_logs/{testName}_{timestamp}.csv`
- Serenity genera reports HTML normales

---

### **FASE 3: Post-Testing Analysis** 📊

Después de que terminan los tests (N×M paralelos):

```powershell
# 1. Generar reporte agregado (en máquina central o local)
.\generate_app_performance_report.ps1 -appPerfLogsPath "target/app_performance_logs"

# Output: target\reports\app_performance_report_20260511_143022.xlsx
```

**Analizar las 5 hojas Excel:**
1. **Summary** → Métricas generales ¿OK?
2. **Network Timing** → Endpoints rápidos/lentos
3. **Web Vitals Under Load** → Cómo degrada con parallelismo
4. **Bottleneck Analysis** → Dónde está el cuello de botella
5. **Load Degradation** → Scalability Index (¿50% o más?)

---

## 🎯 Key Metrics por Layer

### **LAYER 1 - Web Vitals (Navegador)**
| Métrica | Baseline | Under 40 Load | Target Degradation |
|---------|----------|---------------|-------------------|
| First Contentful Paint (FCP) | 1.8s | 2.1s | < 20% |
| Largest Contentful Paint (LCP) | 2.3s | 2.8s | < 25% |
| Time to First Byte (TTFB) | 0.9s | 1.1s | < 25% |

### **LAYER 2 - Step Performance (de la APP)**
| Step | Baseline | Under Load | Target |
|------|----------|-----------|--------|
| Login to Sara3 | 1.8s | 2.2s | < 3s |
| Navigate to Agent | 1.2s | 1.5s | < 2s |
| Fill Form - Caso Express | 2.8s | 3.8s | < 4.5s |

### **LAYER 3 - API Response Times (Endpoints)**
| Endpoint | Baseline | Under 40 Load | Target Degradation |
|----------|----------|---------------|-------------------|
| POST /cases/add | 1.2s | 2.1s | < 80% |
| POST /state/transition | 3.5s | 5.8s | < 70% |
| GET /providers/search | 0.85s | 1.2s | < 45% |
| GET /departments | 0.45s | 0.55s | < 25% |
| GET /municipalities | 0.48s | 0.60s | < 30% |

### **LAYER 4 - Network Timing (Latencia)**
| Métrica | Target | Medición |
|---------|--------|----------|
| Connection Time | < 500ms | Per request |
| Request Time | < 200ms | Per endpoint |
| Response Time | Variable | By endpoint |

### **LAYER 5 - Load Degradation / Scalability**

La tabla se genera dinámicamente según carga. Ejemplo con 40 usuarios paralelos:

| Concurrent Users | Avg Response | Scalability Index | Status |
|-----------------|--------------|-------------------|--------|
| 1 user | 1500ms | 100% | Baseline |
| 5 users | 1650ms | 91% | ✓ Good |
| 10 users | 1850ms | 81% | ✓ Good |
| 20 users | 2200ms | 68% | ○ OK |
| **40 users** | **2850ms** | **53%** | ✓ Acceptable |
| 80 users | 4200ms | 36% | ⚠ Warning |

**Interpretación:**
- **Scalability Index = (1-user response time) / (N-user response time) × 100%**
- **Objetivo: >= 50%** (La app mantiene al menos 50% de velocidad incluso bajo carga N×M)
- **< 30%:** Crítico - App no escala

---

## 🔍 Cómo Identificar Bottlenecks

### **Escenario 1: Endpoint devuelve 5800ms bajo carga (POST /state/transition)**
```
Síntoma: "Fill Form - Basic Data" promedia 3200ms
→ Culpable likely: API de autocomplete lenta
→ Solución: Optimizar backend API, agregar caché
```

### **Escenario 2: Performance degrada bajo paralelismo**
```
Síntoma: 1 máquina = 2s/step, 10 máquinas = 3.5s/step
→ Culpable likely: Contention en base de datos o servidor
→ Solución: Aumentar maxConnections DB, horizontal scaling
```

### **Escenario 3: CPU saturado**
```
Síntoma: CPU > 95% mientras tests corren
→ Culpable likely: maxParallelForks muy alto o JavaScript intenso
→ Solución: Reducir maxParallelForks, optimizar JS en frontend
```

Síntoma: POST /state/transition responde en 5.8s bajo 40 usuarios concurrentes
→ Causa: Backend API lento bajo carga (DB connection pool agotado)
→ Solución: Optimizar query, agregar índices, aumentar connection pool
```

### **Escenario 2: Web Vitals degradan > 30%**
```
Síntoma: LCP sube de 2.3s (1 user) a 3.5s (40 users) = 52% degradation
→ Causa: JavaScript execution lentoagregando elementos al DOM
→ Solución: Lazy load, virtualizar listas, optimizar reconciliación React
```

### **Escenario 3: GET /departments responde rápido pero otros endpoints no**
```
Síntoma: Algunos endpoints escalan bien (GET) pero otros no (POST)
→ Causa: POST usa transacciones DB costosas
→ Solución: Batch inserts, async processing, caching de lecturas
```

### **Escenario 4: Scalability Index cae debajo de 50% con 40 usuarios**
```
Síntoma: Scalability = 45% (velocidad se reduce 55% con 40x carga)
→ Causa: App no está diseñada para alta concurrencia
→ Solución: Horizontal scaling, session management optimizado, circuit breakers
```

---

## 📈 Próximos Pasos

### **Integración Inmediata:**
1. ✅ Copiar `ApplicationPerformanceMonitor.java` al proyecto
2. ✅ Integrar en tus test runners (CasesRunner01-50)
3. ✅ Ejecutar `generate_app_performance_report.ps1` después de tests
4. ✅ Revisar Excel de 5 hojas para identificar bottlenecks

### **Implementación en Tests:**
```java
// En tus runners (ej: CasesRunner01.java)
@RunWith(SerenityRunner.class)
@CucumberOptions(...)
public class CasesRunner01 {
    
    @Before
    public void setupPerformanceMonitoring() {
        // Inicializar app perf monitor
        ApplicationPerformanceMonitor monitor = 
            new ApplicationPerformanceMonitor("CasesRunner01", driver);
    }
}
```

### **Optimizaciones Futuras:**
1. Capturar Core Web Vitals con Web Vitals SDK
2. Dashboard real-time durante ejecución (websocket)
3. Integrar con Prometheus/Grafana para histórico
4. Alertas automáticas si Scalability < 50%

---

## 📞 Support

**Preguntas frecuentes:**

**P: ¿Por qué 5 layers si solo mido la APP?**
A: Cada layer aísla una dimensión:
- Layer 1 (Web Vitals) = Cómo percibe el usuario la velocidad
- Layer 2 (Step Performance) = Tiempo de cada interacción
- Layer 3 (API Response) = Response time de cada endpoint
- Layer 4 (Network Timing) = Cómo afecta la latencia
- Layer 5 (Scalability) = Cómo escala bajo carga

**P: ¿Dónde ve el bottleneck más rápido?**
A: **Layer 3 (API Response Times)** - Si POST /state/transition es lento, eso es el cuello. Si es red, Layer 4 lo muestra.

**P: ¿Qué es Scalability Index?**
A: % de performance que mantiene bajo carga. 100% = baseline, 50% = mantiene mitad velocidad, < 50% = crítico.

**P: ¿Necesito capturar esto en cada test?**
A: SÍ - Cada ejecución de los 40 tests genera un CSV. Luego los agrega en Excel. Esto detecta si performance varía día a día.

---

## 📄 Archivos Creados

| Archivo | Propósito |
|---------|-----------|
| `ApplicationPerformanceMonitor.java` | Captura de Web Vitals, Network Timing, API responses |
| `generate_app_performance_report.ps1` | Agregación de 40 tests → Excel de 5 hojas |
| `PERFORMANCE_TESTING_STRATEGY.json` | Documento técnico de 5 layers |
| `PERFORMANCE_TESTING_README.md` | Esta guía |

---

## 🎬 Quick Start (Flexible)

```bash
# Opción 1: Prueba pequeña (2 máquinas × 2 tests = 4 paralelos)
gradle test -Dcucumber.filter.tags="@batch1 or @batch2" -DmaxParallelForks=2
.\generate_app_performance_report.ps1

# Opción 2: Prueba mediana (5 máquinas × 4 tests = 20 paralelos)
gradle test -Dcucumber.filter.tags="@batch1 or @batch2 or @batch3 or @batch4" -DmaxParallelForks=4
.\generate_app_performance_report.ps1

# Opción 3: Prueba grande (10 máquinas × 5 tests = 50 paralelos)
gradle test -Dcucumber.filter.tags="@batch1 or @batch2 or @batch3 or @batch4 or @batch5" -DmaxParallelForks=5
.\generate_app_performance_report.ps1

# 3. Abrir Excel con resultados
start target\reports\app_performance_report_*.xlsx
```

**Analiza las 5 hojas y ajusta tu app basado en los hallazgos!**

