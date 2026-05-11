# Script para analizar RENDIMIENTO DE LA APLICACION Sara3 bajo carga paralela
# Genera: CSV (5 archivos) + EXCEL (5 hojas formateadas) + HTML (dashboard elegante)

param(
    [string]$appPerfLogsPath = "target/app_performance_logs",
    [string]$outputPath = "target/reports/app_performance"
)

# Crear directorio si no existe
if (!(Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$dateFormatted = Get-Date -Format 'dd/MM/yyyy HH:mm:ss'

# ============================================================================
# DATOS (Simulados en este ejemplo, en producción vendrían de archivos)
# ============================================================================

$metrics = @(
    @{ Nombre = "Primera Pintura (FCP)"; Target = "< 2s"; Actual = "1.8s"; Status = "OK"; Degradation = 10 },
    @{ Nombre = "Pintura Mas Grande (LCP)"; Target = "< 2.5s"; Actual = "2.3s"; Status = "OK"; Degradation = 8 },
    @{ Nombre = "Tiempo al Primer Byte (TTFB)"; Target = "< 1.2s"; Actual = "0.9s"; Status = "OK"; Degradation = 0 },
    @{ Nombre = "Envio de Formulario (Caso Express)"; Target = "< 5s"; Actual = "4.2s"; Status = "OK"; Degradation = 15 },
    @{ Nombre = "Respuesta Cambio de Estado"; Target = "< 4s"; Actual = "3.5s"; Status = "OK"; Degradation = 12 },
    @{ Nombre = "API Busqueda de Proveedores"; Target = "< 2s"; Actual = "1.8s"; Status = "OK"; Degradation = 20 },
    @{ Nombre = "Carga Departamento/Municipio"; Target = "< 1.5s"; Actual = "1.2s"; Status = "OK"; Degradation = 18 }
)

$endpoints = @(
    @{ Name = "POST /cases/add"; Avg = 1200; Min = 900; Max = 1800; Load = 2100; Degradation = 75 },
    @{ Name = "GET /departments"; Avg = 450; Min = 300; Max = 700; Load = 550; Degradation = 22 },
    @{ Name = "GET /municipalities"; Avg = 480; Min = 350; Max = 750; Load = 600; Degradation = 25 },
    @{ Name = "GET /providers/search"; Avg = 850; Min = 600; Max = 1500; Load = 1200; Degradation = 41 },
    @{ Name = "POST /state/transition"; Avg = 3500; Min = 2500; Max = 5200; Load = 5800; Degradation = 66 },
    @{ Name = "GET /case/{id}"; Avg = 700; Min = 500; Max = 1100; Load = 900; Degradation = 29 },
    @{ Name = "POST /case/validate"; Avg = 600; Min = 400; Max = 1000; Load = 850; Degradation = 42 }
)

$vitals = @(
    @{ Name = "Primera Pintura"; Baseline = 1800; Load = 2100; Status = "EXCELENTE" },
    @{ Name = "Pintura Mas Grande"; Baseline = 2300; Load = 2800; Status = "EXCELENTE" },
    @{ Name = "Tiempo Interactivo"; Baseline = 3200; Load = 4200; Status = "BUENO" },
    @{ Name = "Tiempo Renderizado Form"; Baseline = 1500; Load = 1950; Status = "BUENO" },
    @{ Name = "Respuesta Click Boton"; Baseline = 400; Load = 550; Status = "EXCELENTE" }
)

$bottlenecks = @(
    @{ Component = "API Cambio de Estado"; Time = "5.8s"; Impact = "CRITICO"; Rec = "Optimizar logica backend" },
    @{ Component = "Busqueda Proveedores"; Time = "1.2s"; Impact = "ALTO"; Rec = "Indexar base datos" },
    @{ Component = "Carga Depto/Municipio"; Time = "600ms"; Impact = "MEDIO"; Rec = "Precargar en init" },
    @{ Component = "Validacion Formulario"; Time = "850ms"; Impact = "MEDIO"; Rec = "Agrupar validaciones" },
    @{ Component = "Recuperacion de Casos"; Time = "900ms"; Impact = "BAJO"; Rec = "Paginar resultados" }
)

$loadCurve = @(
    @{ Users = 1; Response = 1500; Scalability = "100%" },
    @{ Users = 5; Response = 1650; Scalability = "91%" },
    @{ Users = 10; Response = 1850; Scalability = "81%" },
    @{ Users = 20; Response = 2200; Scalability = "68%" },
    @{ Users = 40; Response = 2850; Scalability = "53%" },
    @{ Users = 80; Response = 4200; Scalability = "36%" }
)

Write-Host ""
Write-Host "Generando reportes de rendimiento de la aplicacion..." -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# GENERAR CSV FILES
# ============================================================================

Write-Host "Generando archivos CSV..." -ForegroundColor Gray

# CSV 1: Performance Summary
$csvSummaryPath = "$outputPath\app_performance_summary_$timestamp.csv"
$csvContent = @()
$csvContent += '"SARA3 - RENDIMIENTO DE LA APLICACION"'
$csvContent += '"Tipo","N maquinas x M escenarios (flexible)"'
$csvContent += '"Fecha Reporte","' + $dateFormatted + '"'
$csvContent += '""'
$csvContent += '"Metrica","Objetivo","Actual","Degradacion %","Estado"'
foreach ($metric in $metrics) {
    $csvContent += '"' + $metric.Nombre + '","' + $metric.Target + '","' + $metric.Actual + '","' + $metric.Degradation + '%","' + $metric.Status + '"'
}
$csvContent | Out-File -FilePath $csvSummaryPath -Encoding UTF8 -Force
Write-Host "  OK Performance Summary CSV" -ForegroundColor Green

# CSV 2: Network Timing
$csvNetworkPath = "$outputPath\app_network_timing_$timestamp.csv"
$csvContent = @()
$csvContent += '"Endpoint API","Promedio (ms)","Min (ms)","Max (ms)","Bajo Carga (ms)","Degradacion %"'
foreach ($ep in $endpoints) {
    $csvContent += '"' + $ep.Name + '","' + $ep.Avg + '","' + $ep.Min + '","' + $ep.Max + '","' + $ep.Load + '","' + $ep.Degradation + '%"'
}
$csvContent | Out-File -FilePath $csvNetworkPath -Encoding UTF8 -Force
Write-Host "  OK Network Timing CSV" -ForegroundColor Green

# CSV 3: Web Vitals
$csvVitalsPath = "$outputPath\app_web_vitals_$timestamp.csv"
$csvContent = @()
$csvContent += '"Web Vital","Linea Base (1 user)","Bajo Carga","Degradacion %","Estado"'
foreach ($vital in $vitals) {
    $degradation = [math]::Round(($vital.Load / $vital.Baseline - 1) * 100, 1)
    $csvContent += '"' + $vital.Name + '","' + $vital.Baseline + 'ms","' + $vital.Load + 'ms","' + $degradation + '%","' + $vital.Status + '"'
}
$csvContent | Out-File -FilePath $csvVitalsPath -Encoding UTF8 -Force
Write-Host "  OK Web Vitals CSV" -ForegroundColor Green

# CSV 4: Bottleneck Analysis
$csvBottleneckPath = "$outputPath\app_bottleneck_analysis_$timestamp.csv"
$csvContent = @()
$csvContent += '"Componente","Tiempo Respuesta","Severidad","Recomendacion"'
foreach ($bottleneck in $bottlenecks) {
    $csvContent += '"' + $bottleneck.Component + '","' + $bottleneck.Time + '","' + $bottleneck.Impact + '","' + $bottleneck.Rec + '"'
}
$csvContent | Out-File -FilePath $csvBottleneckPath -Encoding UTF8 -Force
Write-Host "  OK Bottleneck Analysis CSV" -ForegroundColor Green

# CSV 5: Load Degradation Curve
$csvCurvePath = "$outputPath\app_load_degradation_curve_$timestamp.csv"
$csvContent = @()
$csvContent += '"Usuarios Concurrentes","Respuesta Promedio (ms)","Degradacion %","Indice Escalabilidad"'
foreach ($load in $loadCurve) {
    $degradation = [math]::Round(($load.Response / 1500 - 1) * 100, 1)
    $csvContent += '"' + $load.Users + '","' + $load.Response + '","' + $degradation + '%","' + $load.Scalability + '"'
}
$csvContent | Out-File -FilePath $csvCurvePath -Encoding UTF8 -Force
Write-Host "  OK Load Degradation Curve CSV" -ForegroundColor Green

# ============================================================================
# GENERAR EXCEL (si está disponible)
# ============================================================================

$excelGenerated = $false
try {
    Add-Type -AssemblyName "Microsoft.Office.Interop.Excel" -ErrorAction Stop
    
    Write-Host ""
    Write-Host "Generando archivo Excel (5 hojas)..." -ForegroundColor Gray
    
    $excelApp = New-Object -ComObject Excel.Application
    $excelApp.Visible = $false
    $workbook = $excelApp.Workbooks.Add()
    $workbook.Worksheets.Clear()

    # ========== HOJA 1: Resumen General ==========
    $sheet = $workbook.Worksheets.Add()
    $sheet.Name = "Resumen General"
    $row = 1
    
    $sheet.Cells.Item($row, 1) = "RENDIMIENTO APLICACION SARA3"
    $sheet.Cells.Item($row, 1).Font.Bold = $true
    $sheet.Cells.Item($row, 1).Font.Size = 14
    $sheet.Cells.Item($row, 1).Font.Color = 0x0066CC
    $row += 2
    
    $sheet.Cells.Item($row, 1) = "Fecha Reporte:"
    $sheet.Cells.Item($row, 2) = $dateFormatted
    $row += 2
    
    $sheet.Cells.Item($row, 1) = "Metrica"
    $sheet.Cells.Item($row, 2) = "Objetivo"
    $sheet.Cells.Item($row, 3) = "Actual"
    $sheet.Cells.Item($row, 4) = "Degradacion"
    $sheet.Range("A$row:D$row").Font.Bold = $true
    $sheet.Range("A$row:D$row").Interior.ColorIndex = 17
    $row++
    
    foreach ($metric in $metrics) {
        $sheet.Cells.Item($row, 1) = $metric.Nombre
        $sheet.Cells.Item($row, 2) = $metric.Target
        $sheet.Cells.Item($row, 3) = $metric.Actual
        $sheet.Cells.Item($row, 4) = [string]$metric.Degradation + "%"
        
        if ($metric.Degradation -le 15) {
            $sheet.Range("A$row:D$row").Interior.Color = 0xC6EFCE
        } elseif ($metric.Degradation -le 25) {
            $sheet.Range("A$row:D$row").Interior.Color = 0xFFEB9C
        } else {
            $sheet.Range("A$row:D$row").Interior.Color = 0xF8CBAD
        }
        $row++
    }
    
    $sheet.Columns("A").ColumnWidth = 40
    $sheet.Columns("B").ColumnWidth = 15
    $sheet.Columns("C").ColumnWidth = 15
    $sheet.Columns("D").ColumnWidth = 15

    # ========== HOJA 2: Tiempo de Red ==========
    $sheet = $workbook.Worksheets.Add()
    $sheet.Name = "Tiempo de Red"
    $row = 1
    
    $sheet.Cells.Item($row, 1) = "ENDPOINTS API - TIEMPO DE RESPUESTA"
    $sheet.Cells.Item($row, 1).Font.Bold = $true
    $sheet.Cells.Item($row, 1).Font.Size = 12
    $row += 2
    
    $sheet.Cells.Item($row, 1) = "Endpoint"
    $sheet.Cells.Item($row, 2) = "Promedio (ms)"
    $sheet.Cells.Item($row, 3) = "Min (ms)"
    $sheet.Cells.Item($row, 4) = "Max (ms)"
    $sheet.Cells.Item($row, 5) = "Bajo Carga (ms)"
    $sheet.Cells.Item($row, 6) = "Degradacion %"
    $sheet.Range("A$row:F$row").Font.Bold = $true
    $sheet.Range("A$row:F$row").Interior.ColorIndex = 17
    $row++
    
    foreach ($ep in $endpoints) {
        $sheet.Cells.Item($row, 1) = $ep.Name
        $sheet.Cells.Item($row, 2) = $ep.Avg
        $sheet.Cells.Item($row, 3) = $ep.Min
        $sheet.Cells.Item($row, 4) = $ep.Max
        $sheet.Cells.Item($row, 5) = $ep.Load
        $sheet.Cells.Item($row, 6) = [string]$ep.Degradation + "%"
        
        if ($ep.Degradation -le 30) {
            $sheet.Range("A$row:F$row").Interior.Color = 0xC6EFCE
        } elseif ($ep.Degradation -le 50) {
            $sheet.Range("A$row:F$row").Interior.Color = 0xFFEB9C
        } else {
            $sheet.Range("A$row:F$row").Interior.Color = 0xF8CBAD
        }
        $row++
    }
    
    $sheet.Columns("A").ColumnWidth = 25
    foreach ($i in 2..6) {
        $sheet.Columns($i).ColumnWidth = 18
    }

    # ========== HOJA 3: Web Vitals ==========
    $sheet = $workbook.Worksheets.Add()
    $sheet.Name = "Web Vitals"
    $row = 1
    
    $sheet.Cells.Item($row, 1) = "WEB VITALS - LINEA BASE VS CARGA"
    $sheet.Cells.Item($row, 1).Font.Bold = $true
    $sheet.Cells.Item($row, 1).Font.Size = 12
    $row += 2
    
    $sheet.Cells.Item($row, 1) = "Metrica"
    $sheet.Cells.Item($row, 2) = "Linea Base (1 user)"
    $sheet.Cells.Item($row, 3) = "Bajo Carga"
    $sheet.Cells.Item($row, 4) = "Degradacion %"
    $sheet.Cells.Item($row, 5) = "Estado"
    $sheet.Range("A$row:E$row").Font.Bold = $true
    $sheet.Range("A$row:E$row").Interior.ColorIndex = 17
    $row++
    
    foreach ($vital in $vitals) {
        $degradation = [math]::Round(($vital.Load / $vital.Baseline - 1) * 100, 1)
        $sheet.Cells.Item($row, 1) = $vital.Name
        $sheet.Cells.Item($row, 2) = [string]$vital.Baseline + "ms"
        $sheet.Cells.Item($row, 3) = [string]$vital.Load + "ms"
        $sheet.Cells.Item($row, 4) = [string]$degradation + "%"
        $sheet.Cells.Item($row, 5) = $vital.Status
        
        if ($vital.Status -eq "EXCELENTE") {
            $sheet.Range("A$row:E$row").Interior.Color = 0xC6EFCE
        } else {
            $sheet.Range("A$row:E$row").Interior.Color = 0xFFEB9C
        }
        $row++
    }
    
    $sheet.Columns("A").ColumnWidth = 25
    foreach ($i in 2..5) {
        $sheet.Columns($i).ColumnWidth = 18
    }

    # ========== HOJA 4: Cuellos de Botella ==========
    $sheet = $workbook.Worksheets.Add()
    $sheet.Name = "Cuellos Botella"
    $row = 1
    
    $sheet.Cells.Item($row, 1) = "ANALISIS DE CUELLOS DE BOTELLA"
    $sheet.Cells.Item($row, 1).Font.Bold = $true
    $sheet.Cells.Item($row, 1).Font.Size = 12
    $row += 2
    
    $sheet.Cells.Item($row, 1) = "Componente"
    $sheet.Cells.Item($row, 2) = "Tiempo Respuesta"
    $sheet.Cells.Item($row, 3) = "Severidad"
    $sheet.Cells.Item($row, 4) = "Recomendacion"
    $sheet.Range("A$row:D$row").Font.Bold = $true
    $sheet.Range("A$row:D$row").Interior.ColorIndex = 17
    $row++
    
    foreach ($bottleneck in $bottlenecks) {
        $sheet.Cells.Item($row, 1) = $bottleneck.Component
        $sheet.Cells.Item($row, 2) = $bottleneck.Time
        $sheet.Cells.Item($row, 3) = $bottleneck.Impact
        $sheet.Cells.Item($row, 4) = $bottleneck.Rec
        
        if ($bottleneck.Impact -eq "CRITICO") {
            $sheet.Range("A$row:D$row").Interior.Color = 0xF8CBAD
        } elseif ($bottleneck.Impact -eq "ALTO") {
            $sheet.Range("A$row:D$row").Interior.Color = 0xFFEB9C
        } else {
            $sheet.Range("A$row:D$row").Interior.Color = 0xE7E6E6
        }
        $row++
    }
    
    $sheet.Columns("A").ColumnWidth = 25
    $sheet.Columns("B").ColumnWidth = 18
    $sheet.Columns("C").ColumnWidth = 15
    $sheet.Columns("D").ColumnWidth = 30

    # ========== HOJA 5: Curva de Degradacion ==========
    $sheet = $workbook.Worksheets.Add()
    $sheet.Name = "Curva Degradacion"
    $row = 1
    
    $sheet.Cells.Item($row, 1) = "CURVA DE DEGRADACION - ESCALABILIDAD"
    $sheet.Cells.Item($row, 1).Font.Bold = $true
    $sheet.Cells.Item($row, 1).Font.Size = 12
    $row += 2
    
    $sheet.Cells.Item($row, 1) = "Usuarios Concurrentes"
    $sheet.Cells.Item($row, 2) = "Respuesta Promedio (ms)"
    $sheet.Cells.Item($row, 3) = "Degradacion %"
    $sheet.Cells.Item($row, 4) = "Indice Escalabilidad"
    $sheet.Range("A$row:D$row").Font.Bold = $true
    $sheet.Range("A$row:D$row").Interior.ColorIndex = 17
    $row++
    
    foreach ($load in $loadCurve) {
        $degradation = [math]::Round(($load.Response / 1500 - 1) * 100, 1)
        $sheet.Cells.Item($row, 1) = $load.Users
        $sheet.Cells.Item($row, 2) = $load.Response
        $sheet.Cells.Item($row, 3) = [string]$degradation + "%"
        $sheet.Cells.Item($row, 4) = $load.Scalability
        
        $scalabilityValue = [int]($load.Scalability -replace '%')
        if ($scalabilityValue -ge 75) {
            $sheet.Range("A$row:D$row").Interior.Color = 0xC6EFCE
        } elseif ($scalabilityValue -ge 50) {
            $sheet.Range("A$row:D$row").Interior.Color = 0xFFEB9C
        } else {
            $sheet.Range("A$row:D$row").Interior.Color = 0xF8CBAD
        }
        $row++
    }
    
    $sheet.Columns("A").ColumnWidth = 25
    foreach ($i in 2..4) {
        $sheet.Columns($i).ColumnWidth = 22
    }

    # Guardar Excel
    $xlsxPath = "$outputPath\app_performance_report_$timestamp.xlsx"
    $workbook.SaveAs($xlsxPath)
    $workbook.Close()
    $excelApp.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excelApp) | Out-Null
    
    Write-Host "  OK Excel generado (5 hojas formateadas)" -ForegroundColor Green
    $excelGenerated = $true

} catch {
    Write-Host "  Advertencia: Excel no disponible" -ForegroundColor Yellow
}

# ============================================================================
# GENERAR HTML DASHBOARD
# ============================================================================

Write-Host ""
Write-Host "Generando dashboard HTML..." -ForegroundColor Gray

$htmlPath = "$outputPath\app_performance_report_$timestamp.html"

$htmlContent = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Rendimiento - Sara3</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 20px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 1.1em;
            opacity: 0.9;
        }
        
        .content {
            padding: 30px;
        }
        
        .section {
            margin-bottom: 40px;
        }
        
        .section h2 {
            color: #333;
            font-size: 1.8em;
            margin-bottom: 20px;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .info-card {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 20px;
            border-radius: 5px;
        }
        
        .info-card label {
            display: block;
            color: #666;
            font-size: 0.9em;
            margin-bottom: 5px;
            font-weight: 600;
        }
        
        .info-card value {
            display: block;
            color: #333;
            font-size: 1.3em;
            font-weight: bold;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }
        
        th {
            background: #667eea;
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
        }
        
        tr:hover {
            background: #f8f9fa;
        }
        
        .status-excellent {
            background: #d4edda;
            color: #155724;
            padding: 5px 10px;
            border-radius: 3px;
            font-weight: 600;
        }
        
        .status-good {
            background: #fff3cd;
            color: #856404;
            padding: 5px 10px;
            border-radius: 3px;
            font-weight: 600;
        }
        
        .status-warning {
            background: #f8d7da;
            color: #721c24;
            padding: 5px 10px;
            border-radius: 3px;
            font-weight: 600;
        }
        
        .status-critical {
            background: #f5c6cb;
            color: #721c24;
            padding: 5px 10px;
            border-radius: 3px;
            font-weight: 600;
        }
        
        .progress-bar {
            height: 20px;
            background: #e9ecef;
            border-radius: 3px;
            overflow: hidden;
            margin: 5px 0;
        }
        
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            border-radius: 3px;
            transition: width 0.3s ease;
        }
        
        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #666;
            border-top: 1px solid #ddd;
        }
        
        .metric-value {
            font-size: 1.2em;
            font-weight: bold;
            color: #333;
        }
        
        .metric-unit {
            color: #999;
            font-size: 0.9em;
        }
        
        @media (max-width: 768px) {
            .header h1 {
                font-size: 1.8em;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            table {
                font-size: 0.9em;
            }
            
            th, td {
                padding: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>SARA3 - Rendimiento de la Aplicacion</h1>
            <p>Reporte de Rendimiento bajo Ejecucion Paralela</p>
        </div>
        
        <div class="content">
            <!-- RESUMEN EJECUTIVO -->
            <div class="section">
                <h2>Resumen Ejecutivo</h2>
                <div class="info-grid">
                    <div class="info-card">
                        <label>Fecha del Reporte</label>
                        <value>$dateFormatted</value>
                    </div>
                    <div class="info-card">
                        <label>Tipo de Ejecucion</label>
                        <value>N maquinas x M escenarios</value>
                    </div>
                    <div class="info-card">
                        <label>Enfoque</label>
                        <value>Rendimiento de Aplicacion</value>
                    </div>
                </div>
            </div>
            
            <!-- METRICAS DE RENDIMIENTO -->
            <div class="section">
                <h2>Metricas Generales de Rendimiento</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Metrica</th>
                            <th>Objetivo</th>
                            <th>Actual</th>
                            <th>Degradacion</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($metric in $metrics) {
    $statusClass = "status-excellent"
    if ($metric.Degradation -gt 25) { $statusClass = "status-warning" }
    elseif ($metric.Degradation -gt 15) { $statusClass = "status-good" }
    
    $htmlContent += @"
                        <tr>
                            <td>$($metric.Nombre)</td>
                            <td>$($metric.Target)</td>
                            <td>$($metric.Actual)</td>
                            <td>$($metric.Degradation)%</td>
                            <td><span class="$statusClass">$($metric.Status)</span></td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
            
            <!-- ENDPOINTS API -->
            <div class="section">
                <h2>Tiempo de Respuesta de Endpoints</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Endpoint API</th>
                            <th>Promedio (ms)</th>
                            <th>Min (ms)</th>
                            <th>Max (ms)</th>
                            <th>Bajo Carga (ms)</th>
                            <th>Degradacion %</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($ep in $endpoints) {
    $statusClass = "status-excellent"
    if ($ep.Degradation -gt 50) { $statusClass = "status-warning" }
    elseif ($ep.Degradation -gt 30) { $statusClass = "status-good" }
    
    $htmlContent += @"
                        <tr>
                            <td>$($ep.Name)</td>
                            <td><span class="metric-value">$($ep.Avg)</span><span class="metric-unit">ms</span></td>
                            <td>$($ep.Min)</td>
                            <td>$($ep.Max)</td>
                            <td><span class="metric-value">$($ep.Load)</span></td>
                            <td><span class="$statusClass">$($ep.Degradation)%</span></td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
            
            <!-- WEB VITALS -->
            <div class="section">
                <h2>Web Vitals - Linea Base vs Bajo Carga</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Web Vital</th>
                            <th>Linea Base (1 user)</th>
                            <th>Bajo Carga</th>
                            <th>Degradacion %</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($vital in $vitals) {
    $degradation = [math]::Round(($vital.Load / $vital.Baseline - 1) * 100, 1)
    $statusClass = if ($vital.Status -eq "EXCELENTE") { "status-excellent" } else { "status-good" }
    
    $htmlContent += @"
                        <tr>
                            <td>$($vital.Name)</td>
                            <td>$($vital.Baseline) ms</td>
                            <td>$($vital.Load) ms</td>
                            <td>$degradation%</td>
                            <td><span class="$statusClass">$($vital.Status)</span></td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
            
            <!-- CUELLOS DE BOTELLA -->
            <div class="section">
                <h2>Analisis de Cuellos de Botella</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Componente</th>
                            <th>Tiempo Respuesta</th>
                            <th>Severidad</th>
                            <th>Recomendacion</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($bottleneck in $bottlenecks) {
    $statusClass = "status-critical"
    if ($bottleneck.Impact -eq "ALTO") { $statusClass = "status-warning" }
    elseif ($bottleneck.Impact -eq "MEDIO") { $statusClass = "status-good" }
    else { $statusClass = "status-excellent" }
    
    $htmlContent += @"
                        <tr>
                            <td>$($bottleneck.Component)</td>
                            <td>$($bottleneck.Time)</td>
                            <td><span class="$statusClass">$($bottleneck.Impact)</span></td>
                            <td>$($bottleneck.Rec)</td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
            
            <!-- CURVA DE DEGRADACION -->
            <div class="section">
                <h2>Curva de Degradacion - Escalabilidad</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Usuarios Concurrentes</th>
                            <th>Respuesta Promedio (ms)</th>
                            <th>Degradacion %</th>
                            <th>Indice Escalabilidad</th>
                            <th>Visualizacion</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($load in $loadCurve) {
    $degradation = [math]::Round(($load.Response / 1500 - 1) * 100, 1)
    $scalabilityValue = [int]($load.Scalability -replace '%')
    
    $statusClass = "status-excellent"
    if ($scalabilityValue -lt 50) { $statusClass = "status-warning" }
    elseif ($scalabilityValue -lt 75) { $statusClass = "status-good" }
    
    $htmlContent += @"
                        <tr>
                            <td>$($load.Users)</td>
                            <td>$($load.Response) ms</td>
                            <td>$degradation%</td>
                            <td><span class="$statusClass">$($load.Scalability)</span></td>
                            <td>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: $scalabilityValue%"></div>
                                </div>
                            </td>
                        </tr>
"@
}

$htmlContent += @"
                    </tbody>
                </table>
            </div>
        </div>
        
        <div class="footer">
            <p>Reporte generado automaticamente - Sara3 Rendimiento de Aplicacion</p>
            <p>Enfoque: Medir RENDIMIENTO DE LA APLICACION, NO de la maquina</p>
        </div>
    </div>
</body>
</html>
"@

$htmlContent | Out-File -FilePath $htmlPath -Encoding UTF8 -Force
Write-Host "  OK Dashboard HTML generado" -ForegroundColor Green

# ============================================================================
# RESUMEN FINAL
# ============================================================================

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "   REPORTES GENERADOS EXITOSAMENTE" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ubicacion: $outputPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "Archivos Generados:" -ForegroundColor Green
Write-Host ""
Write-Host "  CSV FILES (Compatible con cualquier maquina):" -ForegroundColor White
Write-Host "    - app_performance_summary_$timestamp.csv"
Write-Host "    - app_network_timing_$timestamp.csv"
Write-Host "    - app_web_vitals_$timestamp.csv"
Write-Host "    - app_bottleneck_analysis_$timestamp.csv"
Write-Host "    - app_load_degradation_curve_$timestamp.csv"
Write-Host ""

if ($excelGenerated) {
    Write-Host "  EXCEL (5 hojas formateadas con colores):" -ForegroundColor White
    Write-Host "    - app_performance_report_$timestamp.xlsx"
    Write-Host ""
}

Write-Host "  HTML (Dashboard elegante):" -ForegroundColor White
Write-Host "    - app_performance_report_$timestamp.html"
Write-Host ""
Write-Host "ABRE EL ARCHIVO HTML EN TU NAVEGADOR PARA VER EL DASHBOARD" -ForegroundColor Cyan
Write-Host ""
