# 🚀 Flujo Real de Captura de Rendimiento - Sara3

## Resumen Ejecutivo

Este documento describe cómo Sara3 captura **datos REALES** de rendimiento de la aplicación (no de máquinas) durante la ejecución de tests, y cómo esos datos se transforman en reportes profesionales.

---

## Arquitectura del Flujo

```
┌─────────────────────────────────────────────────────────────────┐
│  TEST EXECUTION (Gradle + Serenity BDD)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CasesRunner01-50                                              │
│  └─ CasesStepDefinitions                                       │
│     ├─ @Before: Inicializa ApplicationPerformanceMonitor       │
│     │                                                           │
│     ├─ elActorTieneUnNavegadorDisponible()                     │
│     │  └─ perfMonitor.setDriver(browser)                       │
│     │                                                           │
│     ├─ abreLaPaginaDeCasos()                                   │
│     │  ├─ perfMonitor.captureWebVitals("OpenCasesPage")       │
│     │  │  ├─ FCP (First Contentful Paint)                      │
│     │  │  ├─ LCP (Largest Contentful Paint)                    │
│     │  │  ├─ TTFB (Time to First Byte)                         │
│     │  │  └─ DOM Load, Load Complete                           │
│     │  └─ perfMonitor.captureNetworkTiming("OpenCasesPage")   │
│     │     └─ Captura todos los recursos vía Performance API    │
│     │                                                           │
│     ├─ realizaLoginConCredenciales()                           │
│     │  └─ perfMonitor.captureAPIResponseTime("POST /login", ms)│
│     │                                                           │
│     ├─ diligenciaCasoExpressConDatosAleatorios()              │
│     │  └─ perfMonitor.captureNetworkTiming("FormSubmission")  │
│     │                                                           │
│     └─ @After: Finaliza captura                               │
│        └─ perfMonitor.generateReport()                         │
│           └─ CSV: target/app_performance_logs/CasesTest_*.csv  │
│                                                                 │
│  ✅ SALIDA: 1 CSV por cada escenario ejecutado                 │
│     Contenido: Tipo,Métrica,Endpoint/Acción,Tiempo_ms         │
└─────────────────────────────────────────────────────────────────┘
         │
         │ (Archivos CSV con datos REALES)
         ▼
┌─────────────────────────────────────────────────────────────────┐
│  REPORT GENERATION (PowerShell)                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  generate_app_performance_report.ps1                           │
│  ├─ Load-RealPerformanceData()                                 │
│  │  ├─ Lee: target/app_performance_logs/*.csv                 │
│  │  ├─ Parsea: Tipo,Métrica,Endpoint,Tiempo_ms               │
│  │  └─ Agrega estadísticas: Min, Max, Avg, Degradation       │
│  │                                                             │
│  ├─ Genera 5 CSV consolidados (UTF-8, español)               │
│  │  ├─ app_performance_summary_*.csv                         │
│  │  ├─ app_network_timing_*.csv                             │
│  │  ├─ app_web_vitals_*.csv                                 │
│  │  ├─ app_bottleneck_analysis_*.csv                        │
│  │  └─ app_load_degradation_curve_*.csv                     │
│  │                                                             │
│  ├─ Genera Excel (si disponible)                             │
│  │  └─ 5 hojas con colores (Verde/Amarillo/Rojo)            │
│  │     basados en degradación %                              │
│  │                                                             │
│  └─ Genera HTML Dashboard                                     │
│     ├─ Responsive design                                      │
│     ├─ Tablas con datos reales                               │
│     ├─ Barras de progreso de escalabilidad                   │
│     └─ Status indicators elegantes                            │
│                                                                 │
│  ✅ SALIDA: target/reports/app_performance/                   │
│     ├─ 5 CSV files (compatibles con cualquier herramienta)   │
│     ├─ 1 XLSX file (5 hojas formateadas)                     │
│     └─ 1 HTML file (dashboard interactivo)                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. FASE 1: Captura en Tests (Java)

### Archivo: `CasesStepDefinitions.java`

**Inicialización:**
```java
private ApplicationPerformanceMonitor perfMonitor;

@Before
public void prepararEscenario() {
    // ... setup Actor y Serenity ...
    perfMonitor = new ApplicationPerformanceMonitor("CasesTest_" + System.currentTimeMillis(), null);
}

@After
public void finalizarEscenario() {
    if (perfMonitor != null && browser != null) {
        perfMonitor.setDriver(browser);
        perfMonitor.captureWebVitals("Final_Page");
        perfMonitor.generateReport();  // ← Genera CSV
    }
}
```

**Captura en Pasos:**
```java
@When("abre la pagina de casos")
public void abreLaPaginaDeCasos() {
    long startTime = System.currentTimeMillis();
    actor.attemptsTo(OpenCasesPage.now());
    long duration = System.currentTimeMillis() - startTime;
    
    if (perfMonitor != null) {
        // Captura WEB VITALS (FCP, LCP, TTFB, DOM Load, etc.)
        perfMonitor.captureWebVitals("OpenCasesPage");
        
        // Captura NETWORK TIMING (todas las requests de la app)
        perfMonitor.captureNetworkTiming("OpenCasesPage");
    }
    System.out.println("[APP-PERF] OpenCasesPage: " + duration + "ms");
}

