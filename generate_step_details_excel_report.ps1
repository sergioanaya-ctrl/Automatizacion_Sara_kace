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

# Capturar información de máquina y usuario
$machineName = $env:COMPUTERNAME
$userName = $env:USERNAME
$machineUser = "$userName@$machineName"

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

    # Selenium / Launch - WebDriver, browser launch, connection issues
    if ($lower -match "selenium|webdriver|driver executable|session not created|cannot start|cannot launch|chrome not reachable|geckodriver|edge driver|browser not reachable|invalid session id|no such session") {
        return "Selenium / Launch"
    }
    
    # UI / Elementos / Carga - Element locator, visibility, interaction issues
    if ($lower -match "nosuchelement|element not found|not visible|not interactable|element not interactable|stale element|timeoutexception|timeout|wait|load|loading|field.*not|campo.*no|lista.*no|dropdown.*no|select.*no|combo|fieldset|iframe|selector not found|unable to locate|element is not clickable|invisible") {
        return "UI / Elementos / Carga"
    }
    
    # Datos / Feature / Input - Data validation, missing values, invalid input
    if ($lower -match "illegalargumentexception|not a valid|missing.*value|falta valor|required value|no se encontro|no se encontraron|missing resource|missing credentials|null reference|empty value|invalid parameter|parameter.*null|valor.*null") {
        return "Datos / Feature / Input"
    }
    
    # Validacion / Assertion - Assertions and validation errors
    if ($lower -match "assert|assertion|expected.*but.*was|assertion error|assertion failed|java\.lang\.AssertionError|comparison failed|actual value.*expected") {
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
    param([array]$steps, [int]$level = 0, [string]$testName, [string]$batch = "")
    $result = @()
    
    foreach ($step in $steps) {
        $timeMs = [int]$step.duration
        $timeS = Format-WithComma -Value ($timeMs / 1000) -Decimals 2
        $stepDetails = Extract-StepDetails -Description $step.description
        
        # Extraer error del paso si existe
        $stepError = ""
        $stepErrorType = "Sin Error"
        if ($step.result -eq "ERROR" -and $step.error) {
            $stepError = $step.error
            $stepErrorType = Get-ErrorType -message $stepError
        }
        elseif ($step.result -eq "ERROR" -and $step.exception) {
            $stepError = $step.exception
            $stepErrorType = Get-ErrorType -message $stepError
        }
        
        $result += [PSCustomObject]@{
            Test = $testName
            Batch = $batch
            Nivel = $level
            Descripcion = $step.description
            Accion = $stepDetails.Accion
            Elemento = $stepDetails.Elemento
            Valor = $stepDetails.Valor
            Tiempo_ms = $timeMs
            Tiempo_s = $timeS
            Estado = $step.result
            ErrorMessage = $stepError
            ErrorType = $stepErrorType
        }
        
        if ($step.children -and $step.children.Count -gt 0) {
            $result += Extract-TestSteps -steps $step.children -level ($level + 1) -testName $testName -batch $batch
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
                
                # Extraer Batch del tag (batch25, batch50, etc.)
                $batch = ""
                if ($content.tags) {
                    $batchTag = $content.tags | Where-Object { $_.name -like "batch*" } | Select-Object -First 1
                    if ($batchTag) {
                        $batch = $batchTag.name
                    }
                }
                
                $steps = Extract-TestSteps -steps $content.testSteps -testName $testName -batch $batch
                $allSteps += $steps
                
                $slowSteps = $steps | Where-Object { $_.Tiempo_ms -gt 5000 }
                $totalMs = ($steps | Measure-Object -Property Tiempo_ms -Sum).Sum
                $totalMin = Format-WithComma -Value ($totalMs / 60000) -Decimals 2
                
                # Detectar estado del test (si hay algún paso con ERROR, el test es FAILED)
                $errorSteps = $steps | Where-Object { $_.Estado -eq "ERROR" }
                $testState = if ($errorSteps.Count -gt 0) { "FAILED" } else { "PASSED" }
                
                # Obtener el primer error del test (si existe)
                $testErrorMsg = ""
                $testErrorType = "Sin Error"
                if ($errorSteps.Count -gt 0) {
                    $firstError = $errorSteps | Select-Object -First 1
                    $testErrorMsg = $firstError.ErrorMessage
                    $testErrorType = $firstError.ErrorType
                }
                
                $testStats += [PSCustomObject]@{
                    Test = $testName
                    Batch = $batch
                    TotalPasos = $steps.Count
                    PasosLentos = $slowSteps.Count
                    TiempoTotal_min = $totalMin
                    Estado = $testState
                    ErrorType = $testErrorType
                    ErrorMessage = $testErrorMsg
                }
                
                Write-Host "OK: $testName | Batch: $batch"
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
        $summary += [PSCustomObject]@{ Metrica = "Máquina"; Valor = $machineName }
        $summary += [PSCustomObject]@{ Metrica = "Usuario"; Valor = $userName }
        $summary += [PSCustomObject]@{ Metrica = "Total Tests"; Valor = $testStats.Count }
        $summary += [PSCustomObject]@{ Metrica = "Tests Exitosos"; Valor = $passedTests }
        $summary += [PSCustomObject]@{ Metrica = "Tests Fallidos"; Valor = $failedTests }
        $summary += [PSCustomObject]@{ Metrica = "Total Pasos"; Valor = $allSteps.Count }
        $summary += [PSCustomObject]@{ Metrica = "Pasos Lentos (>5s)"; Valor = ($allSteps | Where-Object { $_.Tiempo_ms -gt 5000 }).Count }
        
        $summary | Export-Excel -Path $excelPath -WorksheetName "Resumen" -AutoSize -TableStyle "Light1"
        
        # Hoja 2: Todos los Pasos (CON ERROR TYPE/MESSAGE + BATCH + MAQUINA)
        $stepsForExcel = $allSteps | Select-Object @{N="Test"; E={$_.Test}},
                                   @{N="Batch"; E={$_.Batch}},
                                   @{N="Máquina"; E={$machineName}},
                                   @{N="Usuario"; E={$userName}},
                                   @{N="Descripción Completa"; E={$_.Descripcion}},
                                   @{N="Acción"; E={$_.Accion}},
                                   @{N="Elemento/Campo"; E={if([string]::IsNullOrEmpty($_.Elemento)) { "N/A" } else { $_.Elemento }}},
                                   @{N="Valor Ingresado"; E={if([string]::IsNullOrEmpty($_.Valor)) { "N/A" } else { $_.Valor }}},
                                   @{N="Nivel"; E={$_.Nivel}},
                                   @{N="Tiempo (ms)"; E={$_.Tiempo_ms}},
                                   @{N="Tiempo (s)"; E={$_.Tiempo_s}},
                                   @{N="Estado Paso"; E={$_.Estado}},
                                   @{N="Error Type"; E={if($_.Estado -eq "ERROR") { $_.ErrorType } else { "" }}},
                                   @{N="Error Message"; E={if($_.Estado -eq "ERROR") { $_.ErrorMessage } else { "" }}}
        
        $stepsForExcel | Export-Excel -Path $excelPath -WorksheetName "Todos los Pasos" -AutoSize -TableStyle "Light1" -Append
        
        # Hoja 3: Pasos Lentos (CON ERROR TYPE/MESSAGE + BATCH + MAQUINA)
        $slowSteps = $allSteps | Where-Object { $_.Tiempo_ms -gt 5000 } | Sort-Object Tiempo_ms -Descending
        if ($slowSteps.Count -gt 0) {
            $slowSteps | Select-Object @{N="Test"; E={$_.Test}},
                                       @{N="Batch"; E={$_.Batch}},
                                       @{N="Máquina"; E={$machineName}},
                                       @{N="Usuario"; E={$userName}},
                                       @{N="Descripción Completa"; E={$_.Descripcion}},
                                       @{N="Acción"; E={$_.Accion}},
                                       @{N="Elemento/Campo"; E={if([string]::IsNullOrEmpty($_.Elemento)) { "N/A" } else { $_.Elemento }}},
                                       @{N="Valor Ingresado"; E={if([string]::IsNullOrEmpty($_.Valor)) { "N/A" } else { $_.Valor }}},
                                       @{N="Nivel"; E={$_.Nivel}},
                                       @{N="Tiempo (ms)"; E={$_.Tiempo_ms}},
                                       @{N="Tiempo (s)"; E={$_.Tiempo_s}},
                                       @{N="Estado Paso"; E={$_.Estado}},
                                       @{N="Error Type"; E={if($_.Estado -eq "ERROR") { $_.ErrorType } else { "" }}},
                                       @{N="Error Message"; E={if($_.Estado -eq "ERROR") { $_.ErrorMessage } else { "" }}} | 
                Export-Excel -Path $excelPath -WorksheetName "Pasos Lentos (>5s)" -AutoSize -TableStyle "Light1" -Append
        }
        
        # Hoja 4: Estadísticas por Test (CON ERRORES + BATCH + MAQUINA)
        if ($testStats.Count -gt 0) {
            $testStats | Select-Object @{N="Test"; E={$_.Test}},
                                       @{N="Batch"; E={$_.Batch}},
                                       @{N="Máquina"; E={$machineName}},
                                       @{N="Usuario"; E={$userName}},
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
        
        # Hoja 7: Resumen por Batch
        $batchSummary = $testStats | Where-Object { $_.Batch } | Group-Object Batch | 
                        Select-Object @{N="Batch"; E={$_.Name}},
                                      @{N="Total Tests"; E={$_.Count}},
                                      @{N="Exitosos"; E={($_.Group | Where-Object { $_.Estado -eq "PASSED" }).Count}},
                                      @{N="Fallidos"; E={($_.Group | Where-Object { $_.Estado -eq "FAILED" }).Count}},
                                      @{N="Tasa Error %"; E={if($_.Count -gt 0) { Format-WithComma -Value ((($_.Group | Where-Object { $_.Estado -eq "FAILED" }).Count / $_.Count) * 100) -Decimals 1 } else { "0,00" }}} | 
                        Sort-Object 'Batch'
        
        if ($batchSummary.Count -gt 0) {
            $batchSummary | Export-Excel -Path $excelPath -WorksheetName "Resumen por Batch" -AutoSize -TableStyle "Light1" -Append
        }
        
        # Hoja 6: Tests Fallidos Detallados
        $failedTestsDetails = $testStats | Where-Object { $_.Estado -eq "FAILED" } | 
                              Select-Object @{N="Test"; E={$_.Test}},
                                            @{N="Batch"; E={$_.Batch}},
                                            @{N="Máquina"; E={$machineName}},
                                            @{N="Usuario"; E={$userName}},
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
        Write-Host ("  - Hoja 2: Todos los Pasos (" + $allSteps.Count + " filas + Batch + Error Type/Message)")
        Write-Host ("  - Hoja 3: Pasos Lentos (" + $slowSteps.Count + " pasos >5s + Batch + Error Type/Message)")
        Write-Host ("  - Hoja 4: Estadísticas por Test (" + $testStats.Count + " tests + Batch + Error Type/Message)")
        if ($errorSummary.Count -gt 0) {
            Write-Host ("  - Hoja 5: Resumen de Errores (" + $errorSummary.Count + " categor\u00edas)")
        }
        if ($failedTestsDetails.Count -gt 0) {
            Write-Host ("  - Hoja 6: Tests Fallidos (" + $failedTestsDetails.Count + " tests + Batch)")
        }
        if ($batchSummary.Count -gt 0) {
            Write-Host ("  - Hoja 7: Resumen por Batch (" + $batchSummary.Count + " batches)")
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
        
        # ============================================
        # GENERAR CSV Y HTML COMO ALTERNATIVAS
        # ============================================
        
        # Generar CSV (con Batch + Error Type/Message + Máquina/Usuario)
        $csvPath = "$reportPath\step_details_$timestamp.csv"
        $csvLines = @('"Test","Batch","Maquina","Usuario","Descripcion","Accion","Elemento","Valor","Nivel","Tiempo (ms)","Tiempo (s)","Estado","Error Type","Error Message"')
        
        foreach ($step in $allSteps) {
            $desc = $step.Descripcion -replace '"', '""'
            $errorType = if($step.Estado -eq "ERROR") { $step.ErrorType } else { "" }
            $errorMsg = if($step.Estado -eq "ERROR") { $step.ErrorMessage -replace '"', '""' } else { "" }
            
            $line = "`"$($step.Test)`",`"$($step.Batch)`",`"$machineName`",`"$userName`",`"$desc`",`"$($step.Accion)`",`"$($step.Elemento)`",`"$($step.Valor)`",$($step.Nivel),$($step.Tiempo_ms),$($step.Tiempo_s),`"$($step.Estado)`",`"$errorType`",`"$errorMsg`""
            $csvLines += $line
        }
        
        $csvLines | Out-File -FilePath $csvPath -Encoding UTF8
        Write-Host "  - CSV generado: step_details_$timestamp.csv"
        
        # Generar HTML (con Batch + Error Type/Message)
        $htmlPath = "$reportPath\step_details_$timestamp.html"
        
        # Calcular estadísticas
        $slowSteps = $allSteps | Where-Object { $_.Tiempo_ms -gt 5000 }
        $slowCount = $slowSteps.Count
        $failedCount = $failedTests
        $passedCount = $passedTests
        $totalDuration = ($allSteps | Measure-Object -Property Tiempo_ms -Sum).Sum
        $avgDuration = [math]::Round($totalDuration / $allSteps.Count, 2)
        
        $htmlContent = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SARA3 - Reporte de Detalles de Pasos</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        
        header {
            background: linear-gradient(135deg, #0078d4 0%, #106ebe 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        
        header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .timestamp {
            font-size: 0.9em;
            opacity: 0.9;
        }
        
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 30px;
            background-color: #f8f9fa;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .summary-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #0078d4;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .summary-card.success {
            border-left-color: #107c10;
        }
        
        .summary-card.danger {
            border-left-color: #d83b01;
        }
        
        .summary-card.warning {
            border-left-color: #ff8c00;
        }
        
        .summary-card.info {
            border-left-color: #005a9e;
        }
        
        .summary-card .value {
            font-size: 2em;
            font-weight: bold;
            color: #0078d4;
            margin: 10px 0;
        }
        
        .summary-card.success .value {
            color: #107c10;
        }
        
        .summary-card.danger .value {
            color: #d83b01;
        }
        
        .summary-card.warning .value {
            color: #ff8c00;
        }
        
        .summary-card.info .value {
            color: #005a9e;
        }
        
        .summary-card .label {
            font-size: 0.9em;
            color: #666;
            font-weight: 500;
        }
        
        .tabs {
            display: flex;
            background-color: #f8f9fa;
            border-bottom: 2px solid #e0e0e0;
            overflow-x: auto;
        }
        
        .tab {
            padding: 15px 25px;
            cursor: pointer;
            background: transparent;
            border: none;
            border-bottom: 3px solid transparent;
            font-size: 1em;
            font-weight: 500;
            color: #666;
            transition: all 0.3s;
            white-space: nowrap;
        }
        
        .tab:hover {
            background-color: #e8e8e8;
            color: #0078d4;
        }
        
        .tab.active {
            border-bottom-color: #0078d4;
            color: #0078d4;
            background-color: white;
        }
        
        .content-section {
            display: none;
            padding: 30px;
        }
        
        .content-section.active {
            display: block;
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
            font-size: 0.95em;
        }
        
        .search-box input:focus {
            outline: none;
            border-color: #0078d4;
            box-shadow: 0 0 0 3px rgba(0, 120, 212, 0.1);
        }
        
        .table-wrapper {
            overflow-x: auto;
            margin-top: 20px;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
        }
        
        thead {
            background-color: #0078d4;
            color: white;
            position: sticky;
            top: 0;
            z-index: 10;
        }
        
        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #0078d4;
        }
        
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        tr:hover {
            background-color: #f5f5f5;
        }
        
        .status-pass {
            color: #107c10;
            font-weight: bold;
            background-color: #dff6dd;
            padding: 4px 8px;
            border-radius: 3px;
            display: inline-block;
        }
        
        .status-fail {
            color: #d83b01;
            font-weight: bold;
            background-color: #fed9cc;
            padding: 4px 8px;
            border-radius: 3px;
            display: inline-block;
        }
        
        .time-slow {
            color: #d83b01;
            font-weight: bold;
            background-color: #fdedf0;
            padding: 4px 8px;
            border-radius: 3px;
        }
        
        .error-type {
            padding: 4px 8px;
            border-radius: 3px;
            font-weight: 500;
            font-size: 0.85em;
        }
        
        .error-selenium { background-color: #fff4ce; color: #cc7a00; }
        .error-ui { background-color: #fdeaf1; color: #c50f1f; }
        .error-datos { background-color: #e7f3ff; color: #004b50; }
        .error-validacion { background-color: #f0f6e8; color: #107c10; }
        .error-otros { background-color: #f0f0f0; color: #333; }
        
        .charts-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 30px;
            margin-bottom: 30px;
        }
        
        .chart-box {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .chart-box h3 {
            margin-bottom: 15px;
            color: #333;
            font-size: 1.1em;
        }
        
        canvas {
            max-width: 100%;
        }
        
        .footer {
            padding: 20px 30px;
            background-color: #f8f9fa;
            border-top: 1px solid #e0e0e0;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
        
        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
        }
        
        .filter-badge {
            display: inline-block;
            background: #0078d4;
            color: white;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.85em;
            margin-right: 10px;
        }
        
        @media (max-width: 768px) {
            header h1 {
                font-size: 1.8em;
            }
            
            .summary-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 15px;
                padding: 15px;
            }
            
            .charts-container {
                grid-template-columns: 1fr;
            }
            
            th, td {
                padding: 10px 5px;
                font-size: 0.85em;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>&#x1F4CA; SARA3 - Reporte de Detalles de Pasos</h1>
            <div class="timestamp">Generado: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")</div>
        </header>
        
        <div class="summary-grid">
            <div class="summary-card info">
                <div class="label">Total Tests</div>
                <div class="value">$($testStats.Count)</div>
            </div>
            <div class="summary-card success">
                <div class="label">Tests Exitosos</div>
                <div class="value">$passedCount</div>
            </div>
            <div class="summary-card danger">
                <div class="label">Tests Fallidos</div>
                <div class="value">$failedCount</div>
            </div>
            <div class="summary-card info">
                <div class="label">Total Pasos</div>
                <div class="value">$($allSteps.Count)</div>
            </div>
            <div class="summary-card warning">
                <div class="label">Pasos Lentos (>5s)</div>
                <div class="value">$slowCount</div>
            </div>
            <div class="summary-card info">
                <div class="label">Duración Promedio</div>
                <div class="value">${avgDuration}ms</div>
            </div>
            <div class="summary-card info">
                <div class="label">Máquina</div>
                <div class="value" style="font-size: 1.2em;">$machineName</div>
            </div>
            <div class="summary-card info">
                <div class="label">Usuario</div>
                <div class="value" style="font-size: 1.2em;">$userName</div>
            </div>
        </div>
        
        <div class="tabs">
            <button class="tab active" onclick="switchTab('all-steps', this)">&#x1F4CB; Todos los Pasos</button>
            <button class="tab" onclick="switchTab('slow-steps', this)">&#x1F422; Pasos Lentos</button>
            <button class="tab" onclick="switchTab('failed-tests', this)">&#x274C; Tests Fallidos</button>
            <button class="tab" onclick="switchTab('statistics', this)">&#x1F4C8; Estadísticas</button>
        </div>
        
        <!-- Todos los Pasos -->
        <div id="all-steps" class="content-section active">
            <div class="search-box">
                <input type="text" placeholder="Buscar por test, descripción, error..." id="searchInput" onkeyup="filterTable('all-steps-table')">
            </div>
            <div class="table-wrapper">
                <table id="all-steps-table">
                    <thead>
                        <tr>
                            <th>Test</th>
                            <th>Batch</th>
                            <th>Máquina</th>
                            <th>Usuario</th>
                            <th>Descripción</th>
                            <th>Acción</th>
                            <th>Elemento</th>
                            <th>Tiempo (ms)</th>
                            <th>Estado</th>
                            <th>Error Type</th>
                        </tr>
                    </thead>
                    <tbody>
"@
        
        foreach ($step in $allSteps) {
            $errorType = if($testErrorMap.ContainsKey($step.Test)) { $testErrorMap[$step.Test].ErrorType } else { "Sin Error" }
            $stateClass = if($step.Estado -eq "PASSED") { "status-pass" } else { "status-fail" }
            $timeClass = if($step.Tiempo_ms -gt 5000) { "time-slow" } else { "" }
            $errorClass = "error-otros"
            if ($errorType -match "Selenium") { $errorClass = "error-selenium" }
            elseif ($errorType -match "UI") { $errorClass = "error-ui" }
            elseif ($errorType -match "Datos") { $errorClass = "error-datos" }
            elseif ($errorType -match "Validacion") { $errorClass = "error-validacion" }
            
            $htmlContent += @"
                        <tr>
                            <td><strong>$($step.Test)</strong></td>
                            <td>$($step.Batch)</td>
                            <td>$machineName</td>
                            <td>$userName</td>
                            <td title="$($step.Descripcion)">$($step.Descripcion.Substring(0, [Math]::Min(50, $step.Descripcion.Length)))...</td>
                            <td>$($step.Accion)</td>
                            <td>$(if([string]::IsNullOrEmpty($step.Elemento)) { "-" } else { $step.Elemento })</td>
                            <td class="$timeClass">$($step.Tiempo_ms)</td>
                            <td><span class="$stateClass">$($step.Estado)</span></td>
                            <td><span class="error-type $errorClass">$errorType</span></td>
                        </tr>
"@
        }
        
        $htmlContent += @"
                    </tbody>
                </table>
            </div>
        </div>
        
        <!-- Pasos Lentos -->
        <div id="slow-steps" class="content-section">
            <div class="table-wrapper">
"@
        
        if ($slowSteps.Count -gt 0) {
            $htmlContent += @"
                <table>
                    <thead>
                        <tr>
                            <th>Test</th>
                            <th>Batch</th>
                            <th>Máquina</th>
                            <th>Usuario</th>
                            <th>Descripción</th>
                            <th>Acción</th>
                            <th>Elemento</th>
                            <th>Tiempo (ms)</th>
                            <th>Tiempo (s)</th>
                            <th>Error Type</th>
                        </tr>
                    </thead>
                    <tbody>
"@
            foreach ($step in ($slowSteps | Sort-Object Tiempo_ms -Descending)) {
                $errorType = if($testErrorMap.ContainsKey($step.Test)) { $testErrorMap[$step.Test].ErrorType } else { "Sin Error" }
                $errorClass = "error-otros"
                if ($errorType -match "Selenium") { $errorClass = "error-selenium" }
                elseif ($errorType -match "UI") { $errorClass = "error-ui" }
                elseif ($errorType -match "Datos") { $errorClass = "error-datos" }
                elseif ($errorType -match "Validacion") { $errorClass = "error-validacion" }
                
                $htmlContent += @"
                        <tr>
                            <td><strong>$($step.Test)</strong></td>
                            <td>$($step.Batch)</td>
                            <td>$machineName</td>
                            <td>$userName</td>
                            <td title="$($step.Descripcion)">$($step.Descripcion.Substring(0, [Math]::Min(50, $step.Descripcion.Length)))...</td>
                            <td>$($step.Accion)</td>
                            <td>$(if([string]::IsNullOrEmpty($step.Elemento)) { "-" } else { $step.Elemento })</td>
                            <td class="time-slow">$($step.Tiempo_ms)</td>
                            <td class="time-slow">$($step.Tiempo_s)</td>
                            <td><span class="error-type $errorClass">$errorType</span></td>
                        </tr>
"@
            }
            $htmlContent += @"
                    </tbody>
                </table>
"@
        } else {
            $htmlContent += @"
                <div class="no-data">
                    <p>&#x2713; No hay pasos lentos. Todos los pasos se ejecutaron rápidamente (< 5s)</p>
                </div>
"@
        }
        
        $htmlContent += @"
            </div>
        </div>
        
        <!-- Tests Fallidos -->
        <div id="failed-tests" class="content-section">
            <div class="table-wrapper">
"@
        
        if ($failedTests -gt 0) {
            $failedTestList = $testStats | Where-Object { $_.Estado -eq "FAILED" }
            $htmlContent += @"
                <table>
                    <thead>
                        <tr>
                            <th>Test</th>
                            <th>Batch</th>
                            <th>Máquina</th>
                            <th>Usuario</th>
                            <th>Total Pasos</th>
                            <th>Pasos Fallidos</th>
                            <th>Duración (s)</th>
                            <th>Error Type</th>
                            <th>Error Message</th>
                        </tr>
                    </thead>
                    <tbody>
"@
            foreach ($test in $failedTestList) {
                $testErrorInfo = $testErrorMap[$test.Test]
                $errorClass = "error-otros"
                if ($testErrorInfo.ErrorType -match "Selenium") { $errorClass = "error-selenium" }
                elseif ($testErrorInfo.ErrorType -match "UI") { $errorClass = "error-ui" }
                elseif ($testErrorInfo.ErrorType -match "Datos") { $errorClass = "error-datos" }
                elseif ($testErrorInfo.ErrorType -match "Validacion") { $errorClass = "error-validacion" }
                
                $failedSteps = $allSteps | Where-Object { $_.Test -eq $test.Test -and $_.Estado -eq "FAILED" }
                $htmlContent += @"
                        <tr>
                            <td><strong>$($test.Test)</strong></td>
                            <td>$($test.Batch)</td>
                            <td>$machineName</td>
                            <td>$userName</td>
                            <td>$($allSteps | Where-Object { $_.Test -eq $test.Test }).Count</td>
                            <td class="status-fail">$($failedSteps.Count)</td>
                            <td>$(($allSteps | Where-Object { $_.Test -eq $test.Test } | Measure-Object -Property Tiempo_ms -Sum).Sum / 1000)</td>
                            <td><span class="error-type $errorClass">$($testErrorInfo.ErrorType)</span></td>
                            <td title="$($testErrorInfo.ErrorMessage)">$($testErrorInfo.ErrorMessage.Substring(0, [Math]::Min(60, $testErrorInfo.ErrorMessage.Length)))...</td>
                        </tr>
"@
            }
            $htmlContent += @"
                    </tbody>
                </table>
"@
        } else {
            $htmlContent += @"
                <div class="no-data">
                    <p>&#x2713; Excelente! Todos los tests pasaron correctamente.</p>
                </div>
"@
        }
        
        $htmlContent += @"
            </div>
        </div>
        
        <!-- Estadísticas -->
        <div id="statistics" class="content-section">
            <div class="charts-container">
                <div class="chart-box">
                    <h3>&#x1F4C8; Distribución de Estados</h3>
                    <canvas id="stateChart"></canvas>
                </div>
                <div class="chart-box">
                    <h3>&#x274C; Distribución de Errores</h3>
                    <canvas id="errorChart"></canvas>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>Reporte generado automáticamente por SARA3 Test Automation Framework</p>
            <p>Timestamp: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")</p>
        </div>
    </div>
    
    <script>
        function switchTab(tabName, element) {
            const sections = document.querySelectorAll('.content-section');
            sections.forEach(s => s.classList.remove('active'));
            document.getElementById(tabName).classList.add('active');
            
            const tabs = document.querySelectorAll('.tab');
            tabs.forEach(t => t.classList.remove('active'));
            element.classList.add('active');
            
            if (tabName === 'statistics') {
                initCharts();
            }
        }
        
        function filterTable(tableId) {
            const input = document.getElementById('searchInput');
            const filter = input.value.toUpperCase();
            const table = document.getElementById(tableId);
            const rows = table.getElementsByTagName('tr');
            
            for (let i = 1; i < rows.length; i++) {
                const text = rows[i].textContent || rows[i].innerText;
                rows[i].style.display = text.toUpperCase().includes(filter) ? '' : 'none';
            }
        }
        
        function initCharts() {
            // Gráfico de estados
            const stateCtx = document.getElementById('stateChart');
            if (stateCtx && !stateCtx.chart) {
                stateCtx.chart = new Chart(stateCtx, {
                    type: 'doughnut',
                    data: {
                        labels: ['Exitosos', 'Fallidos'],
                        datasets: [{
                            data: [$passedCount, $failedCount],
                            backgroundColor: ['#107c10', '#d83b01'],
                            borderColor: ['#107c10', '#d83b01']
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            legend: { position: 'bottom' }
                        }
                    }
                });
            }
            
            // Gráfico de errores
            const errorCtx = document.getElementById('errorChart');
            if (errorCtx && !errorCtx.chart) {
                errorCtx.chart = new Chart(errorCtx, {
                    type: 'bar',
                    data: {
                        labels: [
"@
            
            foreach ($error in $errorSummary) {
                $htmlContent += @"
                            '$($error.'Error Type')',
"@
            }
            
            $htmlContent += @"
                        ],
                        datasets: [{
                            label: 'Cantidad',
                            data: [
"@
            
            foreach ($error in $errorSummary) {
                $htmlContent += @"
                                $($error.Cantidad),
"@
            }
            
            $htmlContent += @"
                            ],
                            backgroundColor: [
                                '#fff4ce',
                                '#fdeaf1',
                                '#e7f3ff',
                                '#f0f6e8',
                                '#f0f0f0'
                            ]
                        }]
                    },
                    options: {
                        responsive: true,
                        indexAxis: 'y',
                        plugins: {
                            legend: { display: false }
                        }
                    }
                });
            }
        }
    </script>
</body>
</html>
"@
        
        $htmlContent | Out-File -FilePath $htmlPath -Encoding UTF8
        Write-Host "  - HTML generado: step_details_$timestamp.html"
        
    } else {
        Write-Host "INFO: ImportExcel no disponible. Instala con: Install-Module ImportExcel"
        Write-Host "      Generando CSV y HTML en su lugar..."
        
        # Generar CSV como alternativa (con Batch + Error Type/Message)
        $csvPath = "$reportPath\step_details_$timestamp.csv"
        $lines = @('"Test","Batch","Descripcion","Accion","Elemento","Valor","Nivel","Tiempo (ms)","Tiempo (s)","Estado","Error Type","Error Message"')
        
        foreach ($step in $allSteps) {
            $desc = $step.Descripcion -replace '"', '""'
            $errorType = if($step.Estado -eq "ERROR") { $step.ErrorType } else { "" }
            $errorMsg = if($step.Estado -eq "ERROR") { $step.ErrorMessage -replace '"', '""' } else { "" }
            
            $line = "`"$($step.Test)`",`"$($step.Batch)`",`"$desc`",`"$($step.Accion)`",`"$($step.Elemento)`",`"$($step.Valor)`",$($step.Nivel),$($step.Tiempo_ms),$($step.Tiempo_s),`"$($step.Estado)`",`"$errorType`",`"$errorMsg`""
            $lines += $line
        }
        
        $lines | Out-File -FilePath $csvPath -Encoding UTF8
        Write-Host "OK: CSV generado: $csvPath (con Batch + Error Type/Message)"
    }
}
catch {
    Write-Host "ERROR: $_"
}

Write-Host "====== REPORTE COMPLETADO ======"
