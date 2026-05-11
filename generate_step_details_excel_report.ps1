# ============================================
# Generate Step Details Excel Report
# ============================================

param(
    [string]$serenityPath = ".\target\site\serenity",
    [string]$reportPath = ".\target\reports",
    [string]$junitPath = ".\build\test-results\test",
    [bool]$useImportExcel = $true
)

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

if (-not (Test-Path $reportPath)) {
    New-Item -ItemType Directory -Path $reportPath | Out-Null
}

# ============================================
# FUNCIÓN DE CLASIFICACIÓN DE ERRORES
# ============================================
function Get-ErrorType {
    param([string]$message)
    if ([string]::IsNullOrWhiteSpace($message)) { return "Sin Error" }

    $lower = $message.ToLower()

    if ($lower -match "selenium|webdriver|driver executable|session not created|cannot start|cannot launch|chrome not reachable|geckodriver|edge driver|browser not reachable") {
        return "Selenium / Launch"
    }
    if ($lower -match "nosuchelement|element not found|not visible|not interactable|element not interactable|stale element|timeoutexception|timeout|wait|load|loading|field.*not|campo.*no|lista.*no|dropdown.*no|select.*no") {
        return "UI / Elementos / Carga"
    }
    if ($lower -match "illegalargumentexception|not a valid|missing.*value|falta valor|required value|no se encontro|no se encontraron|missing resource|missing credentials") {
        return "Datos / Feature / Input"
    }
    if ($lower -match "assert|assertion|expected.*but.*was|assertion error|assertion failed") {
        return "Validacion / Assertion"
    }
    return "Otros"
}

function Format-WithComma {
    param([double]$Value, [int]$Decimals = 2)
    $rounded = [math]::Round($Value, $Decimals)
    return $rounded.ToString("N$Decimals", [System.Globalization.CultureInfo]::GetCultureInfo("es-CO"))
}

function Extract-StepDetails {
    param([string]$Description)
    
    $actionType = "Otra"
    $element = ""
    $value = ""
    
    if ($Description -like "*enters*") {
        $actionType = "Escribe"
        if ($Description -match "'([^']*)'.*into\s+(.+)") {
            $value = $matches[1]
            $element = $matches[2]
        }
    }
    elseif ($Description -like "*clicks*" -or $Description -like "*click*") {
        $actionType = "Click/Selecciona"
        # Patrones: "clicks on Element" o "click Element"
        if ($Description -match "on\s+(.+)$") {
            $element = $matches[1]
        }
        elseif ($Description -match "click\s+(.+)$") {
            $element = $matches[1]
        }
    }
    elseif ($Description -like "*switch*") {
        $actionType = "Navega/Cambia"
        if ($Description -match "to\s+(.+)") {
            $element = $matches[1]
        }
    }
    elseif ($Description -like "*open*") {
        $actionType = "Abre"
        if ($Description -match "at\s+(.+)") {
            $element = $matches[1]
        }
    }
    elseif ($Description -like "*fill*") {
        $actionType = "Completa"
        $element = $Description
    }
    elseif ($Description -like "*And*" -or $Description -like "*Given*" -or $Description -like "*When*") {
        $actionType = "Ejecuta"
        $element = $Description
    }
    
    return @{
        Accion = $actionType
        Elemento = $element
        Valor = $value
    }
}

function Extract-TestSteps {
    param([array]$steps, [int]$level = 0, [string]$testName)
    $result = @()
    
    foreach ($step in $steps) {
        $timeMs = [int]$step.duration
        $timeS = Format-WithComma -Value ($timeMs / 1000) -Decimals 2
        $stepDetails = Extract-StepDetails -Description $step.description
        
        $result += [PSCustomObject]@{
            Test = $testName
            Nivel = $level
            Descripcion = $step.description
            Accion = $stepDetails.Accion
            Elemento = $stepDetails.Elemento
            Valor = $stepDetails.Valor
            Tiempo_ms = $timeMs
            Tiempo_s = $timeS
            Estado = $step.result
        }
        
        if ($step.children -and $step.children.Count -gt 0) {
            $result += Extract-TestSteps -steps $step.children -level ($level + 1) -testName $testName
        }
    }
    return $result
}


Write-Host "====== Generando Excel con detalles de pasos ======"

$allSteps = @()
$testStats = @()

