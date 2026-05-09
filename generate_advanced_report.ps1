# ========================================================
# SCRIPT DE REPORTING AVANZADO PARA SARA3
# Genera reportes en Excel y HTML con multiples funcionalidades
# ========================================================

# Configuracion
$testResultsPath = "build\test-results\test"
$reportFolder = "target\reports"
$xlsxOutput = "$reportFolder\test_timings_report.xlsx"
$htmlOutput = "$reportFolder\test_timings_report.html"
$historicFolder = "target\reports_historic"

# Crear carpeta de reportes
if (-not (Test-Path $reportFolder)) {
    New-Item -ItemType Directory -Path $reportFolder | Out-Null
}
$alertThresholdMinutes = 3

# Crear carpeta de historico
if (-not (Test-Path $historicFolder)) {
    New-Item -ItemType Directory -Path $historicFolder | Out-Null
}

# Crear carpeta de reportes
if (-not (Test-Path $reportFolder)) {
    New-Item -ItemType Directory -Path $reportFolder | Out-Null
}

# Verificar resultados
if (-not (Test-Path $testResultsPath)) {
    Write-Host "ERROR: No se encontro: $testResultsPath" -ForegroundColor Red
    exit 1
}

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Generando REPORTE AVANZADO..." -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$testData = @()

# Leer XMLs
Get-ChildItem -Path $testResultsPath -Filter "*.xml" | ForEach-Object {
    [xml]$xmlContent = Get-Content $_.FullName
    $testSuite = $xmlContent.SelectSingleNode("//testsuite")
    
    if ($testSuite) {
        $suiteName = $testSuite.GetAttribute("name")
        $testSuite.SelectNodes("testcase") | ForEach-Object {
            $testName = $_.GetAttribute("name")
            $testTime = [double]$_.GetAttribute("time")
            $testClass = $_.GetAttribute("classname")
            
            $status = "PASSED"
            $errorMsg = ""
            
            $failure = $_.SelectSingleNode("failure")
            if ($failure) {
                $status = "FAILED"
                $errorMsg = $failure.GetAttribute("message")
            }
            $skipped = $_.SelectSingleNode("skipped")
            if ($skipped) {
                $status = "SKIPPED"
            }
            
            # Extraer region
            $region = "GENERAL"
            if ($testName -match "- ([A-Z\s]+) -") {
                $region = $matches[1].Trim()
            }
            
            $testData += [PSCustomObject]@{
                "Suite" = $suiteName
                "TestName" = $testName
                "Region" = $region
                "Class" = $testClass
                "DurationMin" = [math]::Round($testTime / 60, 2)
                "Status" = $status
                "Error" = $errorMsg
                "IsSlow" = ($testTime / 60) -gt $alertThresholdMinutes
            }
        }
    }
}

$testData = $testData | Sort-Object -Property "DurationMin" -Descending

# Estadisticas
$totalTime = ($testData | Measure-Object -Property "DurationMin" -Sum).Sum
$avgTime = ($testData | Measure-Object -Property "DurationMin" -Average).Average
$maxTime = ($testData | Measure-Object -Property "DurationMin" -Maximum).Maximum
$minTime = ($testData | Measure-Object -Property "DurationMin" -Minimum).Minimum
$totalTests = @($testData).Count
$passedTests = @($testData | Where-Object { $_.Status -eq "PASSED" }).Count
$failedTests = @($testData | Where-Object { $_.Status -eq "FAILED" }).Count
$skippedTests = @($testData | Where-Object { $_.Status -eq "SKIPPED" }).Count
$slowTests = @($testData | Where-Object { $_.IsSlow -eq $true }).Count
$passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }

Write-Host "Total: $totalTests | Exitosos: $passedTests | Fallidos: $failedTests | Lentos: $slowTests" -ForegroundColor Green
Write-Host "Tiempo total: $([math]::Round($totalTime, 2)) min | Promedio: $([math]::Round($avgTime, 2)) min" -ForegroundColor Cyan
Write-Host ""

