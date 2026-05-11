@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: VALIDAR Y CORREGIR JAVA_HOME ANTES DE LLAMAR A GRADLEW
:: ============================================================
:: Si JAVA_HOME apunta a una ruta invalida, Gradle no puede arrancar.
:: Intentamos detectar un JDK valido automaticamente.
if defined JAVA_HOME (
    if not exist "%JAVA_HOME%\bin\java.exe" (
        echo ADVERTENCIA: JAVA_HOME invalido: %JAVA_HOME%
        set "JAVA_HOME="
    )
)
if not defined JAVA_HOME (
    if exist "C:\Program Files\Microsoft\jdk-21.0.8.9-hotspot\bin\java.exe" (
        set "JAVA_HOME=C:\Program Files\Microsoft\jdk-21.0.8.9-hotspot"
    ) else if exist "C:\Program Files\Eclipse Adoptium\jdk-21.0.8.9-hotspot\bin\java.exe" (
        set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.8.9-hotspot"
    ) else (
        where java >nul 2>&1
        if %errorlevel% neq 0 (
            echo ERROR: No se encontro una instalacion de Java valida.
            echo Instala JDK 21 o configura JAVA_HOME correctamente.
            pause
            exit /b 1
        )
    )
)
echo.
echo ========================================================
echo         SARA3 - Descargando dependencias...
echo ========================================================
echo.
echo (Primera vez: 3-5 minutos. Siguientes: 30 segundos)
echo.

call .\gradlew.bat compileTestJava -q
if %errorlevel% neq 0 (
    echo.
    echo ERROR: No se pudo compilar el proyecto
    echo Verifica tu conexion a internet
    echo.
    pause
    exit /b 1
)

:menu
cls
echo.
echo ========================================================
echo       AUTOMATIZACION SARA3 - EJECUCION DE PRUEBAS
echo ========================================================
echo.
echo  1. Ejecutar numero personalizado de runners
echo  2. Ejecutar  2 runners en paralelo
echo  3. Ejecutar  4 runners en paralelo
echo  4. Ejecutar  8 runners en paralelo
echo  5. Ejecutar 12 runners en paralelo
echo  6. Ejecutar 50 runners en paralelo
echo  7. Ejecutar  1 runner individual (con numero 1-50)
echo  8. Ver reporte de resultados
echo  9. Generar reporte SIMPLE (EXCEL/CSV con tiempos)
echo 10. Generar reporte AVANZADO (EXCEL MULTIPLES HOJAS + HTML)
echo 11. Limpiar reportes (en otro archivo)
echo 12. Ejecutar 1 SCENARIO sin paralelo
echo 13. Generar REPORTE DE RENDIMIENTO (solo performance)
echo 14. Salir
echo.
set /p choice="Selecciona opcion (1-14): "

if "%choice%"=="1" goto custom_runners
if "%choice%"=="2" goto run_2
if "%choice%"=="3" goto run_4
if "%choice%"=="4" goto run_8
if "%choice%"=="5" goto run_12
if "%choice%"=="6" goto run_50
if "%choice%"=="7" goto run_one
if "%choice%"=="8" goto report
if "%choice%"=="9" goto timing_report
if "%choice%"=="10" goto advanced_report
if "%choice%"=="11" goto clean_help
if "%choice%"=="12" goto run_one_no_parallel
if "%choice%"=="13" goto performance_report
if "%choice%"=="14" goto end
goto menu

:custom_runners
set /p FORKS="Numero de runners (1-50): "
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=%FORKS%' | Set-Content gradle.properties"
call .\gradlew.bat test --parallel
echo.
echo [INFO] Ejecucion completada. Los tests fallidos NO detienen la ejecucion.
echo.
echo [INFO] Generando reportes automaticamente...
timeout /t 2 >nul
powershell -ExecutionPolicy Bypass -File "generate_advanced_report.ps1"
powershell -ExecutionPolicy Bypass -File "generate_app_performance_report.ps1"
if exist "target\reports\test_timings_report.xlsx" (
    echo [INFO] Abriendo reportes...
    timeout /t 1 >nul
    start "" "target\reports\test_timings_report.xlsx"
    start "" "target\reports\test_timings_report.html"
)
pause
goto menu