# ============================================
# LEER DATOS DE SERENITY JSON
# ============================================
if (Test-Path $serenityPath) {
    $jsonFiles = Get-ChildItem "$serenityPath\*.json" -ErrorAction SilentlyContinue
    
    foreach ($jsonFile in $jsonFiles) {
        try {
            $content = Get-Content $jsonFile -Raw -Encoding UTF8 | ConvertFrom-Json
            
            if ($content.testSteps) {
                $testName = $content.title
                $steps = Extract-TestSteps -steps $content.testSteps -testName $testName
                $allSteps += $steps
                
                $slowSteps = $steps | Where-Object { $_.Tiempo_ms -gt 5000 }
                $totalMs = ($steps | Measure-Object -Property Tiempo_ms -Sum).Sum
                $totalMin = Format-WithComma -Value ($totalMs / 60000) -Decimals 2
                
                $testStats += [PSCustomObject]@{
                    Test = $testName
                    TotalPasos = $steps.Count
                    PasosLentos = $slowSteps.Count
                    TiempoTotal_min = $totalMin
                    Estado = "PASSED"
                    ErrorType = "Sin Error"
                    ErrorMessage = ""
                }
                
                Write-Host "OK: $testName"
            }
        }
        catch {
            Write-Host "ERROR procesando $($jsonFile.Name): $_"
        }
    }
}

# ============================================
# LEER ERRORES DE JUNIT XML
# ============================================
Write-Host "\n====== Leyendo errores de JUnit XML ======"
$testErrors = @{}

if (Test-Path $junitPath) {
    $xmlFiles = Get-ChildItem "$junitPath\*.xml" -ErrorAction SilentlyContinue
    
    foreach ($xmlFile in $xmlFiles) {
        try {
            [xml]$xml = Get-Content $xmlFile -Encoding UTF8
            
            foreach ($testcase in $xml.testsuite.testcase) {
                $testName = $testcase.name
                $duration = [double]$testcase.time
                
                if ($testcase.failure) {
                    $errorMsg = $testcase.failure.message
                    if (-not $errorMsg) { $errorMsg = $testcase.failure.InnerText }
                    
                    $testErrors[$testName] = @{
                        Status = "FAILED"
                        ErrorMessage = $errorMsg
                        ErrorType = Get-ErrorType -message $errorMsg
                        Duration = $duration
                    }
                    Write-Host "ERROR detectado: $testName - $(Get-ErrorType -message $errorMsg)" -ForegroundColor Yellow
                }
            }
        }
        catch {
            Write-Host "ERROR leyendo XML $($xmlFile.Name): $_" -ForegroundColor Red
        }
    }
}

# ============================================
# CORRELACIONAR ERRORES CON ESTADÍSTICAS
# ============================================
Write-Host "\n====== Correlacionando errores con tests ======"

# Crear mapa de errores por test para lookup rápido
$testErrorMap = @{}

foreach ($stat in $testStats) {
    if ($testErrors.ContainsKey($stat.Test)) {
        $stat.Estado = $testErrors[$stat.Test].Status
        $stat.ErrorType = $testErrors[$stat.Test].ErrorType
        $stat.ErrorMessage = $testErrors[$stat.Test].ErrorMessage
        
        # Guardar en mapa para los pasos
        $testErrorMap[$stat.Test] = @{
            ErrorType = $stat.ErrorType
            ErrorMessage = $stat.ErrorMessage
        }
        
        Write-Host "Correlación OK: $($stat.Test) - $($stat.ErrorType)" -ForegroundColor Cyan
    } else {
        # Test sin error
        $testErrorMap[$stat.Test] = @{
            ErrorType = "Sin Error"
            ErrorMessage = ""
        }
    }
}

# ============================================
# GENERAR EXCEL
# ============================================

