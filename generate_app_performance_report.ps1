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
        Get-ChildItem "$logsPath/*.csv" -ErrorAction SilentlyContinue | ForEach-Object {
            $testCount++
            $csvData = Import-Csv -Path $_.FullName -Encoding UTF8
            
            foreach ($row in $csvData) {
                if ($row.Tipo -eq "NETWORK") {
                    $endpoint = $row."Endpoint/Acción"
                    $tiempo = [int]$row.Tiempo_ms
                    
                    $existing = $allEndpoints | Where-Object { $_.Name -eq $endpoint }
                    if ($existing) {
                        $existing.Times += @($tiempo)
                    } else {
                        $allEndpoints += @{ Name = $endpoint; Times = @($tiempo) }
                    }
                }
                elseif ($row.Tipo -eq "RENDER") {
                    $metric = $row.Metrica
                    $tiempo = [int]$row.Tiempo_ms
                    
                    $existing = $allMetrics | Where-Object { $_.Nombre -eq $metric }
                    if ($existing) {
                        $existing.Times += @($tiempo)
                    } else {
                        $allMetrics += @{ Nombre = $metric; Times = @($tiempo) }
                    }
                }
            }
            $dataLoaded = $true
        }
    }
    
    return @{
        Success = $dataLoaded
        AllMetrics = $allMetrics
        AllEndpoints = $allEndpoints
        TestCount = $testCount
    }
}

# Cargar datos consolidados
Write-Host ""
Write-Host "Cargando y consolidando datos de performance..." -ForegroundColor Cyan
$consolidatedData = Load-And-Consolidate-AllPerformanceData $appPerfLogsPath

if (!$consolidatedData.Success) {
    Write-Host "ERROR: No se encontraron archivos de performance" -ForegroundColor Red
    exit 1
}

# Procesar y calcular estadísticas
$metrics = @()
$endpoints = @()

foreach ($metric in $consolidatedData.AllMetrics) {
    $times = $metric.Times
    if ($times.Count -gt 0) {
        $avg = [math]::Round(($times | Measure-Object -Average).Average, 2)
        $min = [math]::Round(($times | Measure-Object -Minimum).Minimum, 2)
        $max = [math]::Round(($times | Measure-Object -Maximum).Maximum, 2)
        $degradation = if ($min -gt 0) { [math]::Round(($max / $min - 1) * 100, 1) } else { 0 }
        
        $metrics += @{
            Nombre = $metric.Nombre
            Actual = $avg
            Min = $min
            Max = $max
            Degradation = $degradation
        }
    }
}

foreach ($endpoint in $consolidatedData.AllEndpoints) {
    $times = $endpoint.Times
    if ($times.Count -gt 0) {
        $avg = [math]::Round(($times | Measure-Object -Average).Average, 2)
        $min = [math]::Round(($times | Measure-Object -Minimum).Minimum, 2)
        $max = [math]::Round(($times | Measure-Object -Maximum).Maximum, 2)
        $degradation = if ($min -gt 0) { [math]::Round(($max / $min - 1) * 100, 1) } else { 0 }
        
        $endpoints += @{
            Name = $endpoint.Name
            Average = $avg
            Min = $min
            Max = $max
            Degradation = $degradation
        }
    }
}

# Identificar cuellos de botella
$bottlenecks = @()
foreach ($ep in $endpoints) {
    if ($ep.Degradation -gt 10) {
        $bottlenecks += @{
            Name = $ep.Name
            Degradation = $ep.Degradation
            Impact = if ($ep.Degradation -gt 50) { "CRITICO" } elseif ($ep.Degradation -gt 30) { "ALTO" } else { "MEDIO" }
            Rec = "Optimizar llamada a API"
        }
    }
}

$bottlenecks = $bottlenecks | Sort-Object -Property Degradation -Descending

# Curva de degradacion
$loadCurve = @(
    @{ Users = 1; Response = 800; Scalability = "100%" },
    @{ Users = 2; Response = 850; Scalability = "94%" },
    @{ Users = 4; Response = 920; Scalability = "87%" },
    @{ Users = 8; Response = 1100; Scalability = "73%" },
    @{ Users = 10; Response = 1300; Scalability = "62%" }
)

# Generar CSV consolidado
$csvReportPath = "$outputPath/app_performance_consolidated_$timestamp.csv"
$csvContent = "Endpoint API,Promedio (ms),Min (ms),Max (ms),Tests Procesados,Degradacion %`n"
$csvContent += "Tests Ejecutados,$($consolidatedData.TestCount)`n`n"

foreach ($ep in $endpoints) {
    $csvContent += "$($ep.Name),$($ep.Average),$($ep.Min),$($ep.Max),$($consolidatedData.TestCount),$($ep.Degradation)`n"
}

$csvContent | Out-File -FilePath $csvReportPath -Encoding UTF8 -Force
Write-Host "✓ CSV consolidado generado: $csvReportPath" -ForegroundColor Green

# Generar HTML
$htmlReportPath = "$outputPath/app_performance_report_$timestamp.html"

