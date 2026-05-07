# 🤖 Automatización SARA3 - Pruebas Paralelas

Pruebas de automatización **Serenity BDD + Cucumber + Screenplay** para SARA3 con soporte para ejecución paralela de **50 usuarios**.

Gestiona casos en: `https://asistenciaapp.kit.sura-konecta.com/cases`

---

## 🚀 Instalación Rápida (Primer Uso)

### Paso 1: Descargar el proyecto

```bash
git clone <repository-url>
cd Siigo_Front/Sara3
```

### Paso 2: Ejecutar setup automático

En **Windows PowerShell** (como Administrador):

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\setup.ps1
```

✅ Este script verificará Java, descargará dependencias y compilará el proyecto.

---

## ⚙️ Configuración de Runners Paralelos

### Cambiar número de navegadores simultáneos

**Archivo:** `gradle.properties`

```properties
# Número de browsers que se ejecutan al mismo tiempo
maxParallelForks=2
```

**Simplemente cambia el número:**

| Valor | Navegadores | Máquina | Memoria Recomendada |
|-------|-------------|---------|-------------------|
| 2 | 2 | Lenta | 2GB |
| 4 | 4 | Media | 4GB |
| 8 | 8 | Rápida | 8GB |
| 12 | 12 | Muy Rápida | 12GB |
| 50 | 50 (todos) | Servidor | 16GB+ |

---

## 🏃 Ejecutar Pruebas

### Ejecutar todos los 50 runners
```powershell
.\gradlew.bat test
```

### Ejecutar solo N runners (ejemplo: 2)
```powershell
.\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner01" --tests "com.sara.automation.runners.CasesRunner02"
```

### Ejecutar 1 runner (test individual)
```powershell
.\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner01"
```

### Ejecutar rango (runners 01-10)
```powershell
.\gradlew.bat test --tests "*CasesRunner0[1-9]" --tests "*CasesRunner10"
```

---

## 📊 Ver Reportes

Después de ejecutar, abre:
```
target/site/serenity/index.html
```

---

## 👥 Usuarios de Prueba (50 en Total)

Configurados en: `src/test/resources/credentials.properties`

```
pruebas1  - K7m@2xQ9n#
pruebas2  - Bv4!Y8wZ3$
pruebas3  - Hq6#L1cX5!
...
pruebas50 - Cw4#U1hS6$
```

✅ Cada usuario se asigna automáticamente a un navegador diferente.

---

## 📋 Requisitos

- **Java 11 o superior** ([Descargar](https://www.oracle.com/java/technologies/downloads/))
- **Windows PowerShell 5.1+**
- **RAM:**
  - Mínimo: 2GB
  - Recomendado: 4GB+
  - Ideal para 50 runners: 16GB+

---

## 🔧 Solución de Problemas

### ❌ "Java no está instalado"
→ Instala Java desde: https://www.oracle.com/java/technologies/downloads/

### ❌ "OutOfMemory Error"
→ En `gradle.properties` aumenta:
```properties
org.gradle.jvmargs=-Xmx4096m
```

### ❌ "Demasiados browsers abiertos"
→ En `gradle.properties` reduce `maxParallelForks` (ej: 4 en lugar de 12)

### ❌ "Build Failed"
→ Ejecuta nuevamente:
```powershell
.\setup.ps1
```

---

## 📁 Estructura del Proyecto

```
Sara3/
├── setup.ps1                         # 🔧 Setup automático
├── gradle.properties                 # ⚙️ Configuración de runners
├── build.gradle                      # 📦 Configuración Gradle
├── src/test/
│   ├── java/com/sara/automation/
│   │   ├── runners/                 # 50 CasesRunner (1 por usuario)
│   │   ├── tasks/                   # Tareas de automatización
│   │   └── interactions/            # Interacciones con elementos
│   └── resources/
│       ├── credentials.properties    # 50 usuarios
│       ├── features/
│       │   └── open_cases.feature   # Scenarios de prueba
│       └── serenity.conf            # Config Serenity
├── target/site/serenity/            # 📊 Reportes generados
└── README.md                        # 📖 Este archivo
```

---

## 🔄 Flujo de Cada Prueba

1. ✅ Abrir navegador (Chrome maximizado)
2. ✅ Login (con usuario asignado: pruebas1-pruebas50)
3. ✅ Navegar a agente
4. ✅ Crear caso (Caso Express)
5. ✅ Gestionar proveedor (llenar datos)
6. ✅ Transicionar estados:
   - Programado
   - Aceptado y en desplazamiento
   - Concluido
   - Finalizado
7. ✅ Cierre y reporte

---

## 💡 Consejos de Rendimiento

1. **Máquina lenta?** → Usa `maxParallelForks=2`
2. **Máquina rápida?** → Usa `maxParallelForks=12` o más
3. **Muchos runners?** → Aumenta RAM en `gradle.properties`
4. **Lentitud?** → Cierra otros programas antes de ejecutar

---

## 🔗 Enlaces Útiles

- [Serenity BDD](https://serenity-bdd.github.io/)
- [Cucumber](https://cucumber.io/)
- [Gradle](https://gradle.org/)
- [Selenium WebDriver](https://www.selenium.dev/)

---

**Versión:** 1.0  
**Última actualización:** Mayo 2026  
**Estado:** ✅ Listo para producción
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

