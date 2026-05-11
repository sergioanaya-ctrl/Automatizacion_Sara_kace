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
$reportFolder = "target\reports"
$csvOutput = "$reportFolder\test_timings_report.csv"
$xlsxOutput = "$reportFolder\test_timings_report.xlsx"

# Crear carpeta de reportes
if (-not (Test-Path $reportFolder)) {
    New-Item -ItemType Directory -Path $reportFolder | Out-Null
}

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
$totalTests = @($testData).Count
$passedTests = @($testData | Where-Object { $_.Status -eq "PASSED" }).Count
$failedTests = @($testData | Where-Object { $_.Status -eq "FAILED" }).Count
$skippedTests = @($testData | Where-Object { $_.Status -eq "SKIPPED" }).Count

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

# Generar Excel desde CSV usando función reutilizable
Write-Host ""
Write-Host "Generando Excel desde CSV..." -ForegroundColor Cyan

. ".\generate_excel_from_csv.ps1"
$excelSuccess = Convert-CsvToExcel -csvPath $csvOutput -outputPath $reportFolder -worksheetName "Test Timings"

if ($excelSuccess) {
    Write-Host "✓ Excel generado exitosamente" -ForegroundColor Green
} else {
    Write-Host "⚠ No se pudo generar Excel, pero CSV está disponible" -ForegroundColor Yellow
}

# Mostrar los 10 tests mas lentos
Write-Host ""
Write-Host "TOP 10 TESTS MAS LENTOS:" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Yellow
$testData | Select-Object -First 10 | ForEach-Object {
    Write-Host "$($_.`"Test Name`") - $($_.`"Duration (min)`") min - $($_.Status)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ REPORTES GENERADOS EXITOSAMENTE!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "   CSV: $csvOutput" -ForegroundColor Gray
Write-Host ""
