@echo off
REM ========================================================
REM Ejecutor de Pruebas - Interface Fácil
REM ========================================================

setlocal enabledelayedexpansion

:menu
cls
echo.
echo ========================================================
echo         AUTOMATIZACION SARA3 - EJECUCION DE PRUEBAS
echo ========================================================
echo.
echo 1. Ejecutar todos los 50 runners
echo 2. Ejecutar solo 2 runners (paralelo)
echo 3. Ejecutar solo 1 runner (test individual)
echo 4. Ver reporte de resultados
echo 5. Salir
echo.
set /p choice="Selecciona opcion (1-5): "

if "%choice%"=="1" goto all_runners
if "%choice%"=="2" goto two_runners
if "%choice%"=="3" goto one_runner
if "%choice%"=="4" goto report
if "%choice%"=="5" goto exit
echo Opcion invalida. Intenta de nuevo.
pause
goto menu

:all_runners
cls
echo.
echo Ejecutando TODOS los 50 runners...
echo.
call .\gradlew.bat test
pause
goto menu

:two_runners
cls
echo.
echo Ejecutando 2 runners en paralelo...
echo.
call .\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner01" --tests "com.sara.automation.runners.CasesRunner02"
pause
goto menu

:one_runner
cls
echo.
set /p runner="Numero del runner (01-50): "
echo.
echo Ejecutando CasesRunner%runner%...
echo.
call .\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner%runner%"
pause
goto menu

:report
cls
echo.
if exist "target\site\serenity\index.html" (
    echo Abriendo reporte...
    start target\site\serenity\index.html
) else (
    echo No se encontro reporte. Ejecuta primero algunas pruebas.
    pause
)
goto menu

:exit
echo.
echo Hasta luego!
echo.
exit /b 0