try {
    $importExcelAvailable = Get-Module -ListAvailable -Name ImportExcel
    
    if ($importExcelAvailable) {
        Import-Module ImportExcel -ErrorAction SilentlyContinue
        
        $excelPath = "$reportPath\step_details_$timestamp.xlsx"
        
        # Crear Excel con múltiples hojas
        
        # Hoja 1: Resumen
        $failedTests = ($testStats | Where-Object { $_.Estado -eq "FAILED" }).Count
        $passedTests = ($testStats | Where-Object { $_.Estado -eq "PASSED" }).Count
        
        $summary = @()
        $summary += [PSCustomObject]@{ Metrica = "Fecha y Hora"; Valor = (Get-Date -Format "dd/MM/yyyy HH:mm:ss") }
        $summary += [PSCustomObject]@{ Metrica = "Total Tests"; Valor = $testStats.Count }
        $summary += [PSCustomObject]@{ Metrica = "Tests Exitosos"; Valor = $passedTests }
        $summary += [PSCustomObject]@{ Metrica = "Tests Fallidos"; Valor = $failedTests }
        $summary += [PSCustomObject]@{ Metrica = "Total Pasos"; Valor = $allSteps.Count }
        $summary += [PSCustomObject]@{ Metrica = "Pasos Lentos (>5s)"; Valor = ($allSteps | Where-Object { $_.Tiempo_ms -gt 5000 }).Count }
        
        $summary | Export-Excel -Path $excelPath -WorksheetName "Resumen" -AutoSize -TableStyle "Light1"
        
        # Hoja 2: Todos los Pasos (CON ERROR TYPE/MESSAGE)
        $stepsForExcel = $allSteps | Select-Object @{N="Test"; E={$_.Test}},
                                   @{N="Descripción Completa"; E={$_.Descripcion}},
                                   @{N="Acción"; E={$_.Accion}},
                                   @{N="Elemento/Campo"; E={if([string]::IsNullOrEmpty($_.Elemento)) { "N/A" } else { $_.Elemento }}},
                                   @{N="Valor Ingresado"; E={if([string]::IsNullOrEmpty($_.Valor)) { "N/A" } else { $_.Valor }}},
                                   @{N="Nivel"; E={$_.Nivel}},
                                   @{N="Tiempo (ms)"; E={$_.Tiempo_ms}},
                                   @{N="Tiempo (s)"; E={$_.Tiempo_s}},
                                   @{N="Estado Paso"; E={$_.Estado}},
                                   @{N="Error Type"; E={if($testErrorMap.ContainsKey($_.Test)) { $testErrorMap[$_.Test].ErrorType } else { "Sin Error" }}},
                                   @{N="Error Message"; E={if($testErrorMap.ContainsKey($_.Test)) { $testErrorMap[$_.Test].ErrorMessage } else { "" }}}
        
        $stepsForExcel | Export-Excel -Path $excelPath -WorksheetName "Todos los Pasos" -AutoSize -TableStyle "Light1" -Append
        
        # Hoja 3: Pasos Lentos (CON ERROR TYPE/MESSAGE)
        $slowSteps = $allSteps | Where-Object { $_.Tiempo_ms -gt 5000 } | Sort-Object Tiempo_ms -Descending
        if ($slowSteps.Count -gt 0) {
            $slowSteps | Select-Object @{N="Test"; E={$_.Test}},
                                       @{N="Descripción Completa"; E={$_.Descripcion}},
                                       @{N="Acción"; E={$_.Accion}},
                                       @{N="Elemento/Campo"; E={if([string]::IsNullOrEmpty($_.Elemento)) { "N/A" } else { $_.Elemento }}},
                                       @{N="Valor Ingresado"; E={if([string]::IsNullOrEmpty($_.Valor)) { "N/A" } else { $_.Valor }}},
                                       @{N="Nivel"; E={$_.Nivel}},
                                       @{N="Tiempo (ms)"; E={$_.Tiempo_ms}},
                                       @{N="Tiempo (s)"; E={$_.Tiempo_s}},
                                       @{N="Estado Paso"; E={$_.Estado}},
                                       @{N="Error Type"; E={if($testErrorMap.ContainsKey($_.Test)) { $testErrorMap[$_.Test].ErrorType } else { "Sin Error" }}},
                                       @{N="Error Message"; E={if($testErrorMap.ContainsKey($_.Test)) { $testErrorMap[$_.Test].ErrorMessage } else { "" }}} | 
                Export-Excel -Path $excelPath -WorksheetName "Pasos Lentos (>5s)" -AutoSize -TableStyle "Light1" -Append
        }
        
        # Hoja 4: Estadísticas por Test (CON ERRORES)
        if ($testStats.Count -gt 0) {
            $testStats | Select-Object @{N="Test"; E={$_.Test}},
                                       @{N="Total Pasos"; E={$_.TotalPasos}},
                                       @{N="Pasos Lentos"; E={$_.PasosLentos}},
                                       @{N="Tiempo Total (min)"; E={$_.TiempoTotal_min}},
                                       @{N="Estado"; E={$_.Estado}},
                                       @{N="Error Type"; E={$_.ErrorType}},
                                       @{N="Error Message"; E={$_.ErrorMessage}} | 
                Export-Excel -Path $excelPath -WorksheetName "Estadísticas por Test" -AutoSize -TableStyle "Light1" -Append
        }
        
        # Hoja 5: Resumen de Errores
        $errorSummary = $testStats | Where-Object { $_.Estado -eq "FAILED" } | 
                        Group-Object ErrorType | 
                        Select-Object @{N="Error Type"; E={$_.Name}},
                                      @{N="Cantidad"; E={$_.Count}},
                                      @{N="Porcentaje"; E={Format-WithComma -Value (($_.Count / $failedTests) * 100) -Decimals 1}} | 
                        Sort-Object Cantidad -Descending
        
        if ($errorSummary.Count -gt 0) {
            $errorSummary | Export-Excel -Path $excelPath -WorksheetName "Resumen de Errores" -AutoSize -TableStyle "Light1" -Append
        }
        
        # Hoja 6: Tests Fallidos Detallados
        $failedTestsDetails = $testStats | Where-Object { $_.Estado -eq "FAILED" } | 
                              Select-Object @{N="Test"; E={$_.Test}},
                                            @{N="Tiempo Total (min)"; E={$_.TiempoTotal_min}},
                                            @{N="Total Pasos"; E={$_.TotalPasos}},
                                            @{N="Pasos Lentos"; E={$_.PasosLentos}},
                                            @{N="Error Type"; E={$_.ErrorType}},
                                            @{N="Error Message"; E={$_.ErrorMessage}}
        
        if ($failedTestsDetails.Count -gt 0) {
            $failedTestsDetails | Export-Excel -Path $excelPath -WorksheetName "Tests Fallidos" -AutoSize -TableStyle "Light1" -Append
        }
        
        Write-Host ""
        Write-Host "====================================" -ForegroundColor Green
        Write-Host "OK: Excel unificado generado" -ForegroundColor Green
        Write-Host "====================================" -ForegroundColor Green
        Write-Host "Archivo: $excelPath" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "HOJAS GENERADAS:"
        Write-Host ("  - Hoja 1: Resumen (Tests: " + $testStats.Count + ", Fallidos: " + $failedTests + ")")
        Write-Host ("  - Hoja 2: Todos los Pasos (" + $allSteps.Count + " filas + Error Type/Message)")
        Write-Host ("  - Hoja 3: Pasos Lentos (" + $slowSteps.Count + " pasos >5s + Error Type/Message)")
        Write-Host ("  - Hoja 4: Estadisticas por Test (" + $testStats.Count + " tests + Error Type/Message)")
        if ($errorSummary.Count -gt 0) {
            Write-Host ("  - Hoja 5: Resumen de Errores (" + $errorSummary.Count + " categorias)")
        }
        if ($failedTestsDetails.Count -gt 0) {
            Write-Host ("  - Hoja 6: Tests Fallidos (" + $failedTestsDetails.Count + " tests detallados)")
        }
        Write-Host ""
        Write-Host "CLASIFICACION DE ERRORES:"
        foreach ($error in $errorSummary) {
            $errorType = $error.'Error Type'
            $errorCant = $error.Cantidad
            $errorPorc = $error.Porcentaje
            Write-Host "  - $errorType : $errorCant ($errorPorc%)" -ForegroundColor Yellow
        }
        Write-Host ""
        
    } else {
        Write-Host "INFO: ImportExcel no disponible. Instala con: Install-Module ImportExcel"
        Write-Host "      Generando CSV en su lugar..."
        
        # Generar CSV como alternativa (con Error Type/Message)
        $csvPath = "$reportPath\step_details_$timestamp.csv"
        $lines = @('"Test","Descripcion","Accion","Elemento","Valor","Nivel","Tiempo (ms)","Tiempo (s)","Estado","Error Type","Error Message"')
        
        foreach ($step in $allSteps) {
            $desc = $step.Descripcion -replace '"', '""'
            $errorType = if($testErrorMap.ContainsKey($step.Test)) { $testErrorMap[$step.Test].ErrorType } else { "Sin Error" }
            $errorMsg = if($testErrorMap.ContainsKey($step.Test)) { $testErrorMap[$step.Test].ErrorMessage -replace '"', '""' } else { "" }
            
            $line = "`"$($step.Test)`",`"$desc`",`"$($step.Accion)`",`"$($step.Elemento)`",`"$($step.Valor)`",$($step.Nivel),$($step.Tiempo_ms),$($step.Tiempo_s),`"$($step.Estado)`",`"$errorType`",`"$errorMsg`""
            $lines += $line
        }
        
        $lines | Out-File -FilePath $csvPath -Encoding UTF8
        Write-Host "OK: CSV generado: $csvPath (con Error Type/Message)"
    }
}
catch {
    Write-Host "ERROR: $_"
}

Write-Host "====== REPORTE COMPLETADO ======"