:run_2
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=2' | Set-Content gradle.properties"
call .\gradlew.bat test --parallel
echo.
echo [INFO] Ejecucion completada. Los tests fallidos NO detienen la ejecucion.
echo.
echo [INFO] Generando reportes automaticamente...
timeout /t 2 >nul
powershell -ExecutionPolicy Bypass -File "generate_advanced_report.ps1"
powershell -ExecutionPolicy Bypass -File "generate_app_performance_report.ps1"
if exist "target\reports\test_timings_report.xlsx" (
    echo [INFO] Abriendo reportes...
    timeout /t 1 >nul
    start "" "target\reports\test_timings_report.xlsx"
    start "" "target\reports\test_timings_report.html"
)
pause
goto menu

:run_4
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=4' | Set-Content gradle.properties"
call .\gradlew.bat test --parallel
echo.
echo [INFO] Ejecucion completada. Los tests fallidos NO detienen la ejecucion.
echo.
echo [INFO] Generando reportes automaticamente...
timeout /t 2 >nul
powershell -ExecutionPolicy Bypass -File "generate_advanced_report.ps1"
powershell -ExecutionPolicy Bypass -File "generate_app_performance_report.ps1"
if exist "target\reports\test_timings_report.xlsx" (
    echo [INFO] Abriendo reportes...
    timeout /t 1 >nul
    start "" "target\reports\test_timings_report.xlsx"
    start "" "target\reports\test_timings_report.html"
)
pause
goto menu

:run_8
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=8' | Set-Content gradle.properties"
call .\gradlew.bat test --parallel
echo.
echo [INFO] Ejecucion completada. Los tests fallidos NO detienen la ejecucion.
echo.
echo [INFO] Generando reportes automaticamente...
timeout /t 2 >nul
powershell -ExecutionPolicy Bypass -File "generate_advanced_report.ps1"
powershell -ExecutionPolicy Bypass -File "generate_app_performance_report.ps1"
if exist "target\reports\test_timings_report.xlsx" (
    echo [INFO] Abriendo reportes...
    timeout /t 1 >nul
    start "" "target\reports\test_timings_report.xlsx"
    start "" "target\reports\test_timings_report.html"
)
pause
goto menu

:run_12
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=12' | Set-Content gradle.properties"
call .\gradlew.bat test --parallel
echo.
echo [INFO] Ejecucion completada. Los tests fallidos NO detienen la ejecucion.
echo.
echo [INFO] Generando reportes automaticamente...
timeout /t 2 >nul
powershell -ExecutionPolicy Bypass -File "generate_advanced_report.ps1"
powershell -ExecutionPolicy Bypass -File "generate_app_performance_report.ps1"
if exist "target\reports\test_timings_report.xlsx" (
    echo [INFO] Abriendo reportes...
    timeout /t 1 >nul
    start "" "target\reports\test_timings_report.xlsx"
    start "" "target\reports\test_timings_report.html"
)
pause
goto menu

:run_50
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=50' | Set-Content gradle.properties"
echo.
echo ADVERTENCIA: Ejecutar 50 tests en paralelo requiere recursos significativos
echo.
call .\gradlew.bat test --parallel
echo.
echo [INFO] Ejecucion completada. Los 50 tests se ejecutaron (fallen o no).
echo.
echo [INFO] Generando reportes automaticamente...
timeout /t 2 >nul
powershell -ExecutionPolicy Bypass -File "generate_advanced_report.ps1"
powershell -ExecutionPolicy Bypass -File "generate_app_performance_report.ps1"
if exist "target\reports\test_timings_report.xlsx" (
    echo [INFO] Abriendo reportes...
    timeout /t 1 >nul
    start "" "target\reports\test_timings_report.xlsx"
    start "" "target\reports\test_timings_report.html"
)
pause
goto menu

:run_one
set /p runner="Numero del runner (1-50): "

