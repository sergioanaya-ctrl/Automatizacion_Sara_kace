# Analisis de Metricas Consolidadas
# Script para extraer indicadores avanzados

param(
    [string]$consolidationFolder = ".\reports_consolidation"
)

Write-Host ""
Write-Host "ANALISIS AVANZADO DE METRICAS" -ForegroundColor Cyan
Write-Host ""

# Buscar archivos
$statsFile = Get-ChildItem -Path $consolidationFolder -Filter "consolidated_report_stats_*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$machineFile = Get-ChildItem -Path $consolidationFolder -Filter "consolidated_report_by_machine_*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$allStepsFile = Get-ChildItem -Path $consolidationFolder -Filter "consolidated_report_20*.csv" -Exclude "*stats*", "*machine*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $statsFile) {
    Write-Host "ERROR: No archivos consolidados" -ForegroundColor Red
    exit 1
}

Write-Host "Cargando datos..." -ForegroundColor Yellow
$stats = Import-Csv -Path $statsFile.FullName -Encoding UTF8
$machines = if($machineFile) { Import-Csv -Path $machineFile.FullName -Encoding UTF8 } else { $null }
$allSteps = if($allStepsFile) { Import-Csv -Path $allStepsFile.FullName -Encoding UTF8 } else { $null }

Write-Host "  OK Tests: $($stats.Count)" -ForegroundColor Green
if($machines) { Write-Host "  OK Machines: $($machines.Count)" -ForegroundColor Green }
if($allSteps) { Write-Host "  OK Steps: $($allSteps.Count)" -ForegroundColor Green }

Write-Host ""
Write-Host "1. INDICADORES GENERALES" -ForegroundColor Magenta
Write-Host "---" -ForegroundColor Magenta

$totalTests = $stats.Count
$passed = (@($stats | Where-Object { $_.Estado -eq "PASSED" })).Count
$failed = (@($stats | Where-Object { $_.Estado -eq "FAILED" })).Count
$tasaExito = if($totalTests -gt 0) { [math]::Round(($passed / $totalTests) * 100, 2) } else { 0 }
$tasaFallo = 100 - $tasaExito

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "  PASSED: $passed" -ForegroundColor Green
Write-Host "  FAILED: $failed" -ForegroundColor Red
Write-Host "Tasa Exito: $tasaExito por ciento" -ForegroundColor Cyan
Write-Host "Tasa Fallo: $tasaFallo por ciento" -ForegroundColor Yellow
Write-Host ""

# ============================================
# Rendimiento por Maquina
# ============================================
Write-Host "2. RENDIMIENTO POR MAQUINA" -ForegroundColor Magenta
Write-Host "---" -ForegroundColor Magenta

if($machines) {
    $machinesOrdenadas = $machines | Sort-Object "Tasa Exito %" -Descending
    
    $mejorMaquina = $machinesOrdenadas | Select-Object -First 1
    $peorMaquina = $machinesOrdenadas | Select-Object -Last 1
    
    Write-Host "Mejor Maquina: $($mejorMaquina.Maquina) - $($mejorMaquina.'Tasa Exito %') por ciento" -ForegroundColor Green
    Write-Host "Peor Maquina: $($peorMaquina.Maquina) - $($peorMaquina.'Tasa Exito %') por ciento" -ForegroundColor Red
    Write-Host "Total Maquinas: $($machines.Count)" -ForegroundColor White
    
    Write-Host ""
    Write-Host "Ranking de Maquinas:" -ForegroundColor White
    $rank = 1
    foreach($maq in $machinesOrdenadas) {
        $emoji = if($maq."Tasa Exito %" -ge 75) { "OK" } elseif($maq."Tasa Exito %" -ge 50) { "?" } else { "NO" }
        Write-Host "  $rank. $($maq.Maquina): Tests=$($maq.'Total Tests'), OK=$($maq.'Tests Exitosos'), Tasa=$($maq.'Tasa Exito %') por ciento [$emoji]" -ForegroundColor White
        $rank++
    }
} else {
    Write-Host "SIN DATOS DE MAQUINAS" -ForegroundColor Yellow
}
Write-Host ""

# ============================================
# Analisis de Errores
# ============================================
Write-Host "3. DISTRIBUCION DE ERRORES" -ForegroundColor Magenta
Write-Host "---" -ForegroundColor Magenta

if($allSteps) {
    $errorTypes = @($allSteps | Group-Object "Error Type" | Select-Object @{N="Tipo"; E={$_.Name}}, @{N="Cantidad"; E={$_.Count}})
    $totalErrores = (@($allSteps | Where-Object { $_."Error Type" -eq "ERROR" })).Count
    
    Write-Host "Total Pasos Fallidos (ERROR): $totalErrores" -ForegroundColor Red
    
    $errorTypes | Sort-Object Cantidad -Descending | ForEach-Object {
        $porcentaje = [math]::Round(($_.Cantidad / $allSteps.Count) * 100, 2)
        Write-Host "  - $($_.Tipo): $($_.Cantidad) ($porcentaje porciento)" -ForegroundColor White
    }
} else {
    Write-Host "SIN DATOS DE PASOS" -ForegroundColor Yellow
}
Write-Host ""

# ============================================
# Analisis de Tiempos
# ============================================
Write-Host "4. ANALISIS DE PERFORMANCE" -ForegroundColor Magenta
Write-Host "---" -ForegroundColor Magenta