@When("realiza login con credenciales")
public void realizaLoginConCredenciales() {
    long startTime = System.currentTimeMillis();
    // ... login logic ...
    long duration = System.currentTimeMillis() - startTime;
    
    if (perfMonitor != null) {
        // Captura API RESPONSE TIME específico
        perfMonitor.captureAPIResponseTime("POST /login", duration);
        perfMonitor.captureNetworkTiming("LoginStep");
    }
}
```

### Archivo: `ApplicationPerformanceMonitor.java`

**Qué captura - 5 Capas:**

1. **Web Vitals** (Performance API del navegador)
   ```java
   public void captureWebVitals(String pageIdentifier) {
       // Ejecuta JavaScript en el navegador para obtener:
       // - FCP: First Contentful Paint (tiempo hasta primer contenido)
       // - LCP: Largest Contentful Paint (elemento visual más grande)
       // - TTFB: Time to First Byte (respuesta inicial del servidor)
       // - DOM Content Loaded: DOM listo
       // - Load Complete: Página completamente cargada
   }
   ```

2. **Network Timing** (Recursos reales descargados)
   ```java
   public void captureNetworkTiming(String actionName) {
       // Ejecuta: window.performance.getEntriesByType('resource')
       // Captura TODAS las requests de la aplicación:
       // - APIs de Sara3
       // - Endpoints personalizados
       // - Recursos filtrados (solo sara/api, no librerías externas)
   }
   ```

3. **JavaScript Execution Time**
   ```java
   public void captureJSExecutionTime(String actionName) {
       // Captura memory.jsHeapUsed y heap limits
       // Indica cuánta memoria usa JavaScript
   }
   ```

4. **API Response Times** (Manual)
   ```java
   public void captureAPIResponseTime(String endpoint, long responseTimeMs) {
       // Registra endpoints específicos
       // Ej: POST /cases/add, POST /state/transition
   }
   ```

5. **Form Submission Time**
   ```java
   public void captureFormSubmissionTime(String formName, long submitTimeMs) {
       // Mide cuánto tarda un formulario
   }
   ```

**Salida: CSV en `target/app_performance_logs/`**
```csv
Tipo,Métrica,Endpoint/Acción,Tiempo_ms,Timestamp
NETWORK,Response Time,GET /departments,450,1715400906000
NETWORK,Response Time,POST /login,1200,1715400906100
RENDER,First Contentful Paint,OpenCasesPage,1800,1715400906200
RENDER,Largest Contentful Paint,OpenCasesPage,2300,1715400906300
RENDER,DOM Content Loaded,OpenCasesPage,3200,1715400906400
API,Response Time,POST /cases/add,1500,1715400906500
TOTAL,Test Duration,N/A,45000,1715400906600
```

---

## 2. FASE 2: Generación de Reportes (PowerShell)

### Archivo: `generate_app_performance_report.ps1`

**Flujo de Lectura de Datos Reales:**

```powershell
function Load-RealPerformanceData {
    # 1. Busca archivos CSV más recientes en target/app_performance_logs/
    # 2. Lee el CSV más nuevo (último test ejecutado)
    # 3. Parsea cada fila:
    #    - Si Tipo = "NETWORK" → Agregará a endpoints[]
    #    - Si Tipo = "RENDER" → Agregará a metrics[]
    # 4. Calcula estadísticas:
    #    - Avg = promedio de tiempos
    #    - Min/Max = valores extremos
    #    - Degradation % = (tiempo_paralelo / tiempo_baseline - 1) * 100
    # 5. Retorna arrays con datos REALES
}

# Si Load-RealPerformanceData() retorna datos: USAR DATOS REALES
# Si no encuentra archivos CSV: USAR DATOS DE DEMOSTRACIÓN
```

**Generación de 5 CSV Consolidados:**

```
1. app_performance_summary_*.csv
   Métrica,Objetivo,Actual,Degradacion,Estado
   FCP,<2s,1.8s,10%,OK
   LCP,<2.5s,2.3s,8%,OK
   
2. app_network_timing_*.csv
   Endpoint API,Promedio (ms),Min,Max,Bajo Carga,Degradacion %
   POST /login,1200,900,1800,1700,42%
   GET /departments,450,300,700,550,22%
   
3. app_web_vitals_*.csv
   Web Vital,Linea Base (1 user),Bajo Carga,Degradacion %,Estado
   FCP,1800ms,2100ms,16%,EXCELENTE
   
4. app_bottleneck_analysis_*.csv
   Componente,Tiempo Respuesta,Severidad,Recomendacion
   API Cambio Estado,5.8s,CRITICO,Optimizar logica backend
   