# ========================================================
# CREAR EXCEL
# ========================================================
try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $workbook = $excel.Workbooks.Add()
    
    # HOJA 1: RESUMEN
    $sheet1 = $workbook.Sheets.Item(1)
    $sheet1.Name = "Summary"
    
    $sheet1.Cells.Item(1, 1) = "ESTADISTICAS GENERALES"
    $sheet1.Cells.Item(1, 1).Font.Bold = $true
    $sheet1.Cells.Item(1, 1).Font.Size = 14
    
    $stats = @(
        @("Metrica", "Valor"),
        @("Total de Tests", $totalTests),
        @("Tests Exitosos", "$passedTests ($passRate%)"),
        @("Tests Fallidos", $failedTests),
        @("Tests Omitidos", $skippedTests),
        @("Tests Lentos", $slowTests),
        @("Tiempo Total (min)", [math]::Round($totalTime, 2)),
        @("Tiempo Promedio (min)", [math]::Round($avgTime, 2)),
        @("Tiempo Maximo (min)", [math]::Round($maxTime, 2)),
        @("Tiempo Minimo (min)", [math]::Round($minTime, 2))
    )
    
    $row = 3
    foreach ($stat in $stats) {
        $sheet1.Cells.Item($row, 1) = $stat[0]
        $sheet1.Cells.Item($row, 2) = $stat[1]
        
        if ($row -eq 3) {
            $sheet1.Cells.Item($row, 1).Font.Bold = $true
            $sheet1.Cells.Item($row, 2).Font.Bold = $true
            $sheet1.Cells.Item($row, 1).Interior.ColorIndex = 15
            $sheet1.Cells.Item($row, 2).Interior.ColorIndex = 15
        }
        $row++
    }
    
    $sheet1.UsedRange.Columns.AutoFit() | Out-Null
    
    # HOJA 2: TODOS LOS TESTS
    $sheet2 = $workbook.Sheets.Add()
    $sheet2.Name = "All Tests"
    
    $headers = @("Suite", "Test Name", "Region", "Duration (min)", "Status", "Error")
    for ($i = 0; $i -lt $headers.Count; $i++) {
        $sheet2.Cells.Item(1, $i + 1) = $headers[$i]
        $sheet2.Cells.Item(1, $i + 1).Font.Bold = $true
        $sheet2.Cells.Item(1, $i + 1).Interior.ColorIndex = 15
    }
    
    $row = 2
    foreach ($test in $testData) {
        $sheet2.Cells.Item($row, 1) = $test.Suite
        $sheet2.Cells.Item($row, 2) = $test.TestName
        $sheet2.Cells.Item($row, 3) = $test.Region
        $sheet2.Cells.Item($row, 4) = $test.DurationMin
        $sheet2.Cells.Item($row, 5) = $test.Status
        $sheet2.Cells.Item($row, 6) = $test.Error
        
        if ($test.Status -eq "FAILED") {
            $sheet2.Cells.Item($row, 5).Interior.Color = 255
        } elseif ($test.IsSlow -eq $true) {
            $sheet2.Cells.Item($row, 4).Interior.Color = 65535
        }
        $row++
    }
    
    $sheet2.UsedRange.Columns.AutoFit() | Out-Null
    
    # HOJA 3: EXITOSOS
    $passedData = @($testData | Where-Object { $_.Status -eq "PASSED" })
    if ($passedData.Count -gt 0) {
        $sheet3 = $workbook.Sheets.Add()
        $sheet3.Name = "PASSED"
        
        $headers = @("Test Name", "Region", "Duration (min)", "Suite")
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $sheet3.Cells.Item(1, $i + 1) = $headers[$i]
            $sheet3.Cells.Item(1, $i + 1).Font.Bold = $true
            $sheet3.Cells.Item(1, $i + 1).Interior.ColorIndex = 10
        }
        
        $row = 2
        foreach ($test in $passedData) {
            $sheet3.Cells.Item($row, 1) = $test.TestName
            $sheet3.Cells.Item($row, 2) = $test.Region
            $sheet3.Cells.Item($row, 3) = $test.DurationMin
            $sheet3.Cells.Item($row, 4) = $test.Suite
            $row++
        }
        
        $sheet3.UsedRange.Columns.AutoFit() | Out-Null
    }
    
    # HOJA 4: FALLIDOS
    $failedData = @($testData | Where-Object { $_.Status -eq "FAILED" })
    if ($failedData.Count -gt 0) {
        $sheet4 = $workbook.Sheets.Add()
        $sheet4.Name = "FAILED"
        
        $headers = @("Test Name", "Region", "Duration (min)", "Error Message")
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $sheet4.Cells.Item(1, $i + 1) = $headers[$i]
            $sheet4.Cells.Item(1, $i + 1).Font.Bold = $true
            $sheet4.Cells.Item(1, $i + 1).Interior.ColorIndex = 3
        }
        
        $row = 2
        foreach ($test in $failedData) {
            $sheet4.Cells.Item($row, 1) = $test.TestName
            $sheet4.Cells.Item($row, 2) = $test.Region
            $sheet4.Cells.Item($row, 3) = $test.DurationMin
            $sheet4.Cells.Item($row, 4) = $test.Error
            $sheet4.Cells.Item($row, 5).Interior.Color = 255
            $row++
        }
        
        $sheet4.UsedRange.Columns.AutoFit() | Out-Null
    }
    
    # HOJA 5: LENTOS
    $slowData = @($testData | Where-Object { $_.IsSlow -eq $true })
    if ($slowData.Count -gt 0) {
        $sheet5 = $workbook.Sheets.Add()
        $sheet5.Name = "Slow Tests"
        
        $headers = @("Test Name", "Region", "Duration (min)", "Status")
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $sheet5.Cells.Item(1, $i + 1) = $headers[$i]
            $sheet5.Cells.Item(1, $i + 1).Font.Bold = $true
            $sheet5.Cells.Item(1, $i + 1).Interior.ColorIndex = 6
        }
        
        $row = 2
        foreach ($test in $slowData) {
            $sheet5.Cells.Item($row, 1) = $test.TestName
            $sheet5.Cells.Item($row, 2) = $test.Region
            $sheet5.Cells.Item($row, 3) = $test.DurationMin
            $sheet5.Cells.Item($row, 4) = $test.Status
            $sheet5.Cells.Item($row, 3).Interior.Color = 65535
            $row++
        }
        
        $sheet5.UsedRange.Columns.AutoFit() | Out-Null
    }
    
    # HOJA 6: COBERTURA POR REGION
    $regions = @($testData | Select-Object -ExpandProperty "Region" -Unique)
    if ($regions.Count -gt 0) {
        $sheet6 = $workbook.Sheets.Add()
        $sheet6.Name = "Coverage by Region"
        
        $headers = @("Region", "Total Tests", "Passed", "Failed", "Pass Rate (%)")
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $sheet6.Cells.Item(1, $i + 1) = $headers[$i]
            $sheet6.Cells.Item(1, $i + 1).Font.Bold = $true
            $sheet6.Cells.Item(1, $i + 1).Interior.ColorIndex = 15
        }
        
        $row = 2
        foreach ($region in $regions) {
            $regionTests = @($testData | Where-Object { $_.Region -eq $region })
            $regionPassed = @($regionTests | Where-Object { $_.Status -eq "PASSED" }).Count
            $regionFailed = @($regionTests | Where-Object { $_.Status -eq "FAILED" }).Count
            $regionTotal = @($regionTests).Count
            $regionRate = if ($regionTotal -gt 0) { [math]::Round(($regionPassed / $regionTotal) * 100, 2) } else { 0 }
            
            $sheet6.Cells.Item($row, 1) = $region
            $sheet6.Cells.Item($row, 2) = $regionTotal
            $sheet6.Cells.Item($row, 3) = $regionPassed
            $sheet6.Cells.Item($row, 4) = $regionFailed
            $sheet6.Cells.Item($row, 5) = $regionRate
            
            $row++
        }
        
        $sheet6.UsedRange.Columns.AutoFit() | Out-Null
    }
    
    # Guardar
    $fullPath = (Get-Location).Path + "\" + $xlsxOutput
    $workbook.SaveAs($fullPath)
    $workbook.Close()
    $excel.Quit()
    
    Write-Host "[OK] Excel generado: $fullPath" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] No se pudo crear Excel: $_" -ForegroundColor Red
}

