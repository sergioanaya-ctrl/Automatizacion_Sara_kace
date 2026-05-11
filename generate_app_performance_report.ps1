# Script para CONSOLIDAR RENDIMIENTO DE LA APLICACION SARA3
# Consolida 1 o MULTIPLES tests en UN ÚNICO informe final

param(
    [string]$appPerfLogsPath = "target/app_performance_logs",
    [string]$outputPath = "target/reports/app_performance"
)

# Importar funciones de utilidad
. ".\report_utilities.ps1"

# Crear directorio si no existe
if (!(Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$dateFormatted = Get-Date -Format 'dd/MM/yyyy HH:mm:ss'

# FUNCIÓN: Consolidar TODOS los CSVs
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

# Cargar datos
Write-Host ""
Write-Host "Cargando y consolidando datos de performance..." -ForegroundColor Cyan
$consolidatedData = Load-And-Consolidate-AllPerformanceData $appPerfLogsPath

if (!$consolidatedData.Success) {
    Write-Host "ERROR: No se encontraron archivos de performance" -ForegroundColor Red
    exit 1
}

# Procesar estadísticas
$metrics = @()
$endpoints = @()

foreach ($metric in $consolidatedData.AllMetrics) {
    $times = $metric.Times
    if ($times.Count -gt 0) {
        $avg = ($times | Measure-Object -Average).Average
        $min = ($times | Measure-Object -Minimum).Minimum
        $max = ($times | Measure-Object -Maximum).Maximum
        $degradation = if ($min -gt 0) { [math]::Round(($max / $min - 1) * 100, 1) } else { 0 }
        
        $metrics += @{
            Nombre = $metric.Nombre
            Actual = $avg
            ActualFormatted = Format-SecondsWithComma -Milliseconds ([int]$avg)
            Min = $min
            MinFormatted = Format-SecondsWithComma -Milliseconds ([int]$min)
            Max = $max
            MaxFormatted = Format-SecondsWithComma -Milliseconds ([int]$max)
            Degradation = $degradation
        }
    }
}

foreach ($endpoint in $consolidatedData.AllEndpoints) {
    $times = $endpoint.Times
    if ($times.Count -gt 0) {
        $avg = ($times | Measure-Object -Average).Average
        $min = ($times | Measure-Object -Minimum).Minimum
        $max = ($times | Measure-Object -Maximum).Maximum
        $degradation = if ($min -gt 0) { [math]::Round(($max / $min - 1) * 100, 1) } else { 0 }
        
        $endpoints += @{
            Name = $endpoint.Name
            Average = $avg
            AverageFormatted = Format-SecondsWithComma -Milliseconds ([int]$avg)
            Min = $min
            MinFormatted = Format-SecondsWithComma -Milliseconds ([int]$min)
            Max = $max
            MaxFormatted = Format-SecondsWithComma -Milliseconds ([int]$max)
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

# Generar CSV
$csvReportPath = "$outputPath/app_performance_consolidated_$timestamp.csv"
$csvContent = "Endpoint API,Promedio (ms),Min (ms),Max (ms),Tests Procesados,Degradacion %`nTests Ejecutados,$($consolidatedData.TestCount)`n`n"

foreach ($ep in $endpoints) {
    $csvContent += "$($ep.Name),$($ep.AverageFormatted),$($ep.MinFormatted),$($ep.MaxFormatted),$($consolidatedData.TestCount),$($ep.Degradation)`n"
}

$csvContent | Out-File -FilePath $csvReportPath -Encoding UTF8 -Force
Write-Host "OK CSV consolidado generado" -ForegroundColor Green

# Generar HTML simple (sin parsing issues)
$htmlReportPath = "$outputPath/app_performance_report_$timestamp.html"
$htmlLines = @(
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
    ".good { color: #27ae60; font-weight: bold; }",
    ".footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; text-align: center; color: #888; font-size: 0.9em; }",
    "</style>",
    "</head>",
    "<body>",
    "<div class='container'>",
    "<h1>Performance Consolidado - SARA3</h1>",
    "<p>Fecha: $dateFormatted | Tests: $($consolidatedData.TestCount) | Endpoints: $($endpoints.Count)</p>",
    "<h2>Resumen de Endpoints</h2>",
    "<table>",
    "<tr><th>Endpoint</th><th>Promedio (ms)</th><th>Min (ms)</th><th>Max (ms)</th><th>Degradacion</th></tr>"
)

foreach ($ep in $endpoints | Sort-Object -Property Average -Descending) {
    $statusClass = if ($ep.Degradation -gt 50) { "critical" } elseif ($ep.Degradation -gt 30) { "warning" } else { "good" }
    $htmlLines += "<tr><td>$($ep.Name)</td><td>$($ep.AverageFormatted)</td><td>$($ep.MinFormatted)</td><td>$($ep.MaxFormatted)</td><td class='$statusClass'>$($ep.Degradation)%</td></tr>"
}

$htmlLines += "</table>"

if ($bottlenecks.Count -gt 0) {
    $htmlLines += "<h2>Cuellos de Botella</h2>"
    $htmlLines += "<table>"
    $htmlLines += "<tr><th>Endpoint</th><th>Degradacion</th><th>Impacto</th><th>Recomendacion</th></tr>"
    
    foreach ($bn in $bottlenecks | Select-Object -First 5) {
        $statusClass = if ($bn.Impact -eq "CRITICO") { "critical" } elseif ($bn.Impact -eq "ALTO") { "warning" } else { "good" }
        $htmlLines += "<tr><td>$($bn.Name)</td><td>$($bn.Degradation)%</td><td class='$statusClass'>$($bn.Impact)</td><td>$($bn.Rec)</td></tr>"
    }
    
    $htmlLines += "</table>"
}

$htmlLines += @(
    "<div class='footer'>",
    "<p>SARA3 Automation Test Suite</p>",
    "</div>",
    "</div>",
    "</body>",
    "</html>"
)

$htmlLines | Out-File -FilePath $htmlReportPath -Encoding UTF8 -Force
Write-Host "OK Dashboard HTML generado" -ForegroundColor Green

Write-Host ""
Write-Host "Abriendo dashboard..." -ForegroundColor Cyan
Start-Process $htmlReportPath

# Generar Excel
Write-Host ""
Write-Host "Generando Excel desde CSV..." -ForegroundColor Cyan

. ".\generate_excel_from_csv.ps1"
$excelSuccess = Convert-CsvToExcel -csvPath $csvReportPath -outputPath $outputPath -worksheetName "Performance"

if ($excelSuccess) {
    Write-Host "  OK Excel generado" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "INFORME CONSOLIDADO COMPLETADO" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