5. app_load_degradation_curve_*.csv
   Usuarios,Respuesta (ms),Degradacion %,Indice Escalabilidad
   1,1500,0%,100%
   10,1850,23%,81%
```

**Generación de Excel (si Office disponible):**
- 5 hojas con datos reales
- Color-coded por degradación:
  - Verde: < 20% degradation
  - Amarillo: 20-35%
  - Rojo: > 35%

**Generación de HTML Dashboard:**
- Tablas responsive con datos reales
- Barras de progreso para escalabilidad
- Status indicators elegantes
- Resumen ejecutivo

---

## 3. Cómo Ejecutar con Datos REALES

### Opción 1: Tests + Reporte Automático

```batch
run_tests.bat
→ Opción 2/4/8/12/50 (ejecutar tests)
   (automáticamente genera ApplicationPerformanceMonitor CSVs)
→ Automáticamente genera reportes con DATOS REALES
```

### Opción 2: Solo Generar Reporte (si ya corrieron tests)

```batch
run_tests.bat
→ Opción 13 (Generar REPORTE DE RENDIMIENTO)
   (Lee CSVs existentes de target/app_performance_logs/)
   (Genera reportes en target/reports/app_performance/)
```

### Opción 3: Ejecutar Script Directamente

```powershell
.\generate_app_performance_report.ps1
```

---

## 4. Verificar que Funciona

### Ubicaciones de Archivos:

**Datos crudos (generados por Java):**
```
target/app_performance_logs/
├── CasesTest_1715400906000_20260511_080906.csv  (DATOS REALES)
├── CasesTest_1715400907000_20260511_081906.csv
└── CasesTest_1715400908000_20260511_082906.csv
```

**Reportes consolidados (generados por PowerShell):**
```
target/reports/app_performance/
├── app_performance_summary_20260511_080906.csv
├── app_network_timing_20260511_080906.csv
├── app_web_vitals_20260511_080906.csv
├── app_bottleneck_analysis_20260511_080906.csv
├── app_load_degradation_curve_20260511_080906.csv
├── app_performance_report_20260511_080906.xlsx   (si Excel disponible)
└── app_performance_report_20260511_080906.html   (ABRE EN NAVEGADOR)
```

---

## 5. Adaptación para Diferentes Escenarios

### Parallelización N×M (flexible)

Gradle puede ejecutar `maxParallelForks` tests simultáneamente:
```gradle
test {
    maxParallelForks = project.hasProperty('maxParallelForks') ? 
        Integer.parseInt(project.getProperty('maxParallelForks')) : 
        8
}
```

Cada test captura sus propias métricas en su CSV:
- 1 máquina, 1 escenario: 1 CSV
- 1 máquina, 5 escenarios: 5 CSVs
- 5 máquinas, 10 escenarios: 50 CSVs

PowerShell consolida TODOS los CSVs automáticamente.

---

## 6. Diferencia: DATOS REALES vs SIMULADOS

### DATOS REALES (del ApplicationPerformanceMonitor):
✅ Mide respuesta REAL de APIs desde el navegador
✅ Captura Web Vitals REALES (FCP, LCP, TTFB)
✅ Refleja comportamiento actual de la aplicación
✅ Detecta cuellos de botella verdaderos
✅ Escalable con N×M máquinas/escenarios

### DATOS SIMULADOS (fallback):
⚠️ Usados solo si NO hay CSVs generados
⚠️ Útil para validar formato de reportes
⚠️ NO refleja rendimiento real
⚠️ Solo para demostración

---

## 7. Próximos Pasos

1. **Compilar y ejecutar tests:**
   ```bash
   ./gradlew build
   .\run_tests.bat → Opción 2 (ejecutar con 2 runners)
   ```

2. **Verificar CSVs generados:**
   ```bash
   dir target/app_performance_logs/
   ```

3. **Abrir HTML en navegador:**
   ```bash
   start target/reports/app_performance/app_performance_report_*.html
   ```

4. **Analizar datos en Excel** (si disponible):
   - Revisar 5 hojas formateadas
   - Identificar cuellos de botella
   - Comparar degradación por volumen

---

## Resumen

| Componente | Ubicación | Función |
|-----------|-----------|---------|
| **ApplicationPerformanceMonitor** | `src/test/java/.../utils/` | Captura datos REALES en tests |
| **CasesStepDefinitions** | `src/test/java/.../stepdefinitions/` | Integra monitor en pasos |
| **generate_app_performance_report.ps1** | Raíz del proyecto | Lee CSVs y genera reportes |
| **CSV input** | `target/app_performance_logs/` | Datos REALES de tests |
| **CSV output** | `target/reports/app_performance/` | 5 reportes consolidados |
| **Excel output** | `target/reports/app_performance/` | Dashboard formateado |
| **HTML output** | `target/reports/app_performance/` | Dashboard interactivo |

---

**Hecho con ❤️ para medir RENDIMIENTO DE LA APLICACION (no de máquinas)**
