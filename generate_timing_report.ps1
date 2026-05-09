# ========================================================
# Script para generar reporte de tiempos de ejecucion
# ========================================================
# Este script lee los archivos XML de resultados de Junit
# y genera un reporte CSV/XLSX con tiempos de ejecucion

param(
    [string]$OutputFormat = "CSV"  # CSV o XLSX
)

# Ruta de los resultados
$testResultsPath = "build\test-results\test"
$csvOutput = "test_timings_report.csv"
$xlsxOutput = "test_timings_report.xlsx"

# Verificar que existe la carpeta
if (-not (Test-Path $testResultsPath)) {
    Write-Host "ERROR: No se encontro la carpeta de resultados: $testResultsPath" -ForegroundColor Red
    exit 1
}

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Analizando resultados de tests..." -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$testData = @()

# Leer cada archivo XML de resultados
Get-ChildItem -Path $testResultsPath -Filter "*.xml" | ForEach-Object {
    [xml]$xmlContent = Get-Content $_.FullName
    
    # Parsear información del testsuite
    $testSuite = $xmlContent.SelectSingleNode("//testsuite")
    
    if ($testSuite) {
        $suiteName = $testSuite.GetAttribute("name")
        $totalTests = $testSuite.GetAttribute("tests")
        $failures = $testSuite.GetAttribute("failures")
        $skipped = $testSuite.GetAttribute("skipped")
        $time = [double]$testSuite.GetAttribute("time")
        
        # Analizar cada testcase
        $testSuite.SelectNodes("testcase") | ForEach-Object {
            $testName = $_.GetAttribute("name")
            $testTime = [double]$_.GetAttribute("time")
            $testClass = $_.GetAttribute("classname")
            
            # Verificar si paso o fallo
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
            
            $testData += [PSCustomObject]@{
                "Suite" = $suiteName
                "Test Name" = $testName
                "Class" = $testClass
                "Duration (min)" = [math]::Round($testTime / 60, 2)
                "Status" = $status
                "Error Message" = $errorMsg
            }
        }
    }
}

# Ordenar por tiempo descendente
$testData = $testData | Sort-Object -Property "Duration (min)" -Descending

# Calcular estadisticas
$totalTime = ($testData | Measure-Object -Property "Duration (min)" -Sum).Sum
$avgTime = ($testData | Measure-Object -Property "Duration (min)" -Average).Average
$maxTime = ($testData | Measure-Object -Property "Duration (min)" -Maximum).Maximum
$minTime = ($testData | Measure-Object -Property "Duration (min)" -Minimum).Minimum
$totalTests = $testData.Count
$passedTests = ($testData | Where-Object { $_.Status -eq "PASSED" }).Count
$failedTests = ($testData | Where-Object { $_.Status -eq "FAILED" }).Count
$skippedTests = ($testData | Where-Object { $_.Status -eq "SKIPPED" }).Count

# Mostrar estadisticas
Write-Host "ESTADISTICAS DE EJECUCION:" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host "Total de tests: $totalTests" -ForegroundColor Green
Write-Host "Tests exitosos: $passedTests" -ForegroundColor Green
Write-Host "Tests fallidos: $failedTests" -ForegroundColor Red
Write-Host "Tests omitidos: $skippedTests" -ForegroundColor Yellow
Write-Host ""
Write-Host "Tiempo total: $([math]::Round($totalTime, 2)) minutos" -ForegroundColor Cyan
Write-Host "Tiempo promedio: $([math]::Round($avgTime, 2)) minutos" -ForegroundColor Cyan
Write-Host "Tiempo maximo: $([math]::Round($maxTime, 2)) minutos" -ForegroundColor Yellow
Write-Host "Tiempo minimo: $([math]::Round($minTime, 2)) minutos" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Exportar a CSV
Write-Host "Exportando a CSV: $csvOutput" -ForegroundColor Cyan
$testData | Export-Csv -Path $csvOutput -NoTypeInformation -Encoding UTF8

