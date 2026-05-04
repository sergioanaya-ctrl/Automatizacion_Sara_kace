# Serenity + Cucumber + Screenplay (Sara3)

Proyecto listo para ejecutar una automatizacion que abre:

- `https://asistenciaapp.kit.sura-konecta.com/cases`

## Archivos clave

- `build.gradle`
- `serenity.properties`
- `src/test/resources/features/cases/open_cases.feature`
- `src/test/java/com/sara/automation/runners/CasesRunner.java`
- `src/test/java/com/sara/automation/stepdefinitions/CasesStepDefinitions.java`
- `src/test/java/com/sara/automation/tasks/OpenCasesPage.java`
- `src/test/java/com/sara/automation/ui/CasesPage.java`

## Ejecutar pruebas (Windows PowerShell)

```powershell
.\gradlew.bat clean test aggregate
```

## Reporte

Despues de ejecutar, revisa el reporte Serenity en:

- `target/site/serenity/index.html` (ruta comun)
- o `build/reports/serenity` (segun configuracion/version)

## Nota

La configuracion actual usa Chrome en modo headless definido en `serenity.properties`.