:: Agregar cero a la izquierda si es menor a 10
if %runner% LSS 10 (
    set "runner_formatted=0%runner%"
) else (
    set "runner_formatted=%runner%"
)

powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=1' | Set-Content gradle.properties"
call .\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner%runner_formatted%"
pause
goto menu

:report
if exist "target\site\serenity\index.html" (
    start target\site\serenity\index.html
) else (
    echo No hay reporte. Ejecuta primero los tests.
    pause
)
goto menu

:timing_report
echo.
echo Generando reporte de tiempos...
if exist "build\test-results\test" (
    powershell -ExecutionPolicy Bypass -File "generate_timing_report.ps1"
    if exist "target\reports\test_timings_report.csv" (
        echo [OK] Reporte generado: target\reports\test_timings_report.csv
        timeout /t 2
        if exist "target\reports\test_timings_report.xlsx" (
            start "" "target\reports\test_timings_report.xlsx"
        ) else (
            start "" "target\reports\test_timings_report.csv"
        )
    )
) else (
    echo [ERROR] No hay resultados de tests. Ejecuta los tests primero.
)
pause
goto menu

:advanced_report
echo.
echo Generando REPORTE AVANZADO...
if exist "build\test-results\test" (
    powershell -ExecutionPolicy Bypass -File "generate_advanced_report.ps1"
    powershell -ExecutionPolicy Bypass -File "generate_app_performance_report.ps1"
    echo.
    timeout /t 2
    if exist "target\reports\test_timings_report.xlsx" (
        echo [INFO] Abriendo Excel...
        start "" "target\reports\test_timings_report.xlsx"
    )
    if exist "target\reports\test_timings_report.html" (
        echo [INFO] Abriendo HTML...
        start "" "target\reports\test_timings_report.html"
    )
) else (
    echo [ERROR] No hay resultados de tests. Ejecuta los tests primero.
)
pause
goto menu

:clean_help
echo.
echo Para limpiar reportes, ejecuta:
echo   clean_reports.bat
echo.
echo Limpia:
echo   - Reportes de Serenity
echo   - Resultados de tests
echo   - Excel y CSV de timing
echo   - Logs de ejecucion
echo.
pause
goto menu

:run_one_no_parallel
echo.
echo ========================================================
echo    EJECUTAR 1 SCENARIO SIN PARALELO
echo ========================================================
echo.
set /p batch_num="Numero del scenario (1-50): "

if "%batch_num%"=="" (
    echo ERROR: Debes ingresar un numero
    pause
    goto menu
)

:: Agregar cero a la izquierda si es menor a 10
if %batch_num% LSS 10 (
    set "batch_num_formatted=0%batch_num%"
) else (
    set "batch_num_formatted=%batch_num%"
)

:: Validar que sea un numero entre 1 y 50
for /l %%i in (1,1,50) do (
    if "%batch_num%"=="%%i" (
        powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=1' | Set-Content gradle.properties"
        echo.
        echo [INFO] Ejecutando SCENARIO %batch_num% SIN PARALELO...
        echo [INFO] Usando tag: @batch%batch_num_formatted%
        echo.
        call .\gradlew.bat test -Dcucumber.filter.tags="@batch%batch_num_formatted%"
        echo.
        echo [INFO] Ejecucion completada del scenario %batch_num%
        pause
        goto menu
    )
)

echo ERROR: Numero invalido. Ingresa un numero entre 1 y 50
pause
goto menu

:performance_report
echo.
echo ========================================================
echo    GENERAR REPORTE DE RENDIMIENTO DE LA APLICACION
echo ========================================================
echo.
powershell -ExecutionPolicy Bypass -File "generate_app_performance_report.ps1"
echo.
echo [INFO] Reportes generados en target\reports\
echo.
echo Archivos creados:
echo   - app_performance_summary_*.csv
echo   - app_network_timing_*.csv
echo   - app_web_vitals_*.csv
echo   - app_bottleneck_analysis_*.csv
echo   - app_load_degradation_curve_*.csv
echo   - app_performance_report_*.xlsx (si Excel esta disponible)
echo.
pause
goto menu

:end
exit /b 0
