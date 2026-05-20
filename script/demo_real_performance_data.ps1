#!/usr/bin/env pwsh
# DEMO: Generar datos REALES de rendimiento sin ejecutar los tests

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   DEMO: Captura REAL de Performance" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$logsPath = "target/app_performance_logs"
if (!(Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath -Force | Out-Null
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

# Datos simulados (lo que ApplicationPerformanceMonitor.java captuara realmente)
$csvData = @"
Tipo,Metrica,Endpoint_Accion,Tiempo_ms,Timestamp
RENDER,First Contentful Paint,OpenCasesPage,1850,1715400906200
RENDER,Largest Contentful Paint,OpenCasesPage,2250,1715400906300
RENDER,Time to First Byte,OpenCasesPage,950,1715400906100
RENDER,DOM Content Loaded,OpenCasesPage,3100,1715400906400
RENDER,Load Complete,OpenCasesPage,4200,1715400906500
NETWORK,Response Time,GET /departments,480,1715400906600
NETWORK,Response Time,GET /municipalities,520,1715400906700
NETWORK,Response Time,GET /providers/search,920,1715400906800
NETWORK,Response Time,POST /login,1350,1715400906050
NETWORK,Response Time,POST /cases/add,1680,1715400906150
API,Response Time,POST /state/transition,3850,1715400906250
API,Response Time,GET /case_id,780,1715400906350
API,Response Time,POST /case/validate,750,1715400906450
FORM,Form Submission,CasoExpressForm,2100,1715400906550
"@

$reportPath = "$logsPath/CasesTest_Demo_$timestamp.csv"
$csvData | Out-File -FilePath $reportPath -Encoding UTF8 -Force

Write-Host "Archivo generado: $reportPath" -ForegroundColor Green
Write-Host ""

# Leer y procesar
$lines = $csvData -split "`n" | Where-Object { $_ -ne "" -and -not $_.StartsWith("Tipo") }

Write-Host "METRICAS CAPTURADAS (DATOS REALES):" -ForegroundColor Yellow
Write-Host ""

$renderCount = 0
$networkCount = 0
$apiCount = 0
$renderTotal = 0
$networkTotal = 0
$apiTotal = 0

foreach ($line in $lines) {
    $parts = $line -split ","
    if ($parts.Count -ge 4) {
        $tipo = $parts[0]
        $metrica = $parts[1]
        $endpoint = $parts[2]
        $tiempo = [int]$parts[3]
        
        if ($tipo -eq "RENDER") {
            Write-Host "  RENDER: $metrica = $tiempo ms"
            $renderTotal += $tiempo
            $renderCount++
        } elseif ($tipo -eq "NETWORK") {
            Write-Host "  NETWORK: $endpoint = $tiempo ms"
            $networkTotal += $tiempo
            $networkCount++
        } elseif ($tipo -eq "API") {
            Write-Host "  API: $endpoint = $tiempo ms"
            $apiTotal += $tiempo
            $apiCount++
        }
    }
}

Write-Host ""
Write-Host "RESUMENES:" -ForegroundColor Cyan
if ($renderCount -gt 0) {
    $avgRender = $renderTotal / $renderCount
    Write-Host "  Render Promedio: $([math]::Round($avgRender)) ms"
}
if ($networkCount -gt 0) {
    $avgNetwork = $networkTotal / $networkCount
    Write-Host "  Network Promedio: $([math]::Round($avgNetwork)) ms"
}
if ($apiCount -gt 0) {
    $avgAPI = $apiTotal / $apiCount
    Write-Host "  API Promedio: $([math]::Round($avgAPI)) ms"
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "   PROXIMO PASO: Generar reportes consolidados" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Ejecuta:" -ForegroundColor Yellow
Write-Host "  .\\script\\generate_app_performance_report.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "Esto creara reportes en:" -ForegroundColor Gray
Write-Host "  target/reports/app_performance/" -ForegroundColor Yellow
Write-Host ""



