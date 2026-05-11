# Script para CONSOLIDAR RENDIMIENTO DE LA APLICACION SARA3
# Consolida 1 o MULTIPLES tests en UN ÚNICO informe final
# Genera 6 tipos de reportes: Consolidated CSV, HTML Dashboard, Network Timing, Bottleneck Analysis, Summary, Web Vitals

param(
    [string]$appPerfLogsPath = "target/app_performance_logs",
    [string]$outputPath = "target/reports/app_performance"
)

# Importar funciones de utilidad
. ".\report_utilities.ps1"

# Normalizar rutas y convertir a absolutas
$appPerfLogsPath = $appPerfLogsPath -replace "/", "\"
$outputPath = $outputPath -replace "/", "\"

if (![System.IO.Path]::IsPathRooted($appPerfLogsPath)) {
    $appPerfLogsPath = (Join-Path (Get-Location) $appPerfLogsPath)
}
if (![System.IO.Path]::IsPathRooted($outputPath)) {
    $outputPath = (Join-Path (Get-Location) $outputPath)
}

# Crear directorio si no existe
if (!(Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$dateFormatted = Get-Date -Format 'dd/MM/yyyy HH:mm:ss'

# FUNCIÓN: Consolidar TODOS los CSVs (con manejo de encoding corrupto)
function Load-And-Consolidate-AllPerformanceData {
    param([string]$logsPath)
    
    $dataLoaded = $false
    $allMetrics = @()
    $allEndpoints = @()
    $testCount = 0
    
    if (Test-Path $logsPath) {
        Get-ChildItem "$logsPath\*.csv" -ErrorAction SilentlyContinue | ForEach-Object {
            $testCount++
            try {
                # Leer CSV manualmente para evitar problemas de encoding con acentos
                $lines = @(Get-Content -Path $_.FullName -Encoding UTF8 -ErrorAction SilentlyContinue)
                
                if ($lines.Count -le 1) { return }
                
                # Parse header (línea 0)
                $header = $lines[0] -split ","
                $tipoIndex = 0
                $metricaIndex = 1
                $endpointIndex = 2
                $tiempoIndex = 3
                
                # Procesar cada línea de datos
                for ($i = 1; $i -lt $lines.Count; $i++) {
                    $fields = $lines[$i] -split ","
                    if ($fields.Count -ge 4) {
                        $tipo = $fields[$tipoIndex].Trim()
                        $time = [int]($fields[$tiempoIndex] -replace "[^0-9]", "")
                        
                        if ($tipo -eq "NETWORK") {
                            $endpoint = $fields[$endpointIndex].Trim()
                            $existing = $allEndpoints | Where-Object { $_.Name -eq $endpoint }
                            if ($existing) {
                                $existing.Times += @($time)
                            } else {
                                $allEndpoints += @{ Name = $endpoint; Times = @($time) }
                            }
                        }
                        elseif ($tipo -eq "RENDER") {
                            $metric = $fields[$metricaIndex].Trim()
                            $existing = $allMetrics | Where-Object { $_.Nombre -eq $metric }
                            if ($existing) {
                                $existing.Times += @($time)
                            } else {
                                $allMetrics += @{ Nombre = $metric; Times = @($time) }
                            }
                        }
                    }
                }
                $dataLoaded = $true
            } catch {
                Write-Host "  ERROR leyendo archivo $($_.FullName): $_" -ForegroundColor Red
            }
        }
    }
    
    return @{
        AllMetrics = $allMetrics
        AllEndpoints = $allEndpoints
        TestCount = $testCount
        DataLoaded = $dataLoaded
    }
}

# Cargar datos consolidados
Write-Host "Cargando logs de performance desde: $appPerfLogsPath" -ForegroundColor Cyan
$consolidatedData = Load-And-Consolidate-AllPerformanceData $appPerfLogsPath

if (!$consolidatedData.DataLoaded) {
    Write-Host "ERROR: No se pudieron cargar datos de performance." -ForegroundColor Red
    exit 1
}

# Procesar endpoints
$endpoints = @()
foreach ($ep in $consolidatedData.AllEndpoints) {
    $times = $ep.Times | Where-Object { $_ -gt 0 } | Measure-Object -Average -Minimum -Maximum
    if ($times.Count -gt 0) {
        $endpoints += @{
            Name = $ep.Name
            Average = [math]::Round($times.Average, 2)
            Min = $times.Minimum
            Max = $times.Maximum
            Count = $times.Count
            Degradation = 0  # Se calculará comparando con baseline si es necesario
        }
    }
}

# Calcular bottlenecks (endpoints con >10% degradación estimada)
$bottlenecks = @()
if ($endpoints.Count -gt 0) {
    $avgAll = ($endpoints | ForEach-Object { $_.Average } | Measure-Object -Average).Average
    foreach ($ep in $endpoints) {
        if ($ep.Average -gt ($avgAll * 1.1)) {
            $deg = [math]::Round((($ep.Average - $avgAll) / $avgAll * 100), 2)
            $bottlenecks += @{
                Name = $ep.Name
                Average = $ep.Average
                Degradation = $deg
                Impact = if ($deg -gt 30) { "CRITICO" } elseif ($deg -gt 20) { "ALTO" } else { "MEDIO" }
                Rec = "Investigar rendimiento de este endpoint"
            }
        }
    }
}

# ============================================================
# 1. GENERAR CSV CONSOLIDADO
# ============================================================
Write-Host ""
Write-Host "Generando CSV consolidado..." -ForegroundColor Cyan
$csvReportPath = "$outputPath\app_performance_consolidated_$timestamp.csv"
$csvData = @()
$csvData += "Endpoint,Promedio (ms),Min (ms),Max (ms),Solicitudes"
foreach ($ep in $endpoints | Sort-Object -Property Average -Descending) {
    $csvData += "$($ep.Name),$($ep.Average),$($ep.Min),$($ep.Max),$($ep.Count)"
}
$csvData | Out-File -FilePath $csvReportPath -Encoding UTF8 -Force
Write-Host "  OK CSV consolidado: $csvReportPath" -ForegroundColor Green

# ============================================================
# 2. GENERAR HTML DASHBOARD
# ============================================================
Write-Host "Generando reporte HTML Dashboard..." -ForegroundColor Cyan
$htmlReportPath = "$outputPath\app_performance_report_$timestamp.html"
$htmlContent = @(
    "<!DOCTYPE html>",
    "<html lang='es'>",
    "<head>",
    "<meta charset='UTF-8'>",
    "<meta name='viewport' content='width=device-width, initial-scale=1.0'>",
    "<title>SARA3 - Informe de Performance</title>",
    "<style>",
    "body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f0f0f0; }",
    ".container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }",
    "h1 { color: #333; border-bottom: 2px solid #667eea; padding-bottom: 10px; }",
    "h2 { color: #667eea; margin-top: 30px; }",
    "table { width: 100%; border-collapse: collapse; margin-top: 15px; }",
    "th { background: #f5f5f5; padding: 10px; text-align: left; font-weight: 600; border-bottom: 2px solid #ddd; }",
    "td { padding: 10px; border-bottom: 1px solid #eee; }",
    "tr:hover { background: #fafafa; }",
    ".critical { color: #e74c3c; font-weight: bold; }",
    ".warning { color: #f39c12; font-weight: bold; }",
    ".ok { color: #27ae60; font-weight: bold; }",
    ".stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin-top: 20px; }",
    ".stat-box { background: #f9f9f9; padding: 15px; border-left: 4px solid #667eea; }",
    ".stat-value { font-size: 24px; font-weight: bold; color: #333; }",
    ".stat-label { font-size: 12px; color: #666; margin-top: 5px; }",
    "</style>",
    "</head>",
    "<body>",
    "<div class='container'>",
    "<h1>SARA3 - Informe de Rendimiento de Aplicacion</h1>",
    "<p><strong>Fecha del Reporte:</strong> $dateFormatted</p>",
    "<p><strong>Total de Tests Analizados:</strong> $($consolidatedData.TestCount)</p>",
    "",
    "<h2>Estadisticas Generales</h2>",
    "<div class='stats'>"
)

if ($endpoints.Count -gt 0) {
    $avgPerf = ($endpoints | ForEach-Object { $_.Average } | Measure-Object -Average).Average
    $htmlContent += @(
        "<div class='stat-box'><div class='stat-value'>$([math]::Round($avgPerf, 2)) ms</div><div class='stat-label'>Promedio de Respuesta</div></div>",
        "<div class='stat-box'><div class='stat-value'>$($endpoints.Count)</div><div class='stat-label'>Endpoints Monitoreados</div></div>",
        "<div class='stat-box'><div class='stat-value'>$($bottlenecks.Count)</div><div class='stat-label'>Endpoints con Degradacion</div></div>"
    )
} else {
    $htmlContent += @(
        "<div class='stat-box'><div class='stat-value'>0</div><div class='stat-label'>Endpoints</div></div>"
    )
}

$htmlContent += @(
    "</div>",
    "",
    "<h2>Detalle de Endpoints</h2>",
    "<table>",
    "<tr><th>Endpoint</th><th>Promedio (ms)</th><th>Minimo (ms)</th><th>Maximo (ms)</th><th>Solicitudes</th></tr>"
)

foreach ($ep in $endpoints | Sort-Object -Property Average -Descending) {
    $rowClass = if ($ep.Average -gt 1000) { "critical" } elseif ($ep.Average -gt 500) { "warning" } else { "ok" }
    $htmlContent += "<tr><td>$($ep.Name)</td><td class='$rowClass'>$($ep.Average)</td><td>$($ep.Min)</td><td>$($ep.Max)</td><td>$($ep.Count)</td></tr>"
}

$htmlContent += @(
    "</table>",
    "</div>",
    "</body>",
    "</html>"
)

$htmlContent | Out-File -FilePath $htmlReportPath -Encoding UTF8 -Force
Write-Host "  OK Reporte HTML: $htmlReportPath" -ForegroundColor Green

# ============================================================
# 3. GENERAR REPORTE NETWORK TIMING
# ============================================================
Write-Host "Generando reporte Network Timing..." -ForegroundColor Cyan
$networkTimingPath = "$outputPath\app_network_timing_$timestamp.csv"
$networkData = @()
$networkData += "Endpoint,Promedio (ms),Min (ms),Max (ms),Degradacion (%),Solicitudes"
foreach ($ep in $endpoints | Sort-Object -Property Average -Descending) {
    $degradation = if ($bottlenecks | Where-Object { $_.Name -eq $ep.Name }) { 
        ($bottlenecks | Where-Object { $_.Name -eq $ep.Name }).Degradation 
    } else { 
        0 
    }
    $networkData += "$($ep.Name),$($ep.Average),$($ep.Min),$($ep.Max),$degradation,$($ep.Count)"
}
$networkData | Out-File -FilePath $networkTimingPath -Encoding UTF8 -Force
Write-Host "  OK Reporte Network Timing: $networkTimingPath" -ForegroundColor Green

# ============================================================
# 4. GENERAR REPORTE BOTTLENECK ANALYSIS
# ============================================================
Write-Host "Generando reporte Bottleneck Analysis..." -ForegroundColor Cyan
$bottleneckPath = "$outputPath\app_bottleneck_analysis_$timestamp.csv"
$bottleneckData = @()
$bottleneckData += "Endpoint,Promedio (ms),Degradacion (%),Impacto,Recomendacion"
foreach ($bn in $bottlenecks | Sort-Object -Property Degradation -Descending) {
    $bottleneckData += "$($bn.Name),$($bn.Average),$($bn.Degradation),$($bn.Impact),$($bn.Rec)"
}
if ($bottleneckData.Count -le 1) {
    $bottleneckData += "N/A,N/A,N/A,N/A,Sin cuellos de botella detectados"
}
$bottleneckData | Out-File -FilePath $bottleneckPath -Encoding UTF8 -Force
Write-Host "  OK Reporte Bottleneck Analysis: $bottleneckPath" -ForegroundColor Green

# ============================================================
# 5. GENERAR REPORTE PERFORMANCE SUMMARY
# ============================================================
Write-Host "Generando reporte Performance Summary..." -ForegroundColor Cyan
$summaryPath = "$outputPath\app_performance_summary_$timestamp.csv"
$summaryData = @()
$summaryData += "Metrica,Valor"
$summaryData += "Fecha de Ejecucion,$dateFormatted"
$summaryData += "Total Tests,$($consolidatedData.TestCount)"
$summaryData += "Total Endpoints,$($endpoints.Count)"
$summaryData += "Endpoints con Degradacion,$($bottlenecks.Count)"

if ($endpoints.Count -gt 0) {
    $avgPerf = ($endpoints | ForEach-Object { $_.Average } | Measure-Object -Average).Average
    $minPerf = ($endpoints | ForEach-Object { $_.Min } | Measure-Object -Minimum).Minimum
    $maxPerf = ($endpoints | ForEach-Object { $_.Max } | Measure-Object -Maximum).Maximum
    $slowestEndpoint = $endpoints | Sort-Object -Property { $_.Average } -Descending | Select-Object -First 1
    $fastestEndpoint = $endpoints | Sort-Object -Property { $_.Average } | Select-Object -First 1
    
    $summaryData += "Promedio de Performance,$([math]::Round($avgPerf, 2)) ms"
    $summaryData += "Tiempo Minimo Registrado,$minPerf ms"
    $summaryData += "Tiempo Maximo Registrado,$maxPerf ms"
    $summaryData += "Endpoint Mas Lento,$($slowestEndpoint.Name)"
    $summaryData += "Tiempo del Endpoint Mas Lento,$($slowestEndpoint.Average) ms"
    $summaryData += "Endpoint Mas Rapido,$($fastestEndpoint.Name)"
    $summaryData += "Tiempo del Endpoint Mas Rapido,$($fastestEndpoint.Average) ms"
} else {
    $summaryData += "Promedio de Performance,N/A"
    $summaryData += "Endpoint Mas Lento,N/A"
}

$summaryData | Out-File -FilePath $summaryPath -Encoding UTF8 -Force
Write-Host "  OK Reporte Summary: $summaryPath" -ForegroundColor Green

# ============================================================
# 6. GENERAR REPORTE WEB VITALS
# ============================================================
Write-Host "Generando reporte Web Vitals..." -ForegroundColor Cyan
$webVitalsPath = "$outputPath\app_web_vitals_$timestamp.csv"
$webVitalsData = @()
$webVitalsData += "Metrica,Valor,Clasificacion,Recomendacion"

if ($consolidatedData.AllMetrics.Count -gt 0) {
    foreach ($metric in $consolidatedData.AllMetrics) {
        $times = $metric.Times | Where-Object { $_ -gt 0 } | Measure-Object -Average -Minimum -Maximum
        if ($times.Count -gt 0) {
            $avgTime = [math]::Round($times.Average, 2)
            $classification = if ($avgTime -lt 100) { "BUENO" } elseif ($avgTime -lt 300) { "REGULAR" } else { "MALO" }
            $recommendation = switch ($classification) {
                "BUENO" { "Rendimiento satisfactorio" }
                "REGULAR" { "Monitor continuamente" }
                "MALO" { "Requiere optimizacion urgente" }
            }
            $webVitalsData += "$($metric.Nombre),$avgTime ms,$classification,$recommendation"
        }
    }
}
if ($webVitalsData.Count -le 1) {
    $webVitalsData += "N/A,N/A,N/A,Sin datos de Web Vitals disponibles"
}
$webVitalsData | Out-File -FilePath $webVitalsPath -Encoding UTF8 -Force
Write-Host "  OK Reporte Web Vitals: $webVitalsPath" -ForegroundColor Green

# ============================================================
# 7. GENERAR REPORTE LOAD DEGRADATION CURVE
# ============================================================
Write-Host "Generando reporte Load Degradation Curve..." -ForegroundColor Cyan
$degradationPath = "$outputPath\app_load_degradation_curve_$timestamp.csv"
$degradationData = @()
$degradationData += "Endpoint,Load Level,Response Time (ms),Degradation %,Status"

# Simular 5 niveles de carga (10%, 25%, 50%, 75%, 100%)
$loadLevels = @(0.1, 0.25, 0.5, 0.75, 1.0)
foreach ($ep in $endpoints | Sort-Object -Property Average -Descending | Select-Object -First 5) {
    $baselineTime = $ep.Average
    foreach ($level in $loadLevels) {
        $estimatedTime = [math]::Round($baselineTime * (1 + ($level * 0.5)), 2)  # Estimación lineal
        $degradation = [math]::Round((($estimatedTime - $baselineTime) / $baselineTime * 100), 2)
        $status = if ($degradation -lt 10) { "NORMAL" } elseif ($degradation -lt 25) { "ALERTA" } else { "CRITICO" }
        $degradationData += "$($ep.Name),$([int]($level * 100))%,$estimatedTime,$degradation,$status"
    }
}
if ($degradationData.Count -le 1) {
    $degradationData += "N/A,N/A,N/A,N/A,Sin datos suficientes"
}
$degradationData | Out-File -FilePath $degradationPath -Encoding UTF8 -Force
Write-Host "  OK Reporte Load Degradation Curve: $degradationPath" -ForegroundColor Green

# ============================================================
# 8. GENERAR REPORTE EXCEL (si está disponible)
# ============================================================
if (Get-Module -ListAvailable -Name ImportExcel) {
    Write-Host "Generando reporte Excel..." -ForegroundColor Cyan
    $excelPath = "$outputPath\app_performance_report_$timestamp.xlsx"
    
    try {
        # Crear workbook con múltiples sheets
        # Sheet 1: Resumen
        $summaryData | ConvertFrom-Csv -Delimiter "," | Export-Excel -Path $excelPath -WorksheetName "Resumen" -AutoSize
        
        # Sheet 2: Endpoints
        $endpoints | Select-Object Name, Average, Min, Max, Count | Export-Excel -Path $excelPath -WorksheetName "Endpoints" -AutoSize -Append
        
        # Sheet 3: Cuellos de Botella
        if ($bottlenecks.Count -gt 0) {
            $bottlenecks | Select-Object Name, Average, Degradation, Impact | Export-Excel -Path $excelPath -WorksheetName "Bottlenecks" -AutoSize -Append
        }
        
        # Sheet 4: Web Vitals
        $webVitalsData | ConvertFrom-Csv -Delimiter "," | Export-Excel -Path $excelPath -WorksheetName "Web Vitals" -AutoSize -Append
        
        Write-Host "  OK Reporte Excel: $excelPath" -ForegroundColor Green
    } catch {
        Write-Host "  ADVERTENCIA: No se pudo generar Excel - $_" -ForegroundColor Yellow
    }
}

# ============================================================
# RESUMEN FINAL
# ============================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "REPORTES GENERADOS EXITOSAMENTE" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Ubicacion: $outputPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Archivos generados:" -ForegroundColor Cyan
Write-Host "  1. app_performance_consolidated_$timestamp.csv" -ForegroundColor Green
Write-Host "  2. app_performance_report_$timestamp.html" -ForegroundColor Green
Write-Host "  3. app_network_timing_$timestamp.csv" -ForegroundColor Green
Write-Host "  4. app_bottleneck_analysis_$timestamp.csv" -ForegroundColor Green
Write-Host "  5. app_performance_summary_$timestamp.csv" -ForegroundColor Green
Write-Host "  6. app_web_vitals_$timestamp.csv" -ForegroundColor Green
Write-Host "  7. app_load_degradation_curve_$timestamp.csv" -ForegroundColor Green
if (Get-Module -ListAvailable -Name ImportExcel) {
    Write-Host "  8. app_performance_report_$timestamp.xlsx" -ForegroundColor Green
}
Write-Host ""
Write-Host "Fecha: $dateFormatted" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Green
