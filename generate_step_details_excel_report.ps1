# ============================================
# Generate Step Details Excel Report
# ============================================

param(
    [string]$serenityPath = ".\target\site\serenity",
    [string]$reportPath = ".\target\reports",
    [bool]$useImportExcel = $true
)

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

if (-not (Test-Path $reportPath)) {
    New-Item -ItemType Directory -Path $reportPath | Out-Null
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
# GENERAR EXCEL
# ============================================

try {
    $importExcelAvailable = Get-Module -ListAvailable -Name ImportExcel
    
    if ($importExcelAvailable) {
        Import-Module ImportExcel -ErrorAction SilentlyContinue
        
        $excelPath = "$reportPath\step_details_$timestamp.xlsx"
        
        # Crear Excel con múltiples hojas
        
        # Hoja 1: Resumen
        $summary = @()
        $summary += [PSCustomObject]@{ Metrica = "Fecha y Hora"; Valor = (Get-Date -Format "dd/MM/yyyy HH:mm:ss") }
        $summary += [PSCustomObject]@{ Metrica = "Total Tests"; Valor = $testStats.Count }
        $summary += [PSCustomObject]@{ Metrica = "Total Pasos"; Valor = $allSteps.Count }
        $summary += [PSCustomObject]@{ Metrica = "Pasos Lentos (>5s)"; Valor = ($allSteps | Where-Object { $_.Tiempo_ms -gt 5000 }).Count }
        
        $summary | Export-Excel -Path $excelPath -WorksheetName "Resumen" -AutoSize -TableStyle "Light1"
        
        # Hoja 2: Todos los Pasos
        $stepsForExcel = $allSteps | Select-Object @{N="Test"; E={$_.Test}},
                                   @{N="Descripción Completa"; E={$_.Descripcion}},
                                   @{N="Acción"; E={$_.Accion}},
                                   @{N="Elemento/Campo"; E={if([string]::IsNullOrEmpty($_.Elemento)) { "N/A" } else { $_.Elemento }}},
                                   @{N="Valor Ingresado"; E={if([string]::IsNullOrEmpty($_.Valor)) { "N/A" } else { $_.Valor }}},
                                   @{N="Nivel"; E={$_.Nivel}},
                                   @{N="Tiempo (ms)"; E={$_.Tiempo_ms}},
                                   @{N="Tiempo (s)"; E={$_.Tiempo_s}},
                                   @{N="Estado"; E={$_.Estado}}
        
        $stepsForExcel | Export-Excel -Path $excelPath -WorksheetName "Todos los Pasos" -AutoSize -TableStyle "Light1" -Append
        
        # Hoja 3: Pasos Lentos
        $slowSteps = $allSteps | Where-Object { $_.Tiempo_ms -gt 5000 } | Sort-Object Tiempo_ms -Descending | Select-Object -First 50
        if ($slowSteps.Count -gt 0) {
            $slowSteps | Select-Object @{N="Test"; E={$_.Test.Substring(0, [Math]::Min(40, $_.Test.Length))}},
                                       @{N="Descripción"; E={$_.Descripcion.Substring(0, 80)}},
                                       @{N="Tiempo (ms)"; E={$_.Tiempo_ms}},
                                       @{N="Tiempo (s)"; E={$_.Tiempo_s}},
                                       @{N="Estado"; E={$_.Estado}} | 
                Export-Excel -Path $excelPath -WorksheetName "Pasos Lentos (>5s)" -AutoSize -TableStyle "Light1" -Append
        }
        
        # Hoja 4: Estadísticas por Test
        if ($testStats.Count -gt 0) {
            $testStats | Select-Object @{N="Test"; E={$_.Test}},
                                       @{N="Total Pasos"; E={$_.TotalPasos}},
                                       @{N="Pasos Lentos"; E={$_.PasosLentos}},
                                       @{N="Tiempo Total (min)"; E={$_.TiempoTotal_min}} | 
                Export-Excel -Path $excelPath -WorksheetName "Estadísticas por Test" -AutoSize -TableStyle "Light1" -Append
        }
        
        Write-Host ""
        Write-Host "OK: Excel generado: $excelPath"
        Write-Host "  - Hoja 1: Resumen"
        Write-Host "  - Hoja 2: Todos los Pasos ($($allSteps.Count))"
        Write-Host "  - Hoja 3: Pasos Lentos ($($slowSteps.Count))"
        if ($testStats.Count -gt 0) {
            Write-Host "  - Hoja 4: Estadísticas por Test ($($testStats.Count))"
        }
        Write-Host ""
        
    } else {
        Write-Host "INFO: ImportExcel no disponible. Instala con: Install-Module ImportExcel"
        Write-Host "      Generando CSV en su lugar..."
        
        # Generar CSV como alternativa
        $csvPath = "$reportPath\step_details_$timestamp.csv"
        $lines = @('"Test","Descripcion","Nivel","Tiempo (ms)","Tiempo (s)","Estado"')
        
        foreach ($step in $allSteps) {
            $desc = $step.Descripcion -replace '"', '""'
            $line = "`"$($step.Test)`",`"$desc`",$($step.Nivel),$($step.Tiempo_ms),$($step.Tiempo_s),$($step.Estado)"
            $lines += $line
        }
        
        $lines | Out-File -FilePath $csvPath -Encoding UTF8
        Write-Host "OK: CSV generado: $csvPath"
    }
}
catch {
    Write-Host "ERROR: $_"
}

Write-Host "====== REPORTE COMPLETADO ======"
