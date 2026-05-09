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
echo  7. Ejecutar  1 runner individual
echo  8. Ver reporte de resultados
echo  9. Generar reporte de tiempos (EXCEL)
echo 10. Limpiar reportes (en otro archivo)
echo 11. Salir
echo.
set /p choice="Selecciona opcion (1-11): "

if "%choice%"=="1" goto custom_runners
if "%choice%"=="2" goto run_2
if "%choice%"=="3" goto run_4
if "%choice%"=="4" goto run_8
if "%choice%"=="5" goto run_12
if "%choice%"=="6" goto run_50
if "%choice%"=="7" goto run_one
if "%choice%"=="8" goto report
if "%choice%"=="9" goto timing_report
if "%choice%"=="10" goto clean_help
if "%choice%"=="11" goto end
goto menu

:custom_runners
set /p FORKS="Numero de runners (1-50): "
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=%FORKS%' | Set-Content gradle.properties"
call .\gradlew.bat test --parallel
echo.
echo [INFO] Ejecucion completada. Los tests fallidos NO detienen la ejecucion.
pause
goto menu

:run_2
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=2' | Set-Content gradle.properties"
call .\gradlew.bat test --parallel
echo.
echo [INFO] Ejecucion completada. Los tests fallidos NO detienen la ejecucion.
pause
goto menu

:run_4
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=4' | Set-Content gradle.properties"
call .\gradlew.bat test --parallel
echo.
echo [INFO] Ejecucion completada. Los tests fallidos NO detienen la ejecucion.
pause
goto menu

:run_8
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=8' | Set-Content gradle.properties"
call .\gradlew.bat test --parallel
echo.
echo [INFO] Ejecucion completada. Los tests fallidos NO detienen la ejecucion.
pause
goto menu

:run_12
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=12' | Set-Content gradle.properties"
call .\gradlew.bat test --parallel
echo.
echo [INFO] Ejecucion completada. Los tests fallidos NO detienen la ejecucion.
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
pause
goto menu

:run_one
set /p runner="Numero del runner (01-50): "
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=1' | Set-Content gradle.properties"
call .\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner%runner%"
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
    if exist "test_timings_report.csv" (
        echo [OK] Reporte generado: test_timings_report.csv
        timeout /t 2
        if exist "test_timings_report.xlsx" (
            start test_timings_report.xlsx
        ) else (
            start test_timings_report.csv
        )
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
pause
goto menu

:end
exit /b 0
