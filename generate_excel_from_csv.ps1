# Función reutilizable para generar Excel desde CSV
# Independiente de Office - Funciona con LibreOffice y máquinas sin Office

param(
    [string]$csvPath,
    [string]$outputPath,
    [string]$worksheetName = "Datos"
)

function Convert-CsvToExcel {
    param(
        [string]$csvPath,
        [string]$outputPath,
        [string]$worksheetName = "Datos"
    )
    
    if (-not (Test-Path $csvPath)) {
        Write-Host "❌ Error: CSV no encontrado: $csvPath" -ForegroundColor Red
        return $false
    }
    
    $excelGenerated = $false
    
    # Opción 1: Intentar con ImportExcel (recomendado)
    try {
        Import-Module ImportExcel -ErrorAction SilentlyContinue
        $data = Import-Csv -Path $csvPath -Encoding UTF8
        
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $excelPath = $outputPath + "\report_" + $timestamp + ".xlsx"
        
        Write-Host "  Generando Excel con ImportExcel..." -ForegroundColor Gray
        $data | Export-Excel -Path $excelPath -WorksheetName $worksheetName -AutoSize -TableName "ReportData" -Encoding UTF8
        
        Write-Host "  ✓ Excel generado: $(Split-Path $excelPath -Leaf)" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "  ⚠ ImportExcel no disponible, intentando alternativa..." -ForegroundColor Yellow
    }
    
    # Opción 2: Generar XLSX usando ZIP (formato Open XML)
    try {
        Write-Host "  Generando XLSX usando ZIP (formato Open XML)..." -ForegroundColor Gray
        
        $data = Import-Csv -Path $csvPath -Encoding UTF8
        
        # Crear estructura XML
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $tempDir = [System.IO.Path]::GetTempPath() + "xlsx_" + [System.Guid]::NewGuid()
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        # Crear directorios requeridos
        New-Item -ItemType Directory -Path "$tempDir\_rels" -Force | Out-Null
        New-Item -ItemType Directory -Path "$tempDir\xl\_rels" -Force | Out-Null
        New-Item -ItemType Directory -Path "$tempDir\xl\worksheets" -Force | Out-Null
        
        # Crear [Content_Types].xml
        $contentTypes = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
    <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
    <Default Extension="xml" ContentType="application/xml"/>
    <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
    <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
    <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
    <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
</Types>
"@
        $contentTypes | Out-File -FilePath "$tempDir\[Content_Types].xml" -Encoding UTF8 -Force
        
        # Crear .rels
        $rels = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
    <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
</Relationships>
"@
        $rels | Out-File -FilePath "$tempDir\_rels\.rels" -Encoding UTF8 -Force
        
        # Crear workbook.xml
        $workbook = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
    <sheets>
        <sheet name="$worksheetName" sheetId="1" r:id="rId1"/>
    </sheets>
</workbook>
"@
        $workbook | Out-File -FilePath "$tempDir\xl\workbook.xml" -Encoding UTF8 -Force
        
        # Crear xl/_rels/workbook.xml.rels
        $workbookRels = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
    <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
"@
        $workbookRels | Out-File -FilePath "$tempDir\xl\_rels\workbook.xml.rels" -Encoding UTF8 -Force
        
        # Crear styles.xml (estilos básicos)
        $styles = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
    <fonts><font><sz val="11"/><color theme="1"/><name val="Calibri"/><family val="2"/><scheme val="minor"/></font></fonts>
    <fills><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill></fills>
    <borders><border><left/><right/><top/><bottom/><diagonal/></border></borders>
    <cellStyleXfs><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
    <cellXfs><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/></cellXfs>
</styleSheet>
"@
        $styles | Out-File -FilePath "$tempDir\xl\styles.xml" -Encoding UTF8 -Force
        
        # Crear sheet1.xml con datos del CSV
        $sheet = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
    <sheetData>
"@
        
        $row = 1
        $columns = $data[0].PSObject.Properties.Name
        
        # Encabezados
        $sheet += "`n        <row r=`"$row`">`n"
        foreach ($col in $columns) {
            $colLetter = [System.Convert]::ToString([char](64 + $columns.IndexOf($col) + 1))
            $sheet += "            <c r=`"$colLetter$row`" t=`"inlineStr`"><is><t>$($col)</t></is></c>`n"
        }
        $sheet += "        </row>`n"
        $row++
        
        # Datos
        foreach ($item in $data) {
            $sheet += "        <row r=`"$row`">`n"
            $colIndex = 0
            foreach ($col in $columns) {
                $colLetter = [System.Convert]::ToString([char](64 + $colIndex + 1))
                $value = $item.$col
                $sheet += "            <c r=`"$colLetter$row`" t=`"inlineStr`"><is><t>$value</t></is></c>`n"
                $colIndex++
            }
            $sheet += "        </row>`n"
            $row++
        }
        
        $sheet += @"
    </sheetData>
</worksheet>
"@
        $sheet | Out-File -FilePath "$tempDir\xl\worksheets\sheet1.xml" -Encoding UTF8 -Force
        
        # Crear docProps/core.xml
        $docProps = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <dc:creator>Sara3 Performance Monitor</dc:creator>
    <dcterms:created xsi:type="dcterms:W3CDTF">$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')</dcterms:created>
</cp:coreProperties>
"@
        New-Item -ItemType Directory -Path "$tempDir\docProps" -Force | Out-Null
        $docProps | Out-File -FilePath "$tempDir\docProps\core.xml" -Encoding UTF8 -Force
        
        # Empaquetar como ZIP
        $excelPath = "$outputPath\report_" + $timestamp + ".xlsx"
        
        # Convertir a ZIP
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $excelPath, [System.IO.Compression.CompressionLevel]::Optimal, $false)
        
        # Limpiar
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Host "  ✓ Excel generado: $(Split-Path $excelPath -Leaf)" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "  ⚠ Error generando Excel: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

# Ejecutar si se llama directamente
if ($csvPath -and $outputPath) {
    Convert-CsvToExcel -csvPath $csvPath -outputPath $outputPath -worksheetName $worksheetName
}
