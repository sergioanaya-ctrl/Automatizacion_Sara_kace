#!/usr/bin/env powershell
# Script para generar reportes de detalles de pasos (Excel, CSV, HTML)
# Extrae datos de Serenity JSON y JUnit XML
# Genera Excel con COM API (funciona con Excel y LibreOffice)

param(
    [string]$serenityReportPath = ".\target\site\serenity",
    [string]$junitPath = ".\build\test-results\test",
    [string]$outputPath = ".\target\reports"
)

# Crear directorio de salida
if (-not (Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$machineName = $env:COMPUTERNAME
$userName = $env:USERNAME

# ===== FUNCIONES UTILITARIAS =====

function Get-ErrorType {
    param([string]$errorMessage)
    
    $patterns = @{
        "Selenium" = @("selenium", "webdriver", "driver executable", "session not created", "cannot start", "chrome not reachable", "invalid session id");
        "UI" = @("nosuchelement", "element not found", "not visible", "not interactable", "stale element", "timeout", "field not", "combo", "selector not found", "invisible");
        "Data" = @("illegalargumentexception", "not a valid", "missing value", "required value", "no se encontro", "null reference");
        "Validacion" = @("assert", "assertion", "expected but was", "comparison failed");
    }
    
    foreach ($category in $patterns.GetEnumerator()) {
        foreach ($pattern in $category.Value) {
            if ($errorMessage -like "*$pattern*") {
                return $category.Key
            }
        }
    }
    
    return "Otros"
}

function Extract-TestSteps {
    param([array]$jsonData)
    
    $steps = @()
    
    foreach ($result in $jsonData) {
        $testName = $result.title
        $batch = "N/A"
        if ($result.tags) {
            foreach ($tag in $result.tags) {
                if ($tag -match "batch") {
                    $batch = $tag
                    break
                }
            }
        }
        
        $testSteps = $result.testSteps
        if ($null -eq $testSteps) { $testSteps = @() }
        
        foreach ($step in $testSteps) {
            $errorMessage = ""
            $errorType = ""
            
            if ($step.result -eq "ERROR") {
                $errorMessage = if ($step.error) { $step.error } elseif ($step.exception) { $step.exception } else { "" }
                $errorType = Get-ErrorType $errorMessage
            }
            
            $steps += [PSCustomObject]@{
                Test = $testName
                Batch = $batch
                Descripcion = $step.description
                Accion = $step.action
                Elemento = $step.element
                Valor = $step.value
                Nivel = $step.level
                Tiempo_ms = $step.duration
                Tiempo_s = [math]::Round($step.duration / 1000, 2)
                Estado = if ($step.result -eq "SUCCESS") { "SUCCESS" } elseif ($step.result -eq "ERROR") { "ERROR" } else { "SKIPPED" }
                ErrorType = $errorType
                ErrorMessage = $errorMessage
            }
        }
    }
    
    return $steps
}

# ===== CARGAR DATOS =====

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Generando reportes de detalles de pasos" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Cargar JSON de Serenity
$jsonFiles = Get-ChildItem -Path $serenityReportPath -Filter "*.json" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "index" }
$allSteps = @()

foreach ($jsonFile in $jsonFiles) {
    $jsonContent = Get-Content $jsonFile.FullName | ConvertFrom-Json
    $steps = Extract-TestSteps @($jsonContent)
    $allSteps += $steps
}

if ($allSteps.Count -eq 0) {
    Write-Host "No se encontraron datos. Asegúrate de ejecutar los tests primero." -ForegroundColor Yellow
    exit 1
}

# ===== GENERAR CSV =====

$csvPath = "$outputPath\step_details_$timestamp.csv"
$csvLines = @('"Test","Batch","Maquina","Usuario","Descripcion","Accion","Elemento","Valor","Nivel","Tiempo (ms)","Tiempo (s)","Estado","Error Type","Error Message"')

foreach ($step in $allSteps) {
    $desc = $step.Descripcion -replace '"', '""'
    $errorMsg = $step.ErrorMessage -replace '"', '""'
    $errorType = if($step.Estado -eq "ERROR") { $step.ErrorType } else { "" }
    $errorMsg = if($step.Estado -eq "ERROR") { $errorMsg } else { "" }
    
    $line = @(
        "`"$($step.Test)`""
        "`"$($step.Batch)`""
        "`"$machineName`""
        "`"$userName`""
        "`"$desc`""
        "`"$($step.Accion)`""
        "`"$($step.Elemento)`""
        "`"$($step.Valor)`""
        "$($step.Nivel)"
        "$($step.Tiempo_ms)"
        "$($step.Tiempo_s)"
        "`"$($step.Estado)`""
        "`"$errorType`""
        "`"$errorMsg`""
    ) -join ","
    
    $csvLines += $line
}

$csvLines | Out-File -FilePath $csvPath -Encoding UTF8
Write-Host "CSV generado: $csvPath" -ForegroundColor Green

# ===== GENERAR HTML =====

$htmlPath = "$outputPath\step_details_$timestamp.html"

$html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SARA3 - Reporte de Pasos</title>
    <style>
        body { font-family: Arial; margin: 20px; background-color: #f5f5f5; }
        .header { background: linear-gradient(135deg, #0078d4, #106ebe); color: white; padding: 20px; border-radius: 5px; }
        table { width: 100%; border-collapse: collapse; background-color: white; margin-top: 20px; }
        th { background-color: #0078d4; color: white; padding: 10px; text-align: left; }
        td { padding: 8px; border-bottom: 1px solid #ddd; }
        tr:hover { background-color: #f0f0f0; }
        .ERROR { background-color: #ffebee; }
        .SUCCESS { background-color: #e8f5e9; }
        .stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin: 20px 0; }
        .stat-box { background: white; padding: 15px; border-radius: 5px; text-align: center; border-left: 4px solid #0078d4; }
        .stat-value { font-size: 24px; font-weight: bold; color: #0078d4; }
        .stat-label { color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Reporte de Detalles de Pasos - SARA3</h1>
        <p>Máquina: $machineName | Usuario: $userName | Fecha: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')</p>
    </div>
    
    <div class="stats">
        <div class="stat-box">
            <div class="stat-value">$($allSteps.Count)</div>
            <div class="stat-label">Pasos Totales</div>
        </div>
        <div class="stat-box">
            <div class="stat-value">$($allSteps | Where-Object { $_.Estado -eq 'SUCCESS' } | Measure-Object | Select-Object -ExpandProperty Count)</div>
            <div class="stat-label">Pasos Exitosos</div>
        </div>
        <div class="stat-box">
            <div class="stat-value">$($allSteps | Where-Object { $_.Estado -eq 'ERROR' } | Measure-Object | Select-Object -ExpandProperty Count)</div>
            <div class="stat-label">Pasos con Error</div>
        </div>
    </div>
    
    <h2>Detalle de Pasos</h2>
    <table>
        <thead>
            <tr>
                <th>Test</th>
                <th>Batch</th>
                <th>Descripción</th>
                <th>Estado</th>
                <th>Error Type</th>
                <th>Tiempo (s)</th>
            </tr>
        </thead>
        <tbody>
"@

foreach ($step in $allSteps) {
    $cssClass = $step.Estado
    $errorDisplay = if($step.Estado -eq "ERROR") { $step.ErrorType } else { "-" }
    
    $html += @"
            <tr class="$cssClass">
                <td>$($step.Test)</td>
                <td>$($step.Batch)</td>
                <td>$($step.Descripcion)</td>
                <td>$($step.Estado)</td>
                <td>$errorDisplay</td>
                <td>$($step.Tiempo_s)</td>
            </tr>

"@
}

$html += @"
        </tbody>
    </table>
</body>
</html>
"@

$html | Out-File -FilePath $htmlPath -Encoding UTF8
Write-Host "HTML generado: $htmlPath" -ForegroundColor Green

# ===== RESUMEN =====

Write-Host ""
Write-Host "Reportes generados exitosamente:" -ForegroundColor Green
Write-Host "  - $csvPath" -ForegroundColor Cyan
Write-Host "  - $htmlPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total de pasos procesados: $($allSteps.Count)" -ForegroundColor Green