# Crear resumen estadistico
$statsSummary = @(
    [PSCustomObject]@{
        "Metrica" = "Total de Tests"
        "Valor" = $totalTests
    },
    [PSCustomObject]@{
        "Metrica" = "Tests Exitosos"
        "Valor" = $passedTests
    },
    [PSCustomObject]@{
        "Metrica" = "Tests Fallidos"
        "Valor" = $failedTests
    },
    [PSCustomObject]@{
        "Metrica" = "Tests Omitidos"
        "Valor" = $skippedTests
    },
    [PSCustomObject]@{
        "Metrica" = "Tiempo Total (min)"
        "Valor" = [math]::Round($totalTime, 2)
    },
    [PSCustomObject]@{
        "Metrica" = "Tiempo Promedio (min)"
        "Valor" = [math]::Round($avgTime, 2)
    },
    [PSCustomObject]@{
        "Metrica" = "Tiempo Maximo (min)"
        "Valor" = [math]::Round($maxTime, 2)
    },
    [PSCustomObject]@{
        "Metrica" = "Tiempo Minimo (min)"
        "Valor" = [math]::Round($minTime, 2)
    }
)

# Intentar crear XLSX usando Excel COM (si esta disponible)
try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    
    # Crear workbook
    $workbook = $excel.Workbooks.Add()
    
    # Hoja 1: Detalles de tests
    $sheet1 = $workbook.Sheets.Item(1)
    $sheet1.Name = "Test Details"
    
    # Headers
    $col = 1
    @("Suite", "Test Name", "Class", "Duration (min)", "Status", "Error Message") | ForEach-Object {
        $sheet1.Cells.Item(1, $col) = $_
        $sheet1.Cells.Item(1, $col).Font.Bold = $true
        $sheet1.Cells.Item(1, $col).Interior.ColorIndex = 15
        $col++
    }
    
    # Datos
    $row = 2
    $testData | ForEach-Object {
        $sheet1.Cells.Item($row, 1) = $_.Suite
        $sheet1.Cells.Item($row, 2) = $_."Test Name"
        $sheet1.Cells.Item($row, 3) = $_.Class
        $sheet1.Cells.Item($row, 4) = $_."Duration (min)"
        $sheet1.Cells.Item($row, 5) = $_.Status
        $sheet1.Cells.Item($row, 6) = $_."Error Message"
        
        # Colorear por status
        if ($_.Status -eq "FAILED") {
            $sheet1.Cells.Item($row, 5).Interior.Color = 255  # Rojo
        } elseif ($_.Status -eq "SKIPPED") {
            $sheet1.Cells.Item($row, 5).Interior.Color = 65535  # Amarillo
        }
        
        $row++
    }
    
    # Auto-ajustar columnas
    $sheet1.UsedRange.Columns.AutoFit() | Out-Null
    
    # Hoja 2: Estadisticas
    $sheet2 = $workbook.Sheets.Add()
    $sheet2.Name = "Summary"
    
    $row = 1
    $statsSummary | ForEach-Object {
        $sheet2.Cells.Item($row, 1) = $_.Metrica
        $sheet2.Cells.Item($row, 2) = $_.Valor
        $sheet2.Cells.Item($row, 1).Font.Bold = $true
        $row++
    }
    
    $sheet2.UsedRange.Columns.AutoFit() | Out-Null
    
    # Guardar
    $workbook.SaveAs((Get-Location).Path + "\$xlsxOutput")
    $workbook.Close()
    $excel.Quit()
    
    Write-Host "[OK] Reporte XLSX generado: $xlsxOutput" -ForegroundColor Green
} catch {
    Write-Host "[NOTA] No se pudo crear XLSX (Excel no instalado). Solo CSV disponible." -ForegroundColor Yellow
}

# Mostrar los 10 tests mas lentos
Write-Host ""
Write-Host "TOP 10 TESTS MAS LENTOS:" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Yellow
$testData | Select-Object -First 10 | ForEach-Object {
    Write-Host "$($_.`"Test Name`") - $($_.`"Duration (s)`")s - $($_.Status)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "[OK] Reportes generados exitosamente!" -ForegroundColor Green
Write-Host "   CSV: $csvOutput" -ForegroundColor Green
if (Test-Path $xlsxOutput) {
    Write-Host "   XLSX: $xlsxOutput" -ForegroundColor Green
}