$htmlContent = "<!DOCTYPE html>`r`n"
$htmlContent += "<html lang='es'>`r`n"
$htmlContent += "<head>`r`n"
$htmlContent += "  <meta charset='UTF-8'>`r`n"
$htmlContent += "  <meta name='viewport' content='width=device-width, initial-scale=1.0'>`r`n"
$htmlContent += "  <title>SARA3 - Informe de Performance</title>`r`n"
$htmlContent += "  <style>`r`n"
$htmlContent += "    body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }`r`n"
$htmlContent += "    .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.2); }`r`n"
$htmlContent += "    h1 { color: #667eea; border-bottom: 3px solid #667eea; padding-bottom: 10px; }`r`n"
$htmlContent += "    h2 { color: #667eea; margin-top: 30px; }`r`n"
$htmlContent += "    table { width: 100%; border-collapse: collapse; margin-top: 15px; }`r`n"
$htmlContent += "    th { background: #f0f0f0; padding: 10px; text-align: left; border-bottom: 2px solid #ddd; }`r`n"
$htmlContent += "    td { padding: 10px; border-bottom: 1px solid #ddd; }`r`n"
$htmlContent += "    tr:hover { background: #f9f9f9; }`r`n"
$htmlContent += "    .status-critical { color: #e74c3c; font-weight: bold; }`r`n"
$htmlContent += "    .status-warning { color: #f39c12; font-weight: bold; }`r`n"
$htmlContent += "    .status-good { color: #27ae60; font-weight: bold; }`r`n"
$htmlContent += "    .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; text-align: center; color: #888; font-size: 0.9em; }`r`n"
$htmlContent += "  </style>`r`n"
$htmlContent += "</head>`r`n"
$htmlContent += "<body>`r`n"
$htmlContent += "  <div class='container'>`r`n"
$htmlContent += "    <h1>Performance Consolidado - SARA3</h1>`r`n"
$htmlContent += "    <p>Fecha: $dateFormatted | Tests Ejecutados: $($consolidatedData.TestCount) | Endpoints: $($endpoints.Count)</p>`r`n"
$htmlContent += "    <h2>Resumen de Endpoints</h2>`r`n"
$htmlContent += "    <table>`r`n"
$htmlContent += "      <tr><th>Endpoint</th><th>Promedio (ms)</th><th>Min (ms)</th><th>Max (ms)</th><th>Degradacion</th></tr>`r`n"

foreach ($ep in $endpoints | Sort-Object -Property Average -Descending) {
    $statusClass = if ($ep.Degradation -gt 50) { "status-critical" } elseif ($ep.Degradation -gt 30) { "status-warning" } else { "status-good" }
    $htmlContent += "      <tr><td>$($ep.Name)</td><td>$($ep.Average)</td><td>$($ep.Min)</td><td>$($ep.Max)</td><td class='$statusClass'>$($ep.Degradation)%</td></tr>`r`n"
}

$htmlContent += "    </table>`r`n"

if ($bottlenecks.Count -gt 0) {
    $htmlContent += "    <h2>Cuellos de Botella Detectados</h2>`r`n"
    $htmlContent += "    <table>`r`n"
    $htmlContent += "      <tr><th>Endpoint</th><th>Degradacion</th><th>Impacto</th><th>Recomendacion</th></tr>`r`n"
    
    foreach ($bn in $bottlenecks | Select-Object -First 5) {
        $statusClass = if ($bn.Impact -eq "CRITICO") { "status-critical" } elseif ($bn.Impact -eq "ALTO") { "status-warning" } else { "status-good" }
        $htmlContent += "      <tr><td>$($bn.Name)</td><td>$($bn.Degradation)%</td><td class='$statusClass'>$($bn.Impact)</td><td>$($bn.Rec)</td></tr>`r`n"
    }
    
    $htmlContent += "    </table>`r`n"
}

$htmlContent += "    <div class='footer'>`r`n"
$htmlContent += "      <p>SARA3 Automation Test Suite | Reporte Generado Automaticamente</p>`r`n"
$htmlContent += "    </div>`r`n"
$htmlContent += "  </div>`r`n"
$htmlContent += "</body>`r`n"
$htmlContent += "</html>`r`n"

$htmlContent | Out-File -FilePath $htmlReportPath -Encoding UTF8 -Force
Write-Host "✓ Dashboard HTML generado" -ForegroundColor Green

Write-Host ""
Write-Host "Abriendo dashboard HTML en navegador..." -ForegroundColor Cyan
Start-Process $htmlReportPath

# Generar Excel desde CSV
Write-Host ""
Write-Host "Generando Excel desde CSV..." -ForegroundColor Cyan

. ".\generate_excel_from_csv.ps1"

$excelSuccess = Convert-CsvToExcel -csvPath $csvReportPath -outputPath $outputPath -worksheetName "Performance"

if ($excelSuccess) {
    Write-Host "  OK Excel generado exitosamente" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "INFORME CONSOLIDADO COMPLETADO" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
