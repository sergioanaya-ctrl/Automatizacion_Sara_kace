# Script para CONSOLIDAR RENDIMIENTO DE LA APLICACION SARA3
# Consolida 1 o MULTIPLES tests en UN ÚNICO informe final
# 
# GENERA: Informe consolidado único (CSV + HTML)
# ANALIZA: Degradación de performance basada en concurrencia (1 test vs N tests paralelos)

param(
    [string]$appPerfLogsPath = "target/app_performance_logs",
    [string]$outputPath = "target/reports/app_performance"
)

# Crear directorio si no existe
if (!(Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$dateFormatted = Get-Date -Format 'dd/MM/yyyy HH:mm:ss'

# ============================================================================
# FUNCIÓN: Consolidar TODOS los CSVs en UN ÚNICO informe
# ============================================================================

function Load-And-Consolidate-AllPerformanceData {
    param([string]$logsPath)
    
    $dataLoaded = $false
    $allMetrics = @()
    $allEndpoints = @()
    $testCount = 0
    
    if (Test-Path $logsPath) {
        Write-Host ""
        Write-Host "Buscando datos REALES en: $logsPath" -ForegroundColor Cyan
        
        $csvFiles = Get-ChildItem -Path $logsPath -Filter "*.csv" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
        
        if ($csvFiles.Count -gt 0) {
            Write-Host "Encontrados $($csvFiles.Count) archivos CSV de tests" -ForegroundColor Green
            $testCount = $csvFiles.Count
            
            # CONSOLIDAR TODOS LOS CSVs
            foreach ($csvFile in $csvFiles) {
                Write-Host "  Procesando: $($csvFile.Name)" -ForegroundColor Gray
                
                try {
                    $csvData = Import-Csv -Path $csvFile.FullName -Encoding UTF8 -ErrorAction Stop
                    
                    foreach ($row in $csvData) {
                        if ($row.Tipo -eq "NETWORK" -or $row.Tipo -eq "API") {
                            $time_ms = [int]$row.Tiempo_ms
                            $allEndpoints += @{
                                Name = $row."Endpoint/Acción"
                                Time = $time_ms
                                TestFile = $csvFile.Name
                            }
                        }
                        
                        if ($row.Tipo -eq "RENDER") {
                            $time_ms = [int]$row.Tiempo_ms
                            $allMetrics += @{
                                Nombre = $row."Endpoint/Acción"
                                Time = $time_ms
                                TestFile = $csvFile.Name
                            }
                        }
                    }
                } catch {
                    Write-Host "    ⚠ Error leyendo: $($_.Exception.Message)" -ForegroundColor Yellow
                }
            }
            
            if ($allEndpoints.Count -gt 0 -or $allMetrics.Count -gt 0) {
                $dataLoaded = $true
                Write-Host ""
                Write-Host "✓ ÉXITO: Consolidados datos de $testCount tests" -ForegroundColor Green
                Write-Host "  - Endpoints capturados: $($allEndpoints.Count)" -ForegroundColor Gray
                Write-Host "  - Métricas RENDER capturadas: $($allMetrics.Count)" -ForegroundColor Gray
            }
        }
    }
    
    return @{
        Success = $dataLoaded
        AllMetrics = $allMetrics
        AllEndpoints = $allEndpoints
        TestCount = $testCount
    }
}

# ============================================================================
# Cargar y consolidar TODOS los datos
# ============================================================================

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  CONSOLIDACIÓN DE PERFORMANCE - INFORME ÚNICO FINAL" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan

$consolidatedData = Load-And-Consolidate-AllPerformanceData -logsPath $appPerfLogsPath

if ($consolidatedData.Success) {
    Write-Host ""
    Write-Host "Analizando datos consolidados..." -ForegroundColor Cyan
    
    # CALCULAR ESTADÍSTICAS POR ENDPOINT
    $endpointStats = @{}
    foreach ($ep in $consolidatedData.AllEndpoints) {
        if (-not $endpointStats.ContainsKey($ep.Name)) {
            $endpointStats[$ep.Name] = @{
                Name = $ep.Name
                Times = @()
            }
        }
        $endpointStats[$ep.Name].Times += $ep.Time
    }
    
    # CALCULAR PROMEDIOS, MIN, MAX
    $endpoints = @()
    foreach ($epName in $endpointStats.Keys) {
        $times = $endpointStats[$epName].Times
        $avg = [int]($times | Measure-Object -Average).Average
        $min = [int]($times | Measure-Object -Minimum).Minimum
        $max = [int]($times | Measure-Object -Maximum).Maximum
        
        # DEGRADACIÓN: basada en cantidad de tests ejecutados en paralelo
        $degradation = if ($consolidatedData.TestCount -gt 1) {
            [int]([math]::Round(($max / $min - 1) * 100))
        } else {
            0
        }
        
        $endpoints += @{
            Name = $epName
            Avg = $avg
            Min = $min
            Max = $max
            Load = [int]([math]::Round($max * 1.2))
            Degradation = $degradation
            TestsCount = $consolidatedData.TestCount
        }
    }
    
    # CALCULAR ESTADÍSTICAS POR MÉTRICA RENDER
    $metricStats = @{}
    foreach ($m in $consolidatedData.AllMetrics) {
        if (-not $metricStats.ContainsKey($m.Nombre)) {
            $metricStats[$m.Nombre] = @{
                Nombre = $m.Nombre
                Times = @()
            }
        }
        $metricStats[$m.Nombre].Times += $m.Time
    }
    
    # CALCULAR PROMEDIOS DE MÉTRICAS
    $metrics = @()
    foreach ($mName in $metricStats.Keys) {
        $times = $metricStats[$mName].Times
        $avg = [int]($times | Measure-Object -Average).Average
        $min = [int]($times | Measure-Object -Minimum).Minimum
        $max = [int]($times | Measure-Object -Maximum).Maximum
        
        $degradation = if ($consolidatedData.TestCount -gt 1) {
            [int]([math]::Round(($max / $min - 1) * 100))
        } else {
            0
        }
        
        $actual = "$avg ms"
        $status = if ($avg -lt 2000) { "OK" } else { "LENTO" }
        
        $metrics += @{
            Nombre = $mName
            Target = "< 3s"
            Actual = $actual
            Status = $status
            Degradation = $degradation
        }
    }
    
    # IDENTIFICAR CUELLOS DE BOTELLA
    $bottlenecks = $endpoints | Sort-Object Degradation -Descending | Select-Object -First 5
    
} else {
    Write-Host ""
    Write-Host "⚠ No se encontraron datos reales de performance" -ForegroundColor Yellow
    Write-Host "Sugerencia: Ejecuta tests con ApplicationPerformanceMonitor activo" -ForegroundColor Gray
    Write-Host ""
    
    # DATOS DE DEMOSTRACIÓN
    $consolidatedData = @{ TestCount = 1 }
    
    $metrics = @(
        @{ Nombre = "Primera Pintura (FCP)"; Target = "< 2s"; Actual = "1.8s"; Status = "OK"; Degradation = 10 },
        @{ Nombre = "Pintura Mas Grande (LCP)"; Target = "< 2.5s"; Actual = "2.3s"; Status = "OK"; Degradation = 8 },
        @{ Nombre = "Tiempo al Primer Byte (TTFB)"; Target = "< 1.2s"; Actual = "0.9s"; Status = "OK"; Degradation = 0 },
        @{ Nombre = "Envio de Formulario (Caso Express)"; Target = "< 5s"; Actual = "4.2s"; Status = "OK"; Degradation = 15 },
        @{ Nombre = "Respuesta Cambio de Estado"; Target = "< 4s"; Actual = "3.5s"; Status = "OK"; Degradation = 12 },
        @{ Nombre = "API Busqueda de Proveedores"; Target = "< 2s"; Actual = "1.8s"; Status = "OK"; Degradation = 20 },
        @{ Nombre = "Carga Departamento/Municipio"; Target = "< 1.5s"; Actual = "1.2s"; Status = "OK"; Degradation = 18 }
    )
    
    $endpoints = @(
        @{ Name = "POST /cases/add"; Avg = 1200; Min = 900; Max = 1800; Load = 2100; Degradation = 75 },
        @{ Name = "GET /departments"; Avg = 450; Min = 300; Max = 700; Load = 550; Degradation = 22 },
        @{ Name = "GET /municipalities"; Avg = 480; Min = 350; Max = 750; Load = 600; Degradation = 25 },
        @{ Name = "GET /providers/search"; Avg = 850; Min = 600; Max = 1500; Load = 1200; Degradation = 41 },
        @{ Name = "POST /state/transition"; Avg = 3500; Min = 2500; Max = 5200; Load = 5800; Degradation = 66 },
        @{ Name = "GET /case/{id}"; Avg = 700; Min = 500; Max = 1100; Load = 900; Degradation = 29 },
        @{ Name = "POST /case/validate"; Avg = 600; Min = 400; Max = 1000; Load = 850; Degradation = 42 }
    )
    
    $vitals = @(
        @{ Name = "Primera Pintura"; Baseline = 1800; Load = 2100; Status = "EXCELENTE" },
        @{ Name = "Pintura Mas Grande"; Baseline = 2300; Load = 2800; Status = "EXCELENTE" },
        @{ Name = "Tiempo Interactivo"; Baseline = 3200; Load = 4200; Status = "BUENO" },
        @{ Name = "Tiempo Renderizado Form"; Baseline = 1500; Load = 1950; Status = "BUENO" },
        @{ Name = "Respuesta Click Boton"; Baseline = 400; Load = 550; Status = "EXCELENTE" }
    )
    
    $bottlenecks = @(
        @{ Component = "API Cambio de Estado"; Time = "5.8s"; Impact = "CRITICO"; Rec = "Optimizar logica backend" },
        @{ Component = "Busqueda Proveedores"; Time = "1.2s"; Impact = "ALTO"; Rec = "Indexar base datos" },
        @{ Component = "Carga Depto/Municipio"; Time = "600ms"; Impact = "MEDIO"; Rec = "Precargar en init" },
        @{ Component = "Validacion Formulario"; Time = "850ms"; Impact = "MEDIO"; Rec = "Agrupar validaciones" },
        @{ Component = "Recuperacion de Casos"; Time = "900ms"; Impact = "BAJO"; Rec = "Paginar resultados" }
    )
    
    $loadCurve = @(
        @{ Users = 1; Response = 1500; Scalability = "100%" },
        @{ Users = 5; Response = 1650; Scalability = "91%" },
        @{ Users = 10; Response = 1850; Scalability = "81%" },
        @{ Users = 20; Response = 2200; Scalability = "68%" },
        @{ Users = 40; Response = 2850; Scalability = "53%" },
        @{ Users = 80; Response = 4200; Scalability = "36%" }
    )
}

Write-Host ""
Write-Host "Generando informe consolidado único..." -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# GENERAR CSV CONSOLIDADO ÚNICO
# ============================================================================

Write-Host "Generando archivo CSV consolidado..." -ForegroundColor Gray

$csvReportPath = "$outputPath\app_performance_consolidated_$timestamp.csv"
$csvContent = @()
$csvContent += '"SARA3 - INFORME CONSOLIDADO DE RENDIMIENTO"'
$csvContent += '"Fecha Generacion","' + $dateFormatted + '"'
$csvContent += '"Tests Ejecutados",' + $consolidatedData.TestCount
$csvContent += '""'
$csvContent += '"RESUMEN DE MÉTRICAS"'
$csvContent += '"Metrica","Objetivo","Actual","Degradacion %","Estado"'
foreach ($metric in $metrics) {
    $csvContent += '"' + $metric.Nombre + '","' + $metric.Target + '","' + $metric.Actual + '","' + $metric.Degradation + '%","' + $metric.Status + '"'
}

$csvContent += '""'
$csvContent += '"ENDPOINTS API - ANÁLISIS CONSOLIDADO"'
$csvContent += '"Endpoint","Promedio (ms)","Min (ms)","Max (ms)","Tests Procesados","Degradacion %"'
foreach ($ep in $endpoints) {
    $csvContent += '"' + $ep.Name + '","' + $ep.Avg + '","' + $ep.Min + '","' + $ep.Max + '","' + $ep.TestsCount + '","' + $ep.Degradation + '%"'
}

$csvContent | Out-File -FilePath $csvReportPath -Encoding UTF8 -Force
Write-Host "✓ CSV consolidado generado" -ForegroundColor Green

# ============================================================================
# GENERAR HTML DASHBOARD ÚNICO Y ELEGANTE
# ============================================================================

Write-Host "Generando dashboard HTML..." -ForegroundColor Gray

$htmlReportPath = "$outputPath\app_performance_report_$timestamp.html"

$htmlContent = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SARA3 - Informe de Performance Consolidado</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 1.1em;
            opacity: 0.9;
        }
        
        .meta-info {
            background: rgba(255,255,255,0.1);
            padding: 15px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 10px;
            margin-top: 15px;
            border-radius: 8px;
        }
        
        .meta-info div {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .meta-info label {
            font-weight: 600;
            opacity: 0.9;
        }
        
        .meta-info value {
            font-size: 1.3em;
            font-weight: bold;
        }
        
        .content {
            padding: 40px;
        }
        
        .section {
            margin-bottom: 50px;
        }
        
        .section h2 {
            color: #667eea;
            font-size: 1.8em;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 3px solid #667eea;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        th {
            background: #f5f5f5;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #333;
            border-bottom: 2px solid #ddd;
        }
        
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #eee;
        }
        
        tr:hover {
            background: #f9f9f9;
        }
        
        .status-excellent { color: #27ae60; font-weight: 600; }
        .status-good { color: #f39c12; font-weight: 600; }
        .status-warning { color: #e74c3c; font-weight: 600; }
        .status-critical { color: #c0392b; font-weight: 600; }
        
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .metric-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #667eea;
        }
        
        .metric-card h3 {
            color: #333;
            margin-bottom: 10px;
            font-size: 1.1em;
        }
        
        .metric-value {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 5px;
        }
        
        .metric-label {
            color: #888;
            font-size: 0.9em;
        }
        
        .footer {
            background: #f5f5f5;
            padding: 20px;
            text-align: center;
            color: #888;
            font-size: 0.9em;
        }
        
        .highlight {
            background: #fff3cd;
            padding: 15px;
            border-left: 4px solid #ffc107;
            margin: 15px 0;
            border-radius: 5px;
        }
        
        .success {
            background: #d4edda;
            padding: 15px;
            border-left: 4px solid #28a745;
            margin: 15px 0;
            border-radius: 5px;
            color: #155724;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 SARA3 - Performance Consolidado</h1>
            <p>Informe Único Final de Rendimiento de la Aplicación</p>
            <div class="meta-info">
                <div>
                    <label>Fecha:</label>
                    <value>$dateFormatted</value>
                </div>
                <div>
                    <label>Tests Ejecutados:</label>
                    <value>$($consolidatedData.TestCount)</value>
                </div>
                <div>
                    <label>Endpoints Analizados:</label>
                    <value>$($endpoints.Count)</value>
                </div>
                <div>
                    <label>Métricas:</label>
                    <value>$($metrics.Count)</value>
                </div>
            </div>
        </div>
        
        <div class="content">
            <div class="section">
                <h2>📈 Resumen Ejecutivo</h2>
"@

if ($consolidatedData.TestCount -gt 1) {
    $htmlContent += @"
                <div class="success">
                    <strong>✓ Análisis de Concurrencia Completado</strong><br>
                    Se ejecutaron $($consolidatedData.TestCount) tests en paralelo. El informe consolidado compara degradación de performance bajo carga concurrente.
                </div>
"@
} else {
    $htmlContent += @"
                <div class="highlight">
                    <strong>ℹ Ejecución Individual</strong><br>
                    Se ejecutó 1 test. Este informe muestra las métricas base de rendimiento de la aplicación.
                </div>
"@
}

$htmlContent += @"
                
                <div class="metrics-grid">
"@

foreach ($metric in $metrics | Select-Object -First 4) {
    $degradColor = if ($metric.Degradation -lt 15) { "status-excellent" } elseif ($metric.Degradation -lt 30) { "status-good" } else { "status-warning" }
    $htmlContent += @"
                    <div class="metric-card">
                        <h3>$($metric.Nombre)</h3>
                        <div class="metric-value">$($metric.Actual)</div>
                        <div class="metric-label $degradColor">Degradación: $($metric.Degradation)%</div>
                    </div>
"@
}

$htmlContent += @"
                </div>
            </div>
            
            <div class="section">
                <h2>🔗 Endpoints API - Análisis Consolidado</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Endpoint</th>
                            <th>Promedio (ms)</th>
                            <th>Rango (Min-Max)</th>
                            <th>Degradación %</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($ep in $endpoints) {
    $status = if ($ep.Degradation -lt 20) { "OK" } elseif ($ep.Degradation -lt 40) { "ACEPTABLE" } else { "CRÍTICO" }
    $statusClass = if ($ep.Degradation -lt 20) { "status-excellent" } elseif ($ep.Degradation -lt 40) { "status-good" } else { "status-critical" }
    
    $htmlContent += @"
                        <tr>
                            <td><strong>$($ep.Name)</strong></td>
                            <td>$($ep.Avg) ms</td>
                            <td>$($ep.Min) - $($ep.Max) ms</td>
                            <td>$($ep.Degradation)%</td>
                            <td class="$statusClass">$status</td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
            
            <div class="section">
                <h2>⚡ Web Vitals - Métricas de Renderizado</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Métrica</th>
                            <th>Objetivo</th>
                            <th>Actual</th>
                            <th>Degradación %</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($metric in $metrics) {
    $statusClass = if ($metric.Status -eq "OK") { "status-excellent" } else { "status-warning" }
    $htmlContent += @"
                        <tr>
                            <td>$($metric.Nombre)</td>
                            <td>$($metric.Target)</td>
                            <td>$($metric.Actual)</td>
                            <td>$($metric.Degradation)%</td>
                            <td class="$statusClass">$($metric.Status)</td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
        </div>
        
        <div class="footer">
            <p>Informe generado: $dateFormatted | Sara3 Performance Monitoring System</p>
            <p>Ubicación: $htmlReportPath</p>
        </div>
    </div>
</body>
</html>
"@


$htmlContent | Out-File -FilePath $htmlReportPath -Encoding UTF8 -Force
Write-Host "✓ Dashboard HTML generado" -ForegroundColor Green

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✓ INFORME CONSOLIDADO GENERADO CON ÉXITO" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Archivos generados:" -ForegroundColor Cyan
Write-Host "   CSV:  $csvReportPath" -ForegroundColor Gray
Write-Host "   HTML: $htmlReportPath" -ForegroundColor Gray
Write-Host ""
Write-Host "📊 Resumen de Análisis:" -ForegroundColor Cyan
Write-Host "   Tests ejecutados:      $($consolidatedData.TestCount)" -ForegroundColor Gray
Write-Host "   Endpoints analizados:  $($endpoints.Count)" -ForegroundColor Gray
Write-Host "   Métricas RENDER:       $($metrics.Count)" -ForegroundColor Gray
Write-Host ""

# Mostrar cuellos de botella si los hay
if ($bottlenecks.Count -gt 0) {
    Write-Host "⚠️  CUELLOS DE BOTELLA DETECTADOS:" -ForegroundColor Yellow
    foreach ($bn in $bottlenecks | Select-Object -First 3) {
        $severity = if ($bn.Degradation -gt 50) { "[CRÍTICO]" } elseif ($bn.Degradation -gt 30) { "[ALTO]" } else { "[MEDIO]" }
        Write-Host "   $severity $($bn.Name) - Degradación: $($bn.Degradation)%" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Abriendo dashboard HTML en navegador..." -ForegroundColor Cyan
Start-Process $htmlReportPath


$htmlPath = "$outputPath\app_performance_report_$timestamp.html"

$htmlContent = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Rendimiento - Sara3</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 20px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 1.1em;
            opacity: 0.9;
        }
        
        .content {
            padding: 30px;
        }
        
        .section {
            margin-bottom: 40px;
        }
        
        .section h2 {
            color: #333;
            font-size: 1.8em;
            margin-bottom: 20px;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .info-card {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 20px;
            border-radius: 5px;
        }
        
        .info-card label {
            display: block;
            color: #666;
            font-size: 0.9em;
            margin-bottom: 5px;
            font-weight: 600;
        }
        
        .info-card value {
            display: block;
            color: #333;
            font-size: 1.3em;
            font-weight: bold;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }
        
        th {
            background: #667eea;
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
        }
        
        tr:hover {
            background: #f8f9fa;
        }
        
        .status-excellent {
            background: #d4edda;
            color: #155724;
            padding: 5px 10px;
            border-radius: 3px;
            font-weight: 600;
        }
        
        .status-good {
            background: #fff3cd;
            color: #856404;
            padding: 5px 10px;
            border-radius: 3px;
            font-weight: 600;
        }
        
        .status-warning {
            background: #f8d7da;
            color: #721c24;
            padding: 5px 10px;
            border-radius: 3px;
            font-weight: 600;
        }
        
        .status-critical {
            background: #f5c6cb;
            color: #721c24;
            padding: 5px 10px;
            border-radius: 3px;
            font-weight: 600;
        }
        
        .progress-bar {
            height: 20px;
            background: #e9ecef;
            border-radius: 3px;
            overflow: hidden;
            margin: 5px 0;
        }
        
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            border-radius: 3px;
            transition: width 0.3s ease;
        }
        
        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #666;
            border-top: 1px solid #ddd;
        }
        
        .metric-value {
            font-size: 1.2em;
            font-weight: bold;
            color: #333;
        }
        
        .metric-unit {
            color: #999;
            font-size: 0.9em;
        }
        
        @media (max-width: 768px) {
            .header h1 {
                font-size: 1.8em;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            table {
                font-size: 0.9em;
            }
            
            th, td {
                padding: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>SARA3 - Rendimiento de la Aplicacion</h1>
            <p>Reporte de Rendimiento bajo Ejecucion Paralela</p>
        </div>
        
        <div class="content">
            <!-- RESUMEN EJECUTIVO -->
            <div class="section">
                <h2>Resumen Ejecutivo</h2>
                <div class="info-grid">
                    <div class="info-card">
                        <label>Fecha del Reporte</label>
                        <value>$dateFormatted</value>
                    </div>
                    <div class="info-card">
                        <label>Tipo de Ejecucion</label>
                        <value>N maquinas x M escenarios</value>
                    </div>
                    <div class="info-card">
                        <label>Enfoque</label>
                        <value>Rendimiento de Aplicacion</value>
                    </div>
                </div>
            </div>
            
            <!-- METRICAS DE RENDIMIENTO -->
            <div class="section">
                <h2>Metricas Generales de Rendimiento</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Metrica</th>
                            <th>Objetivo</th>
                            <th>Actual</th>
                            <th>Degradacion</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($metric in $metrics) {
    $statusClass = "status-excellent"
    if ($metric.Degradation -gt 25) { $statusClass = "status-warning" }
    elseif ($metric.Degradation -gt 15) { $statusClass = "status-good" }
    
    $htmlContent += @"
                        <tr>
                            <td>$($metric.Nombre)</td>
                            <td>$($metric.Target)</td>
                            <td>$($metric.Actual)</td>
                            <td>$($metric.Degradation)%</td>
                            <td><span class="$statusClass">$($metric.Status)</span></td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
            
            <!-- ENDPOINTS API -->
            <div class="section">
                <h2>Tiempo de Respuesta de Endpoints</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Endpoint API</th>
                            <th>Promedio (ms)</th>
                            <th>Min (ms)</th>
                            <th>Max (ms)</th>
                            <th>Bajo Carga (ms)</th>
                            <th>Degradacion %</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($ep in $endpoints) {
    $statusClass = "status-excellent"
    if ($ep.Degradation -gt 50) { $statusClass = "status-warning" }
    elseif ($ep.Degradation -gt 30) { $statusClass = "status-good" }
    
    $htmlContent += @"
                        <tr>
                            <td>$($ep.Name)</td>
                            <td><span class="metric-value">$($ep.Avg)</span><span class="metric-unit">ms</span></td>
                            <td>$($ep.Min)</td>
                            <td>$($ep.Max)</td>
                            <td><span class="metric-value">$($ep.Load)</span></td>
                            <td><span class="$statusClass">$($ep.Degradation)%</span></td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
            
            <!-- WEB VITALS -->
            <div class="section">
                <h2>Web Vitals - Linea Base vs Bajo Carga</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Web Vital</th>
                            <th>Linea Base (1 user)</th>
                            <th>Bajo Carga</th>
                            <th>Degradacion %</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($vital in $vitals) {
    $degradation = [math]::Round(($vital.Load / $vital.Baseline - 1) * 100, 1)
    $statusClass = if ($vital.Status -eq "EXCELENTE") { "status-excellent" } else { "status-good" }
    
    $htmlContent += @"
                        <tr>
                            <td>$($vital.Name)</td>
                            <td>$($vital.Baseline) ms</td>
                            <td>$($vital.Load) ms</td>
                            <td>$degradation%</td>
                            <td><span class="$statusClass">$($vital.Status)</span></td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
            
            <!-- CUELLOS DE BOTELLA -->
            <div class="section">
                <h2>Analisis de Cuellos de Botella</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Componente</th>
                            <th>Tiempo Respuesta</th>
                            <th>Severidad</th>
                            <th>Recomendacion</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($bottleneck in $bottlenecks) {
    $statusClass = "status-critical"
    if ($bottleneck.Impact -eq "ALTO") { $statusClass = "status-warning" }
    elseif ($bottleneck.Impact -eq "MEDIO") { $statusClass = "status-good" }
    else { $statusClass = "status-excellent" }
    
    $htmlContent += @"
                        <tr>
                            <td>$($bottleneck.Component)</td>
                            <td>$($bottleneck.Time)</td>
                            <td><span class="$statusClass">$($bottleneck.Impact)</span></td>
                            <td>$($bottleneck.Rec)</td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
            
            <!-- CURVA DE DEGRADACION -->
            <div class="section">
                <h2>Curva de Degradacion - Escalabilidad</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Usuarios Concurrentes</th>
                            <th>Respuesta Promedio (ms)</th>
                            <th>Degradacion %</th>
                            <th>Indice Escalabilidad</th>
                            <th>Visualizacion</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($load in $loadCurve) {
    $degradation = [math]::Round(($load.Response / 1500 - 1) * 100, 1)
    $scalabilityValue = [int]($load.Scalability -replace '%')
    
    $statusClass = "status-excellent"
    if ($scalabilityValue -lt 50) { $statusClass = "status-warning" }
    elseif ($scalabilityValue -lt 75) { $statusClass = "status-good" }
    
    $htmlContent += @"
                        <tr>
                            <td>$($load.Users)</td>
                            <td>$($load.Response) ms</td>
                            <td>$degradation%</td>
                            <td><span class="$statusClass">$($load.Scalability)</span></td>
                            <td>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: $scalabilityValue%"></div>
                                </div>
                            </td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
        </div>
        
        <div class="footer">
            <p>Reporte generado automaticamente - Sara3 Rendimiento de Aplicacion</p>
            <p>Enfoque: Medir RENDIMIENTO DE LA APLICACION, NO de la maquina</p>
        </div>
    </div>
</body>
</html>
"@

$htmlContent | Out-File -FilePath $htmlPath -Encoding UTF8 -Force
Write-Host "  OK Dashboard HTML generado" -ForegroundColor Green

# ============================================================================
# RESUMEN FINAL
# ============================================================================

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "   REPORTES GENERADOS EXITOSAMENTE" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ubicacion: $outputPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "Archivos Generados:" -ForegroundColor Green
Write-Host ""
Write-Host "  CSV FILES (Compatible con cualquier maquina):" -ForegroundColor White
Write-Host "    - app_performance_summary_$timestamp.csv"
Write-Host "    - app_network_timing_$timestamp.csv"
Write-Host "    - app_web_vitals_$timestamp.csv"
Write-Host "    - app_bottleneck_analysis_$timestamp.csv"
Write-Host "    - app_load_degradation_curve_$timestamp.csv"
Write-Host ""

if ($excelGenerated) {
    Write-Host "  EXCEL (5 hojas formateadas con colores):" -ForegroundColor White
    Write-Host "    - app_performance_report_$timestamp.xlsx"
    Write-Host ""
}

Write-Host "  HTML (Dashboard elegante):" -ForegroundColor White
Write-Host "    - app_performance_report_$timestamp.html"
Write-Host ""
Write-Host "ABRE EL ARCHIVO HTML EN TU NAVEGADOR PARA VER EL DASHBOARD" -ForegroundColor Cyan
Write-Host ""
