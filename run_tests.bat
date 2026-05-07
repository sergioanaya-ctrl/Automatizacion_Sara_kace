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
echo 1. Ejecutar numero personalizado de runners en paralelo
echo 2. Ejecutar 2 runners (paralelo)
echo 3. Ejecutar 4 runners (paralelo)
echo 4. Ejecutar 8 runners (paralelo)
echo 5. Ejecutar 12 runners (paralelo)
echo 6. Ejecutar todos los 50 runners
echo 7. Ejecutar solo 1 runner (test individual)
echo 8. Ver reporte de resultados
echo 9. Salir
echo.
set /p choice="Selecciona opcion (1-9): "

if "%choice%"=="1" goto custom_runners
if "%choice%"=="2" goto two_runners
if "%choice%"=="3" goto four_runners
if "%choice%"=="4" goto eight_runners
if "%choice%"=="5" goto twelve_runners
if "%choice%"=="6" goto all_runners
if "%choice%"=="7" goto one_runner
if "%choice%"=="8" goto report
if "%choice%"=="9" goto exit
echo Opcion invalida. Intenta de nuevo.
pause
goto menu

:custom_runners
cls
echo.
set /p num_runners="Numero de runners a ejecutar (1-50): "
if %num_runners% lss 1 (
    echo Error: Numero debe ser al menos 1
    pause
    goto menu
)
if %num_runners% gtr 50 (
    echo Error: Numero maximo es 50
    pause
    goto menu
)
echo.
echo Configurando maxParallelForks=%num_runners% en gradle.properties...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=%num_runners%
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
echo Ejecutando %num_runners% runners en paralelo...
echo.
call .\gradlew.bat test
pause
goto menu

:two_runners
cls
echo.
echo Configurando 2 runners en paralelo...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=2
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
call .\gradlew.bat test
pause
goto menu

:four_runners
cls
echo.
echo Configurando 4 runners en paralelo...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=4
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
call .\gradlew.bat test
pause
goto menu

:eight_runners
cls
echo.
echo Configurando 8 runners en paralelo...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=8
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
call .\gradlew.bat test
pause
goto menu

:twelve_runners
cls
echo.
echo Configurando 12 runners en paralelo...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=12
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
call .\gradlew.bat test
pause
goto menu

:all_runners
cls
echo.
echo Configurando 50 runners en paralelo...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=50
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
call .\gradlew.bat test
pause
goto menu

:one_runner
cls
echo.
set /p runner="Numero del runner (01-50): "
echo.
echo Ejecutando CasesRunner%runner% (sin paralelismo)...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=1
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
call .\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner%runner%"
pause
goto menu
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