# ========================================================
# CREAR HTML
# ========================================================
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SARA3 - Reporte de Pruebas</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; }
        h1 { color: #667eea; border-bottom: 2px solid #667eea; padding-bottom: 10px; }
        h2 { color: #667eea; margin-top: 30px; padding-bottom: 10px; border-bottom: 1px solid #ddd; }
        .stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin: 20px 0; }
        .stat { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px; text-align: center; }
        .stat-value { font-size: 32px; font-weight: bold; }
        .stat-label { font-size: 12px; margin-top: 10px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th { background: #f5f5f5; padding: 12px; text-align: left; font-weight: bold; border-bottom: 2px solid #ddd; }
        td { padding: 10px; border-bottom: 1px solid #eee; }
        tr:hover { background: #f9f9f9; }
        .passed { color: green; font-weight: bold; }
        .failed { color: red; font-weight: bold; }
        .skipped { color: orange; font-weight: bold; }
        .alert { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 10px 0; }
        .footer { text-align: center; margin-top: 30px; color: #999; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 SARA3 - Reporte de Pruebas</h1>
        <p>Generado: $timestamp | Pass Rate: <strong>$passRate%</strong></p>
        
        <div class="stats">
            <div class="stat">
                <div class="stat-value">$passedTests</div>
                <div class="stat-label">EXITOSOS ($passRate%)</div>
            </div>
            <div class="stat">
                <div class="stat-value">$failedTests</div>
                <div class="stat-label">FALLIDOS</div>
            </div>
            <div class="stat">
                <div class="stat-value">$slowTests</div>
                <div class="stat-label">LENTOS (>$alertThresholdMinutes min)</div>
            </div>
            <div class="stat">
                <div class="stat-value">$totalTests</div>
                <div class="stat-label">TOTAL</div>
            </div>
        </div>

        <h2>Tiempos de Ejecucion</h2>
        <table>
            <tr><td><strong>Tiempo Total:</strong></td><td>$([math]::Round($totalTime, 2)) minutos</td></tr>
            <tr><td><strong>Promedio:</strong></td><td>$([math]::Round($avgTime, 2)) minutos</td></tr>
            <tr><td><strong>Maximo:</strong></td><td>$([math]::Round($maxTime, 2)) minutos</td></tr>
            <tr><td><strong>Minimo:</strong></td><td>$([math]::Round($minTime, 2)) minutos</td></tr>
        </table>

        <h2>Top 10 Tests Mas Rapidos</h2>
        <table>
            <tr>
                <th>Test Name</th>
                <th>Region</th>
                <th>Tiempo (min)</th>
                <th>Status</th>
            </tr>
"@

$testData | Sort-Object -Property "DurationMin" -Ascending | Select-Object -First 10 | ForEach-Object {
    $statusClass = switch ($_.Status) {
        "PASSED" { "passed" }
        "FAILED" { "failed" }
        default { "skipped" }
    }
    $html += "<tr><td>$($_.TestName)</td><td>$($_.Region)</td><td>$($_.DurationMin)</td><td class='$statusClass'>$($_.Status)</td></tr>"
}

$html += @"
        </table>

        <h2>Top 10 Tests Mas Lentos</h2>
        <table>
            <tr>
                <th>Test Name</th>
                <th>Region</th>
                <th>Tiempo (min)</th>
                <th>Status</th>
            </tr>
"@

$testData | Select-Object -First 10 | ForEach-Object {
    $statusClass = switch ($_.Status) {
        "PASSED" { "passed" }
        "FAILED" { "failed" }
        default { "skipped" }
    }
    $html += "<tr><td>$($_.TestName)</td><td>$($_.Region)</td><td>$($_.DurationMin)</td><td class='$statusClass'>$($_.Status)</td></tr>"
}

$html += "</table>"

# Agregar tabla de region coverage
if ($regions.Count -gt 0) {
    $html += "<h2>Cobertura por Region</h2><table><tr><th>Region</th><th>Total</th><th>Passed</th><th>Failed</th><th>Pass Rate</th></tr>"
    
    foreach ($region in $regions) {
        $regionTests = @($testData | Where-Object { $_.Region -eq $region })
        $regionPassed = @($regionTests | Where-Object { $_.Status -eq "PASSED" }).Count
        $regionFailed = @($regionTests | Where-Object { $_.Status -eq "FAILED" }).Count
        $regionTotal = @($regionTests).Count
        $regionRate = if ($regionTotal -gt 0) { [math]::Round(($regionPassed / $regionTotal) * 100, 2) } else { 0 }
        
        $html += "<tr><td><strong>$region</strong></td><td>$regionTotal</td><td class='passed'>$regionPassed</td><td class='failed'>$regionFailed</td><td><strong>$regionRate%</strong></td></tr>"
    }
    $html += "</table>"
}

$html += @"
        <div class="footer">
            <p>SARA3 Automation Test Suite | Reporte Generado Automaticamente</p>
        </div>
    </div>
</body>
</html>
"@

$html | Out-File -FilePath $htmlOutput -Encoding UTF8
Write-Host "[OK] HTML generado: $htmlOutput" -ForegroundColor Green

# Guardar en historico
$timestamp_file = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item $xlsxOutput -Destination "$historicFolder\report_$timestamp_file.xlsx" -ErrorAction SilentlyContinue
Copy-Item $htmlOutput -Destination "$historicFolder\report_$timestamp_file.html" -ErrorAction SilentlyContinue

Write-Host "[OK] Reportes generados exitosamente!" -ForegroundColor Green
