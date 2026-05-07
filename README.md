# Serenity + Cucumber + Screenplay (Sara3)

Proyecto de automatización que gestiona casos en:

- `https://asistenciaapp.kit.sura-konecta.com/cases`

## 🚀 Ejecución Paralela con Múltiples Usuarios

**CONFIGURADO:** Este proyecto soporta **ejecución paralela con 50 usuarios concurrentes** (BOT01 - BOT50).

### Ejecución Rápida
```batch
# Opción 1: Script interactivo (RECOMENDADO)
ejecutar_paralelo.bat

# Opción 2: Comando directo - 50 usuarios
.\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner??"

# Opción 3: Comando directo - 12 usuarios
.\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner01" --tests "com.sara.automation.runners.CasesRunner02" ... --tests "com.sara.automation.runners.CasesRunner12"
```

### 📊 Configuración Actual
- **50 runners creados**: CasesRunner01.java hasta CasesRunner50.java
- **50 escenarios**: Uno por cada runner con tag @batch1 a @batch50
- **50 usuarios**: BOT01 hasta BOT50 en credentials.properties
- **Asignación automática**: UserPoolManager asigna usuarios por thread
- **Paralelismo**: 12 navegadores simultáneos (configurable en build.gradle)

📖 **[Ver documentación completa de ejecución paralela](EJECUCION_PARALELA.md)**

---

## Archivos clave

- `build.gradle`
- `serenity.properties`
- `src/test/resources/features/cases/open_cases.feature`
- `src/test/java/com/sara/automation/runners/CasesRunner.java`
- `src/test/java/com/sara/automation/stepdefinitions/CasesStepDefinitions.java`
- `src/test/java/com/sara/automation/tasks/OpenCasesPage.java`
- `src/test/java/com/sara/automation/ui/CasesPage.java`
- **`src/test/java/com/sara/automation/utils/UserPoolManager.java`** (Gestor de usuarios paralelos)
- **`src/test/resources/credentials.properties`** (Pool de 50 usuarios)

## Ejecutar pruebas (Windows PowerShell)

### Modo Secuencial (1 usuario)
```powershell
.\gradlew.bat clean test aggregate --max-workers=1
```

### Modo Paralelo (múltiples usuarios)
```powershell
# Automático (usa CPUs/2)
.\gradlew.bat test --tests CasesRunner

# Especificar forks manualmente
.\gradlew.bat test --tests CasesRunner --max-workers=10
```

## Reporte

Despues de ejecutar, revisa el reporte Serenity en:

- `target/site/serenity/index.html` (ruta comun)
- o `build/reports/serenity` (segun configuracion/version)

Generar reporte:
```powershell
.\gradlew.bat aggregate
```

## Nota

La configuracion actual usa Chrome en modo headless definido en `serenity.properties`.

