# ============================================
# Consolidate Multiple Test Reports (CSV)
# ============================================
# Este script consolida múltiples reportes CSV de diferentes máquinas
# en un solo reporte unificado con análisis comparativo
# 
# USO:
# 1. Copia los archivos step_details_*.csv de cada máquina a: .\reports_consolidation\
# 2. Ejecuta consolidate_reports.bat
# 3. El reporte consolidado se genera en: .\reports_consolidation\consolidated_report_*.xlsx

param(
    [string]$inputFolder = ".\reports_consolidation",
    [string]$outputFolder = ".\reports_consolidation",
    [string]$outputFileName = "consolidated_report"
)

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  CONSOLIDADOR DE REPORTES CSV" -ForegroundColor Cyan
Write-Host "  Multiple Machines Report Consolidation" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Crear carpeta de entrada si no existe
if (-not (Test-Path $inputFolder)) {
    New-Item -ItemType Directory -Path $inputFolder | Out-Null
    Write-Host "[INFO] Carpeta creada: $inputFolder" -ForegroundColor Green
    Write-Host "[INFO] Copia aquí los archivos step_details_*.csv de otras máquinas" -ForegroundColor Yellow
    Write-Host ""
}

# Crear carpeta de salida si no existe (misma que entrada)
if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Buscar todos los archivos CSV en la carpeta de entrada
$csvFiles = Get-ChildItem -Path $inputFolder -Filter "step_details_*.csv" -ErrorAction SilentlyContinue

if ($csvFiles.Count -eq 0) {
    Write-Host "[ADVERTENCIA] No se encontraron archivos CSV en: $inputFolder" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Instrucciones:" -ForegroundColor Cyan
    Write-Host "1. Copia los archivos step_details_*.csv de cada máquina a: $inputFolder" -ForegroundColor White
    Write-Host "2. Ejecuta este script nuevamente (o usa consolidate_reports.bat)" -ForegroundColor White
    Write-Host ""
    pause
    exit 0
}

Write-Host "[INFO] Encontrados $($csvFiles.Count) archivos CSV para consolidar:" -ForegroundColor Green
foreach ($file in $csvFiles) {
    Write-Host "  - $($file.Name) ($([math]::Round($file.Length/1KB, 2)) KB)" -ForegroundColor White
}
Write-Host ""

# ============================================
# PROCESAR TODOS LOS ARCHIVOS CSV
# ============================================
Write-Host "[INFO] Procesando archivos CSV..." -ForegroundColor Cyan

$allSteps = @()

