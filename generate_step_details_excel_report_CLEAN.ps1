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

function Create-ExcelFile {
    param(
        [string]$filePath,
        [array]$sheetData,
        [array]$sheetNames,
        [string]$csvPath  # Ruta del CSV para fallback
    )
    
    $hasExcel = $false
    
    # Intentar con Excel COM
    try {
        $excel = New-Object -ComObject Excel.Application -ErrorAction Stop
        $hasExcel = $true
    }
    catch {
        $hasExcel = $false
    }
    
    if ($hasExcel) {
        try {
            $excel.Visible = $false
            $excel.DisplayAlerts = $false
            $workbook = $excel.Workbooks.Add()
            
            for ($i = 0; $i -lt $sheetData.Count; $i++) {
                $sheet = $sheetData[$i]
                if ($null -eq $sheet -or $sheet.Count -eq 0) { continue }
                
                $worksheet = if ($i -eq 0) { $workbook.Worksheets(1) } else { $workbook.Worksheets.Add() }
                $worksheet.Name = $sheetNames[$i]
                
                $row = 1
                $firstItem = $sheet | Select-Object -First 1
                
                if ($firstItem) {
                    # Headers
                    $col = 1
                    foreach ($prop in $firstItem.PSObject.Properties) {
                        $worksheet.Cells($row, $col).Value = [string]$prop.Name
                        $worksheet.Cells($row, $col).Font.Bold = $true
                        $col++
                    }
                    $row++
                    
                    # Data
                    foreach ($item in $sheet) {
                        $col = 1
                        foreach ($prop in $item.PSObject.Properties) {
                            $val = $prop.Value
                            $worksheet.Cells($row, $col).Value = if ($null -eq $val) { "" } else { [string]$val }
                            $col++
                        }
                        $row++
                    }
                    
                    # AutoFit
                    try {
                        $worksheet.UsedRange.EntireColumn.AutoFit() | Out-Null
                    }
                    catch { }
                }
            }
            
            $absolutePath = [System.IO.Path]::GetFullPath($filePath)
            $workbook.SaveAs($absolutePath, 51)  # 51 = xlOpenXMLWorkbook (Excel 2007+)
            $workbook.Close($false)
            $excel.Quit()
            
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook) | Out-Null
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
            [gc]::Collect()
            
            return $true
        }
        catch {
            Write-Host "    Error Excel COM: $_" -ForegroundColor Yellow
            try { $workbook.Close($false); $excel.Quit() } catch { }
            [gc]::Collect()
            # Continuar con fallback a LibreOffice CLI
        }
    }
    
    # Fallback: Usar LibreOffice CLI para convertir CSV a XLSX
    if ($null -ne $csvPath -and (Test-Path $csvPath)) {
        try {
            $libreOfficePath = (Get-Command soffice -ErrorAction SilentlyContinue).Source
            if ($null -eq $libreOfficePath) {
                $libreOfficePath = "C:\Program Files\LibreOffice\program\soffice.exe"
            }
            
            if (Test-Path $libreOfficePath) {
                $outputDir = Split-Path $filePath -Parent
                $absolutePath = [System.IO.Path]::GetFullPath($filePath)
                $csvAbsPath = [System.IO.Path]::GetFullPath($csvPath)
                $csvBaseName = Split-Path $csvAbsPath -Leaf
                
                # Convertir CSV a XLSX usando LibreOffice CLI
                Write-Host "    Convirtiendo CSV a XLSX con LibreOffice..." -ForegroundColor Cyan
                & $libreOfficePath --headless --convert-to xlsx --outdir $outputDir $csvAbsPath 2>&1 | Out-Null
                
                # Esperar a que se complete la conversión
                Start-Sleep -Milliseconds 2000
                
                # Buscar el archivo generado por LibreOffice
                $expectedXlsx = Join-Path $outputDir ($csvBaseName.Replace(".csv", ".xlsx"))
                Write-Host "    Buscando archivo generado: $expectedXlsx" -ForegroundColor Cyan
                
                # Intentar múltiples estrategias para encontrar el archivo
                $foundXlsx = $null
                
                if (Test-Path $expectedXlsx) {
                    $foundXlsx = $expectedXlsx
                } else {
                    # Buscar archivos .xlsx generados recientemente en el directorio
                    $recentXlsx = Get-ChildItem -Path $outputDir -Filter "*.xlsx" -ErrorAction SilentlyContinue | 
                        Where-Object { $_.LastWriteTime -gt (Get-Date).AddSeconds(-30) } | 
                        Sort-Object LastWriteTime -Descending | 
                        Select-Object -First 1
                    
                    if ($recentXlsx) {
                        $foundXlsx = $recentXlsx.FullName
                        Write-Host "    Archivo encontrado: $foundXlsx" -ForegroundColor Cyan
                    }
                }
                
                if ($foundXlsx -and (Test-Path $foundXlsx)) {
                    # Mover/renombrar el archivo al destino final
                    Remove-Item $absolutePath -ErrorAction SilentlyContinue
                    Move-Item -Path $foundXlsx -Destination $absolutePath -Force -ErrorAction SilentlyContinue
                    if (Test-Path $absolutePath) {
                        Write-Host "    Archivo Excel generado exitosamente via LibreOffice" -ForegroundColor Green
                        return $true
                    }
                } else {
                    Write-Host "    No se encontró archivo XLSX generado por LibreOffice" -ForegroundColor Yellow
                }
            } else {
                Write-Host "    LibreOffice no encontrada en: $libreOfficePath" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "    Error LibreOffice CLI: $_" -ForegroundColor Yellow
        }
    }
    
    return $false
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

# ===== GENERAR EXCEL CON COM =====

$excelPath = "$outputPath\step_details_$timestamp.xlsx"

# Hoja 1: Todos los pasos
$stepsSheet = $allSteps | Select-Object @{N="Test"; E={$_.Test}},
                                        @{N="Batch"; E={$_.Batch}},
                                        @{N="Maquina"; E={$machineName}},
                                        @{N="Usuario"; E={$userName}},
                                        @{N="Descripcion"; E={$_.Descripcion}},
                                        @{N="Accion"; E={$_.Accion}},
                                        @{N="Elemento"; E={$_.Elemento}},
                                        @{N="Valor"; E={$_.Valor}},
                                        @{N="Tiempo (s)"; E={$_.Tiempo_s}},
                                        @{N="Estado"; E={$_.Estado}},
                                        @{N="Error Type"; E={if($_.Estado -eq "ERROR") { $_.ErrorType } else { "" }}},
                                        @{N="Error Message"; E={if($_.Estado -eq "ERROR") { $_.ErrorMessage } else { "" }}}

# Hoja 2: Pasos lentos
$slowSteps = $allSteps | Where-Object { $_.Tiempo_ms -gt 5000 } | Sort-Object Tiempo_ms -Descending
$slowSheet = if ($slowSteps.Count -gt 0) {
    $slowSteps | Select-Object @{N="Test"; E={$_.Test}},
                               @{N="Batch"; E={$_.Batch}},
                               @{N="Maquina"; E={$machineName}},
                               @{N="Usuario"; E={$userName}},
                               @{N="Descripcion"; E={$_.Descripcion}},
                               @{N="Tiempo (s)"; E={$_.Tiempo_s}},
                               @{N="Estado"; E={$_.Estado}},
                               @{N="Error Type"; E={if($_.Estado -eq "ERROR") { $_.ErrorType } else { "" }}}
} else {
    @([PSCustomObject]@{ Mensaje = "Sin pasos lentos" })
}

# Hoja 3: Resumen de errores
$errorSummary = $allSteps | Where-Object { $_.Estado -eq "ERROR" } | 
                Group-Object ErrorType | 
                Select-Object @{N="Error Type"; E={$_.Name}},
                              @{N="Cantidad"; E={$_.Count}},
                              @{N="Porcentaje"; E={"{0:N1}" -f (($_.Count / ($allSteps | Where-Object { $_.Estado -eq "ERROR" }).Count) * 100)}} |
                Sort-Object Cantidad -Descending
if ($errorSummary.Count -eq 0) {
    $errorSummary = @([PSCustomObject]@{ "Error Type" = "Sin Errores"; Cantidad = 0; Porcentaje = "0,0" })
}

# Hoja 4: Resumen por Test
$testSummary = $allSteps | Group-Object Test |
               Select-Object @{N="Test"; E={$_.Name}},
                             @{N="Total Pasos"; E={$_.Count}},
                             @{N="Exitosos"; E={($_.Group | Where-Object { $_.Estado -eq "SUCCESS" }).Count}},
                             @{N="Errores"; E={($_.Group | Where-Object { $_.Estado -eq "ERROR" }).Count}},
                             @{N="Pasos Lentos"; E={($_.Group | Where-Object { $_.Tiempo_ms -gt 5000 }).Count}},
                             @{N="Tiempo Total (s)"; E={"{0:N2}" -f ($_.Group | Measure-Object -Property Tiempo_s -Sum).Sum}}

Write-Host "Generando Excel..." -ForegroundColor Cyan
$excelSuccess = Create-ExcelFile -filePath $excelPath `
                                 -sheetData @($stepsSheet, $slowSheet, $errorSummary, $testSummary) `
                                 -sheetNames @("Todos los Pasos", "Pasos Lentos (>5s)", "Resumen de Errores", "Resumen por Test") `
                                 -csvPath $csvPath

if ($excelSuccess) {
    Write-Host "Excel generado: $excelPath" -ForegroundColor Green
} else {
    Write-Host "No se generó Excel (LibreOffice/Excel no disponibles)" -ForegroundColor Yellow
}

# ===== GENERAR HTML PROFESIONAL =====

$htmlPath = "$outputPath\step_details_$timestamp.html"

$successCount = @($allSteps | Where-Object { $_.Estado -eq 'SUCCESS' }).Count
$errorCount = @($allSteps | Where-Object { $_.Estado -eq 'ERROR' }).Count
$slowCount = @($allSteps | Where-Object { $_.Tiempo_ms -gt 5000 }).Count
$totalTime = ($allSteps | Measure-Object -Property Tiempo_s -Sum).Sum

$html = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SARA3 - Reporte de Pasos Detallado</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
            min-height: 100vh; 
            padding: 30px 20px;
        }
        .container { max-width: 1400px; margin: 0 auto; background: white; border-radius: 10px; box-shadow: 0 10px 40px rgba(0,0,0,0.3); }
        .header { 
            background: linear-gradient(135deg, #0078d4 0%, #106ebe 100%); 
            color: white; 
            padding: 40px 30px; 
            border-radius: 10px 10px 0 0;
            border-bottom: 5px solid #ff6b6b;
        }
        .header h1 { font-size: 32px; margin-bottom: 10px; }
        .header p { font-size: 14px; opacity: 0.95; }
        .info-bar { 
            background: #f8f9fa; 
            padding: 15px 30px; 
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            border-bottom: 1px solid #ddd;
            flex-wrap: wrap;
            gap: 20px;
        }
        .info-item { display: flex; align-items: center; gap: 8px; font-size: 13px; }
        .info-label { font-weight: 600; color: #333; }
        .info-value { color: #0078d4; }
        
        .stats-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); 
            gap: 20px; 
            padding: 30px;
            background: #f8f9fa;
        }
        .stat-card { 
            background: white; 
            padding: 25px; 
            border-radius: 8px; 
            border-left: 5px solid #0078d4;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-card.success { border-left-color: #28a745; }
        .stat-card.error { border-left-color: #dc3545; }
        .stat-card.slow { border-left-color: #ffc107; }
        .stat-icon { font-size: 30px; margin-bottom: 10px; }
        .stat-value { font-size: 36px; font-weight: bold; color: #0078d4; }
        .stat-card.success .stat-value { color: #28a745; }
        .stat-card.error .stat-value { color: #dc3545; }
        .stat-card.slow .stat-value { color: #ffc107; }
        .stat-label { color: #666; font-size: 13px; margin-top: 8px; }
        
        .tabs { 
            display: flex; 
            gap: 0; 
            border-bottom: 2px solid #ddd;
            padding: 0 30px;
            background: white;
        }
        .tab-button { 
            padding: 15px 25px; 
            border: none; 
            background: transparent; 
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            color: #666;
            border-bottom: 3px solid transparent;
            transition: all 0.2s;
        }
        .tab-button:hover { color: #0078d4; }
        .tab-button.active { 
            color: #0078d4; 
            border-bottom-color: #0078d4;
            background: #f8f9fa;
        }
        .tab-content { display: none; padding: 30px; }
        .tab-content.active { display: block; }
        
        table { 
            width: 100%; 
            border-collapse: collapse; 
            font-size: 13px;
        }
        th { 
            background: linear-gradient(135deg, #0078d4, #106ebe); 
            color: white; 
            padding: 15px; 
            text-align: left;
            font-weight: 600;
        }
        td { 
            padding: 12px 15px; 
            border-bottom: 1px solid #eee;
        }
        tr:hover { background-color: #f8f9fa; }
        tr.SUCCESS { background-color: #f1f8f5; }
        tr.ERROR { background-color: #fff5f5; }
        
        .badge { 
            display: inline-block; 
            padding: 4px 12px; 
            border-radius: 20px; 
            font-size: 12px; 
            font-weight: 600;
        }
        .badge-success { background: #d4edda; color: #155724; }
        .badge-error { background: #f8d7da; color: #721c24; }
        .badge-warning { background: #fff3cd; color: #856404; }
        
        .error-summary { 
            background: #f8f9fa; 
            padding: 20px; 
            border-radius: 8px; 
            margin-bottom: 20px;
        }
        .error-row { 
            display: flex; 
            justify-content: space-between; 
            padding: 10px 0; 
            border-bottom: 1px solid #ddd;
        }
        .error-row:last-child { border-bottom: none; }
        .error-type { font-weight: 600; color: #333; }
        .error-count { 
            color: #dc3545; 
            font-weight: 700; 
            font-size: 18px;
        }
        .error-percentage { color: #666; font-size: 12px; }
        
        .chart-container { 
            position: relative; 
            height: 300px; 
            margin-bottom: 30px;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        footer { 
            padding: 20px 30px; 
            background: #f8f9fa; 
            border-top: 1px solid #ddd;
            font-size: 12px;
            color: #666;
            text-align: center;
            border-radius: 0 0 10px 10px;
        }
        
        .search-box { 
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
        }
        .search-box input { 
            flex: 1;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 13px;
        }
        .search-box input:focus { 
            outline: none;
            border-color: #0078d4;
            box-shadow: 0 0 5px rgba(0,120,212,0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Reporte de Detalles de Pasos - SARA3</h1>
            <p>Análisis completo de ejecución de casos y pruebas automatizadas</p>
        </div>
        
        <div class="info-bar">
            <div class="info-item">
                <span class="info-label">💻 Máquina:</span>
                <span class="info-value">$machineName</span>
            </div>
            <div class="info-item">
                <span class="info-label">👤 Usuario:</span>
                <span class="info-value">$userName</span>
            </div>
            <div class="info-item">
                <span class="info-label">📅 Fecha:</span>
                <span class="info-value">$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')</span>
            </div>
            <div class="info-item">
                <span class="info-label">⏱️ Tiempo Total:</span>
                <span class="info-value">${totalTime:N2}s</span>
            </div>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon">📋</div>
                <div class="stat-value">$($allSteps.Count)</div>
                <div class="stat-label">Pasos Totales</div>
            </div>
            <div class="stat-card success">
                <div class="stat-icon">✅</div>
                <div class="stat-value">$successCount</div>
                <div class="stat-label">Pasos Exitosos ($(([math]::Round(($successCount/$($allSteps.Count)*100), 1)))%)</div>
            </div>
            <div class="stat-card error">
                <div class="stat-icon">❌</div>
                <div class="stat-value">$errorCount</div>
                <div class="stat-label">Pasos con Error ($(([math]::Round(($errorCount/$($allSteps.Count)*100), 1)))%)</div>
            </div>
            <div class="stat-card slow">
                <div class="stat-icon">🐢</div>
                <div class="stat-value">$slowCount</div>
                <div class="stat-label">Pasos Lentos (&gt;5s)</div>
            </div>
        </div>
        
        <div class="tabs">
            <button class="tab-button active" onclick="showTab('resumen', this)">Resumen</button>
            <button class="tab-button" onclick="showTab('todos', this)">Todos los Pasos</button>
            <button class="tab-button" onclick="showTab('errores', this)">Errores</button>
            <button class="tab-button" onclick="showTab('lentos', this)">Pasos Lentos</button>
        </div>
        
        <div id="resumen" class="tab-content active">
            <div class="chart-container">
                <canvas id="chartEstados"></canvas>
            </div>
            <div class="chart-container">
                <canvas id="chartErrores"></canvas>
            </div>
        </div>
        
        <div id="todos" class="tab-content">
            <div class="search-box">
                <input type="text" id="filtroTodos" placeholder="🔍 Filtrar pasos..." onkeyup="filtrarTabla('tablaTodos', this.value)">
            </div>
            <table id="tablaTodos">
                <thead>
                    <tr>
                        <th>Test</th>
                        <th>Batch</th>
                        <th>Descripción</th>
                        <th>Acción</th>
                        <th>Estado</th>
                        <th>Error Type</th>
                        <th>Tiempo (ms)</th>
                    </tr>
                </thead>
                <tbody>
"@

foreach ($step in $allSteps) {
    $badgeClass = if($step.Estado -eq 'SUCCESS') { 'badge-success' } else { 'badge-error' }
    $errorDisplay = if($step.Estado -eq "ERROR") { $step.ErrorType } else { "-" }
    $rowClass = $step.Estado
    
    $html += @"
                    <tr class="$rowClass">
                        <td><strong>$([System.Net.WebUtility]::HtmlEncode($step.Test))</strong></td>
                        <td>$($step.Batch)</td>
                        <td>$([System.Net.WebUtility]::HtmlEncode($step.Descripcion))</td>
                        <td><small>$([System.Net.WebUtility]::HtmlEncode($step.Accion))</small></td>
                        <td><span class="badge $badgeClass">$($step.Estado)</span></td>
                        <td>$errorDisplay</td>
                        <td><strong>$($step.Tiempo_ms)</strong></td>
                    </tr>

"@
}

$html += @"
                </tbody>
            </table>
        </div>
        
        <div id="errores" class="tab-content">
            <h3>Resumen de Errores</h3>
            <div class="error-summary">
"@

$errorsByType = $allSteps | Where-Object { $_.Estado -eq 'ERROR' } | Group-Object -Property ErrorType | Sort-Object -Property Count -Descending
$totalErrors = $errorCount

foreach ($errorGroup in $errorsByType) {
    $percentage = if ($totalErrors -gt 0) { [math]::Round(($errorGroup.Count / $totalErrors * 100), 1) } else { 0 }
    $html += @"
                <div class="error-row">
                    <div>
                        <div class="error-type">$($errorGroup.Name)</div>
                        <div class="error-percentage">$($errorGroup.Count) ocurrencias ($percentage%)</div>
                    </div>
                    <div class="error-count">$($errorGroup.Count)</div>
                </div>

"@
}

$html += @"
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Test</th>
                        <th>Descripción</th>
                        <th>Error Type</th>
                        <th>Mensaje de Error</th>
                        <th>Tiempo (ms)</th>
                    </tr>
                </thead>
                <tbody>
"@

foreach ($step in ($allSteps | Where-Object { $_.Estado -eq 'ERROR' })) {
    $html += @"
                    <tr class="ERROR">
                        <td><strong>$([System.Net.WebUtility]::HtmlEncode($step.Test))</strong></td>
                        <td>$([System.Net.WebUtility]::HtmlEncode($step.Descripcion))</td>
                        <td><span class="badge badge-error">$($step.ErrorType)</span></td>
                        <td><small>$([System.Net.WebUtility]::HtmlEncode($step.ErrorMessage))</small></td>
                        <td>$($step.Tiempo_ms)</td>
                    </tr>

"@
}

$html += @"
                </tbody>
            </table>
        </div>
        
        <div id="lentos" class="tab-content">
            <h3>Pasos que tardaron más de 5 segundos</h3>
            <table>
                <thead>
                    <tr>
                        <th>Test</th>
                        <th>Batch</th>
                        <th>Descripción</th>
                        <th>Acción</th>
                        <th>Tiempo (s)</th>
                        <th>% del Total</th>
                    </tr>
                </thead>
                <tbody>
"@

foreach ($step in ($allSteps | Where-Object { $_.Tiempo_ms -gt 5000 } | Sort-Object -Property Tiempo_ms -Descending)) {
    $percentageOfTotal = [math]::Round(($step.Tiempo_ms / ($totalTime * 1000) * 100), 1)
    $html += @"
                    <tr>
                        <td><strong>$([System.Net.WebUtility]::HtmlEncode($step.Test))</strong></td>
                        <td>$($step.Batch)</td>
                        <td>$([System.Net.WebUtility]::HtmlEncode($step.Descripcion))</td>
                        <td><small>$([System.Net.WebUtility]::HtmlEncode($step.Accion))</small></td>
                        <td><strong style="color: #ffc107;">$($step.Tiempo_s)</strong></td>
                        <td>$percentageOfTotal%</td>
                    </tr>

"@
}

$html += @"
                </tbody>
            </table>
        </div>
        
        <footer>
            <p>📈 Reporte generado automáticamente | Total de pasos procesados: $($allSteps.Count) | 🔧 Sara3 Automation Framework</p>
        </footer>
    </div>
    
    <script>
        function showTab(tabName, button) {
            var tabs = document.getElementsByClassName('tab-content');
            for (var i = 0; i < tabs.length; i++) {
                tabs[i].classList.remove('active');
            }
            var buttons = document.getElementsByClassName('tab-button');
            for (var i = 0; i < buttons.length; i++) {
                buttons[i].classList.remove('active');
            }
            document.getElementById(tabName).classList.add('active');
            button.classList.add('active');
            
            if (tabName === 'resumen') {
                setTimeout(function() {
                    if (chart1) chart1.resize();
                    if (chart2) chart2.resize();
                }, 100);
            }
        }
        
        function filtrarTabla(tableId, filter) {
            var table = document.getElementById(tableId);
            var rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
            for (var i = 0; i < rows.length; i++) {
                var text = rows[i].textContent.toLowerCase();
                rows[i].style.display = text.indexOf(filter.toLowerCase()) > -1 ? '' : 'none';
            }
        }
        
        var chart1, chart2;
        
        var ctxEstados = document.getElementById('chartEstados').getContext('2d');
        chart1 = new Chart(ctxEstados, {
            type: 'doughnut',
            data: {
                labels: ['Exitosos', 'Con Error'],
                datasets: [{
                    data: [$successCount, $errorCount],
                    backgroundColor: ['#28a745', '#dc3545'],
                    borderColor: ['white', 'white'],
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom' },
                    title: { display: true, text: 'Estado de Pasos' }
                }
            }
        });
        
        var ctxErrores = document.getElementById('chartErrores').getContext('2d');
        chart2 = new Chart(ctxErrores, {
            type: 'bar',
            data: {
                labels: ['Selenium', 'UI', 'Data', 'Validacion', 'Otros'],
                datasets: [{
                    label: 'Cantidad de Errores',
                    data: [
                        $(@($allSteps | Where-Object { $_.ErrorType -eq 'Selenium' }).Count),
                        $(@($allSteps | Where-Object { $_.ErrorType -eq 'UI' }).Count),
                        $(@($allSteps | Where-Object { $_.ErrorType -eq 'Data' }).Count),
                        $(@($allSteps | Where-Object { $_.ErrorType -eq 'Validacion' }).Count),
                        $(@($allSteps | Where-Object { $_.ErrorType -eq 'Otros' }).Count)
                    ],
                    backgroundColor: '#0078d4',
                    borderColor: '#106ebe',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                indexAxis: 'y',
                plugins: {
                    legend: { display: false },
                    title: { display: true, text: 'Errores por Tipo' }
                }
            }
        });
    </script>
</body>
</html>
"@

$html | Out-File -FilePath $htmlPath -Encoding UTF8
Write-Host "HTML generado: $htmlPath" -ForegroundColor Green

# ===== RESUMEN =====

Write-Host ""
Write-Host "Reportes generados exitosamente:" -ForegroundColor Green
Write-Host "  - $excelPath" -ForegroundColor Cyan
Write-Host "  - $csvPath" -ForegroundColor Cyan
Write-Host "  - $htmlPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total de pasos procesados: $($allSteps.Count)" -ForegroundColor Green