if($allSteps) {
    $tiemposMs = @($allSteps | ForEach-Object { [int]$_."Tiempo (ms)" })
    $tiempoPromedio = [math]::Round(($tiemposMs | Measure-Object -Average).Average, 2)
    $tiempoMax = ($tiemposMs | Measure-Object -Maximum).Maximum
    $tiempoMin = ($tiemposMs | Measure-Object -Minimum).Minimum
    
    $pasosPor1s = (@($allSteps | Where-Object { [int]$_."Tiempo (ms)" -le 1000 })).Count
    $pasosPor5s = (@($allSteps | Where-Object { [int]$_."Tiempo (ms)" -le 5000 })).Count
    $pasosLentos = (@($allSteps | Where-Object { [int]$_."Tiempo (ms)" -gt 5000 })).Count
    
    Write-Host "Tiempo Promedio: $tiempoPromedio ms" -ForegroundColor White
    Write-Host "Tiempo Maximo: $tiempoMax ms" -ForegroundColor Red
    Write-Host "Tiempo Minimo: $tiempoMin ms" -ForegroundColor Green
    Write-Host "Pasos [0-1s]: $pasosPor1s ($([math]::Round(($pasosPor1s / $allSteps.Count) * 100, 2)) porciento)" -ForegroundColor Green
    Write-Host "Pasos [1-5s]: $([int]($pasosPor5s - $pasosPor1s)) ($([math]::Round((($pasosPor5s - $pasosPor1s) / $allSteps.Count) * 100, 2)) porciento)" -ForegroundColor Yellow
    Write-Host "Pasos [5s+]: $pasosLentos ($([math]::Round(($pasosLentos / $allSteps.Count) * 100, 2)) porciento)" -ForegroundColor Red
} else {
    Write-Host "SIN DATOS DE TIEMPOS" -ForegroundColor Yellow
}
Write-Host ""

# ============================================
# Tests Problematicos
# ============================================
Write-Host "5. TESTS MAS PROBLEMATICOS" -ForegroundColor Magenta
Write-Host "---" -ForegroundColor Magenta

$testsFallidos = $stats | Where-Object { $_.Estado -eq "FAILED" } | Sort-Object "Pasos Lentos" -Descending
if($testsFallidos) {
    Write-Host "Total Tests Fallidos: $($testsFallidos.Count)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Top 5 Tests con mas Pasos Lentos:" -ForegroundColor White
    
    $testsFallidos | Select-Object -First 5 | ForEach-Object {
        $testn = if($_.Test.Length -gt 50) { $_.Test.Substring(0, 50) + "..." } else { $_.Test }
        Write-Host "  - $testn" -ForegroundColor Red
        Write-Host "    Maquina: $($_.Maquina), Pasos Lentos: $($_.'Pasos Lentos')/$($_.'Total Pasos')" -ForegroundColor Yellow
    }
} else {
    Write-Host "TODOS LOS TESTS PASARON" -ForegroundColor Green
}
Write-Host ""

# ============================================
# Pasos mas Lentos
# ============================================
Write-Host "6. PASOS MAS LENTOS (BOTTLENECKS)" -ForegroundColor Magenta
Write-Host "---" -ForegroundColor Magenta

if($allSteps) {
    $pasosPorDescripcion = $allSteps | Group-Object Descripcion | ForEach-Object {
        $paso = $_.Name
        $tiemposDelPaso = @($_.Group | ForEach-Object { [int]$_."Tiempo (ms)" })
        $promedio = [math]::Round(($tiemposDelPaso | Measure-Object -Average).Average, 2)
        $max = ($tiemposDelPaso | Measure-Object -Maximum).Maximum
        $errores = (@($_.Group | Where-Object { $_."Error Type" -eq "ERROR" })).Count
        
        [PSCustomObject]@{
            Paso = $paso
            Promedio = $promedio
            Maximo = $max
            Ejecuciones = $_.Count
            Errores = $errores
        }
    } | Sort-Object Promedio -Descending
    
    Write-Host "Top 5 Pasos mas Lentos (promedio):" -ForegroundColor White
    $pasosPorDescripcion | Select-Object -First 5 | ForEach-Object {
        $pasoDesc = if($_.Paso.Length -gt 40) { $_.Paso.Substring(0, 40) + "..." } else { $_.Paso }
        Write-Host "  - $pasoDesc" -ForegroundColor Yellow
        Write-Host "    Promedio: $($_.Promedio)ms, Max: $($_.Maximo)ms, Errores: $($_.Errores)/$($_.Ejecuciones)" -ForegroundColor White
    }
} else {
    Write-Host "SIN DATOS DE PASOS" -ForegroundColor Yellow
}
Write-Host ""

# ============================================
# Indicador de Salud
# ============================================
Write-Host "7. INDICADOR DE SALUD GENERAL" -ForegroundColor Magenta
Write-Host "---" -ForegroundColor Magenta

$indicador = if($tasaExito -ge 90) {
    "EXCELENTE"
} elseif($tasaExito -ge 75) {
    "BUENO"
} elseif($tasaExito -ge 50) {
    "REGULAR"
} else {
    "CRITICO"
}

Write-Host "Salud General: $indicador" -ForegroundColor Green
Write-Host "Confiabilidad: $tasaExito porciento" -ForegroundColor Cyan

if($tasaExito -lt 50) {
    Write-Host ""
    Write-Host "ALERTAS CRITICAS:" -ForegroundColor Red
    Write-Host "  - Tasa de fallo mayor a 50 porciento" -ForegroundColor Red
    Write-Host "  - Revisar maquinas con tasa menor a 50 porciento" -ForegroundColor Red
    Write-Host "  - Investigar pasos con muchos errores" -ForegroundColor Red
}

Write-Host ""
Write-Host "Analisis completado" -ForegroundColor Green
Write-Host ""
