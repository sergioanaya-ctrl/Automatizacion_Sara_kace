@echo off
:: ============================================
:: CONSOLIDADOR DE REPORTES CSV
:: ============================================
:: Este script consolida reportes CSV de múltiples máquinas
:: en un solo reporte unificado
::
:: USO:
:: 1. Copia los archivos step_details_*.csv de cada máquina
::    a la carpeta: .\reports_consolidation\
:: 2. Ejecuta este archivo .bat
:: 3. Los reportes consolidados se generarán en la misma carpeta

echo.
echo ================================================
echo   CONSOLIDADOR DE REPORTES - MULTIPLES MAQUINAS
echo ================================================
echo.
echo Este script consolidara todos los archivos CSV
echo de la carpeta: reports_consolidation\
echo.
echo Presiona cualquier tecla para continuar...
pause >nul

:: Ejecutar el script PowerShell de consolidación
powershell -ExecutionPolicy Bypass -File "consolidate_reports.ps1"

echo.
echo ================================================
echo   CONSOLIDACION FINALIZADA
echo ================================================
echo.
echo Los reportes consolidados estan en:
echo   .\reports_consolidation\
echo.
echo Archivos generados:
echo   - consolidated_report_*.csv (Todos los pasos)
echo   - consolidated_report_stats_*.csv (Estadisticas por test)
echo   - consolidated_report_by_machine_*.csv (Por maquina)
echo   - consolidated_report_*.xlsx (Excel con 8 hojas, si disponible)
echo.
pause