foreach ($file in $csvFiles) {
    Write-Host "  Leyendo: $($file.Name)..." -ForegroundColor White
    
    try {
        # Leer CSV con encoding UTF-8
        $csvData = Import-Csv -Path $file.FullName -Encoding UTF8
        
        # Agregar columna de origen (nombre del archivo)
        $csvData | ForEach-Object {
            $_ | Add-Member -NotePropertyName "Archivo Origen" -NotePropertyValue $file.Name -Force
        }
        
        $allSteps += $csvData
        Write-Host "    OK: $($csvData.Count) pasos cargados" -ForegroundColor Green
        
    } catch {
        Write-Host "    ERROR: No se pudo leer el archivo: $($file.Name)" -ForegroundColor Red
        Write-Host "    Detalle: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[OK] Archivos procesados correctamente" -ForegroundColor Green
Write-Host "  - Total pasos consolidados: $($allSteps.Count)" -ForegroundColor White
Write-Host ""

# ============================================
# GENERAR ANÁLISIS CONSOLIDADO
# ============================================
Write-Host "[INFO] Generando análisis consolidado..." -ForegroundColor Cyan

# Obtener lista única de tests (agrupando por Test)
$uniqueTests = $allSteps | Group-Object Test

# Calcular estadísticas por test
$testStats = $uniqueTests | ForEach-Object {
    $testName = $_.Name
    $steps = $_.Group
    $batch = ($steps | Select-Object -First 1).Batch
    $maquina = ($steps | Select-Object -First 1).Maquina
    $usuario = ($steps | Select-Object -First 1).Usuario
    $estado = ($steps | Select-Object -First 1).Estado
    $errorType = ($steps | Select-Object -First 1)."Error Type"
    $errorMsg = ($steps | Select-Object -First 1)."Error Message"
    
    $totalPasos = $steps.Count
    $pasosLentos = ($steps | Where-Object { $_."Tiempo (ms)" -gt 5000 }).Count
    $tiempoTotalMs = ($steps | Measure-Object -Property "Tiempo (ms)" -Sum).Sum
    $tiempoTotalMin = [math]::Round($tiempoTotalMs / 60000, 2)
    
    [PSCustomObject]@{
        "Test" = $testName
        "Batch" = $batch
        "Maquina" = $maquina
        "Usuario" = $usuario
        "Total Pasos" = $totalPasos
        "Pasos Lentos" = $pasosLentos
        "Tiempo Total (min)" = $tiempoTotalMin
        "Estado" = $estado
        "Error Type" = $errorType
        "Error Message" = $errorMsg
    }
}

# Pasos lentos (>5s)
$slowSteps = $allSteps | Where-Object { $_."Tiempo (ms)" -gt 5000 } | Sort-Object { [int]$_."Tiempo (ms)" } -Descending

# Tests fallidos
$failedTests = $testStats | Where-Object { $_.Estado -eq "FAILED" }

# Resumen General Consolidado
$totalTests = $testStats.Count
$totalPassed = ($testStats | Where-Object { $_.Estado -eq "PASSED" }).Count
$totalFailed = ($testStats | Where-Object { $_.Estado -eq "FAILED" }).Count
$totalSteps = $allSteps.Count
$totalSlowSteps = $slowSteps.Count
$uniqueMachines = ($allSteps | Select-Object -Unique Maquina).Count

$resumenGeneral = @()
$resumenGeneral += [PSCustomObject]@{ "Metrica" = "Fecha Consolidación"; "Valor" = (Get-Date -Format "dd/MM/yyyy HH:mm:ss") }
$resumenGeneral += [PSCustomObject]@{ "Metrica" = "Archivos Procesados"; "Valor" = $csvFiles.Count }
$resumenGeneral += [PSCustomObject]@{ "Metrica" = "Total Máquinas"; "Valor" = $uniqueMachines }
$resumenGeneral += [PSCustomObject]@{ "Metrica" = "Total Tests Ejecutados"; "Valor" = $totalTests }
$resumenGeneral += [PSCustomObject]@{ "Metrica" = "Tests Exitosos"; "Valor" = $totalPassed }
$resumenGeneral += [PSCustomObject]@{ "Metrica" = "Tests Fallidos"; "Valor" = $totalFailed }
$resumenGeneral += [PSCustomObject]@{ "Metrica" = "Tasa de Éxito %"; "Valor" = if($totalTests -gt 0) { [math]::Round(($totalPassed / $totalTests) * 100, 2) } else { 0 } }
$resumenGeneral += [PSCustomObject]@{ "Metrica" = "Total Pasos Ejecutados"; "Valor" = $totalSteps }
$resumenGeneral += [PSCustomObject]@{ "Metrica" = "Total Pasos Lentos (>5s)"; "Valor" = $totalSlowSteps }

# Estadísticas por Máquina
$statsByMachine = $testStats | Group-Object Maquina | ForEach-Object {
    $machine = $_.Name
    $tests = $_.Group
    $passed = ($tests | Where-Object { $_.Estado -eq "PASSED" }).Count
    $failed = ($tests | Where-Object { $_.Estado -eq "FAILED" }).Count
    $avgTime = ($tests | Measure-Object -Property "Tiempo Total (min)" -Average).Average
    
    [PSCustomObject]@{
        "Máquina" = $machine
        "Usuario" = ($tests | Select-Object -First 1).Usuario
        "Total Tests" = $tests.Count
        "Tests Exitosos" = $passed
        "Tests Fallidos" = $failed
        "Tasa Éxito %" = if($tests.Count -gt 0) { [math]::Round(($passed / $tests.Count) * 100, 2) } else { 0 }
        "Tiempo Promedio (min)" = [math]::Round($avgTime, 2)
    }
} | Sort-Object "Tests Fallidos" -Descending

# Distribución de Errores Consolidada
$errorDistribution = $null
if ($totalFailed -gt 0) {
    $errorDistribution = $failedTests | Group-Object "Error Type" | 
        Select-Object @{N="Error Type"; E={$_.Name}},
                      @{N="Cantidad"; E={$_.Count}},
                      @{N="Porcentaje"; E={[math]::Round(($_.Count / $totalFailed) * 100, 2)}} |
        Sort-Object Cantidad -Descending
}

# Estadísticas por Batch Consolidadas
$statsByBatch = $testStats | Group-Object Batch | ForEach-Object {
    $batch = $_.Name
    $tests = $_.Group
    $passed = ($tests | Where-Object { $_.Estado -eq "PASSED" }).Count
    $failed = ($tests | Where-Object { $_.Estado -eq "FAILED" }).Count
    
    [PSCustomObject]@{
        "Batch" = $batch
        "Total Tests" = $tests.Count
        "Exitosos" = $passed
        "Fallidos" = $failed
        "Tasa Error %" = if($tests.Count -gt 0) { [math]::Round(($failed / $tests.Count) * 100, 2) } else { 0 }
        "Máquinas Ejecutoras" = ($tests | Select-Object -Unique Maquina).Count
    }
} | Sort-Object Batch

# ============================================
# GENERAR REPORTES CONSOLIDADOS
# ============================================
Write-Host ""
Write-Host "[INFO] Generando reportes consolidados..." -ForegroundColor Cyan

# 1. CSV Consolidado (TODOS LOS PASOS)
$csvConsolidatedPath = "$outputFolder\${outputFileName}_$timestamp.csv"
$allSteps | Export-Csv -Path $csvConsolidatedPath -NoTypeInformation -Encoding UTF8
Write-Host "  - CSV generado: $csvConsolidatedPath" -ForegroundColor Green

# 2. CSV de Estadísticas por Test
$csvStatsPath = "$outputFolder\${outputFileName}_stats_$timestamp.csv"
$testStats | Export-Csv -Path $csvStatsPath -NoTypeInformation -Encoding UTF8
Write-Host "  - CSV Stats generado: $csvStatsPath" -ForegroundColor Green

# 3. CSV de Estadísticas por Máquina
$csvMachinePath = "$outputFolder\${outputFileName}_by_machine_$timestamp.csv"
$statsByMachine | Export-Csv -Path $csvMachinePath -NoTypeInformation -Encoding UTF8
Write-Host "  - CSV Máquinas generado: $csvMachinePath" -ForegroundColor Green

# 4. Intentar generar Excel (si ImportExcel está disponible)
$excelGenerated = $false
if (Get-Module -ListAvailable -Name ImportExcel) {
    try {
        Import-Module ImportExcel -ErrorAction SilentlyContinue
        
        $excelPath = "$outputFolder\${outputFileName}_$timestamp.xlsx"
        
        # Hoja 1: Resumen General
        $resumenGeneral | Export-Excel -Path $excelPath -WorksheetName "Resumen General" -AutoSize -TableStyle "Medium2"
        
        # Hoja 2: Estadísticas por Máquina
        if ($statsByMachine.Count -gt 0) {
            $statsByMachine | Export-Excel -Path $excelPath -WorksheetName "Por Máquina" -AutoSize -TableStyle "Medium2" -Append
        }
        
        # Hoja 3: Estadísticas por Test
        if ($testStats.Count -gt 0) {
            $testStats | Export-Excel -Path $excelPath -WorksheetName "Estadísticas por Test" -AutoSize -TableStyle "Light1" -Append
        }
        
        # Hoja 4: Todos los Pasos Consolidados (muestra limitada si son muchos)
        if ($allSteps.Count -gt 0) {
            if ($allSteps.Count -le 100000) {
                $allSteps | Export-Excel -Path $excelPath -WorksheetName "Todos los Pasos" -AutoSize -TableStyle "Light1" -Append
            } else {
                # Si son más de 100k pasos, solo exportar primeros 100k
                $allSteps | Select-Object -First 100000 | Export-Excel -Path $excelPath -WorksheetName "Todos los Pasos (100k)" -AutoSize -TableStyle "Light1" -Append
                Write-Host "    NOTA: Solo se exportaron los primeros 100,000 pasos al Excel" -ForegroundColor Yellow
            }
        }
        
        # Hoja 5: Pasos Lentos Consolidados
        if ($slowSteps.Count -gt 0) {
            $slowSteps | Select-Object -First 10000 | Export-Excel -Path $excelPath -WorksheetName "Pasos Lentos" -AutoSize -TableStyle "Light1" -Append
        }
        
        # Hoja 6: Tests Fallidos
        if ($failedTests.Count -gt 0) {
            $failedTests | Export-Excel -Path $excelPath -WorksheetName "Tests Fallidos" -AutoSize -TableStyle "Light1" -Append
        }
        
        # Hoja 7: Distribución de Errores
        if ($errorDistribution -and $errorDistribution.Count -gt 0) {
            $errorDistribution | Export-Excel -Path $excelPath -WorksheetName "Distribución Errores" -AutoSize -TableStyle "Medium2" -Append
        }
        
        # Hoja 8: Estadísticas por Batch
        if ($statsByBatch.Count -gt 0) {
            $statsByBatch | Export-Excel -Path $excelPath -WorksheetName "Por Batch" -AutoSize -TableStyle "Medium2" -Append
        }
        
        Write-Host "  - Excel generado: $excelPath" -ForegroundColor Green
        $excelGenerated = $true
        
    } catch {
        Write-Host "  - Excel NO generado (error ImportExcel): $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "  - Excel NO generado (ImportExcel no instalado)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================"  -ForegroundColor Green
Write-Host "  CONSOLIDACION COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "ARCHIVOS GENERADOS:" -ForegroundColor Yellow
Write-Host "  - $csvConsolidatedPath" -ForegroundColor Cyan
Write-Host "  - $csvStatsPath" -ForegroundColor Cyan
Write-Host "  - $csvMachinePath" -ForegroundColor Cyan
if ($excelGenerated) {
    Write-Host "  - $excelPath" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "RESUMEN CONSOLIDADO:" -ForegroundColor Yellow
Write-Host ("  - Archivos CSV procesados: " + $csvFiles.Count) -ForegroundColor White
Write-Host ("  - Maquinas unicas: " + $uniqueMachines) -ForegroundColor White
Write-Host ("  - Total tests ejecutados: " + $totalTests) -ForegroundColor White
Write-Host ("  - Tests exitosos: " + $totalPassed) -ForegroundColor Green
Write-Host ("  - Tests fallidos: " + $totalFailed) -ForegroundColor Red
$tasaExito = if($totalTests -gt 0) { [math]::Round(($totalPassed / $totalTests) * 100, 2) } else { 0 }
Write-Host ("  - Tasa de exito: " + $tasaExito + "%") -ForegroundColor Cyan
Write-Host ("  - Total pasos: " + $totalSteps) -ForegroundColor White
Write-Host ("  - Pasos lentos (>5s): " + $totalSlowSteps) -ForegroundColor White
Write-Host ""
Write-Host "ESTADISTICAS POR MAQUINA:" -ForegroundColor Yellow
foreach ($item in $statsByMachine) {
    $maq = $item."Máquina"
    $tot = $item."Total Tests"
    $ok = $item."Tests Exitosos"
    $fail = $item."Tests Fallidos"
    $colorMaq = if($fail -eq 0) { "Green" } else { "Yellow" }
    Write-Host ("  - " + $maq + ": " + $tot + " tests (" + $ok + " OK, " + $fail + " FAIL)") -ForegroundColor $colorMaq
}
Write-Host ""
Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

