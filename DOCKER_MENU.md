# 🚀 SARA3 - Menú Interactivo Docker

## Uso Rápido

### Windows - Doble Click
```batch
EJECUTAR_TESTS.bat
```

### Linux/Mac - Terminal
```bash
docker run --rm -it \
  -v "$PWD/target:/app/target" \
  -v "$PWD/logs:/app/logs" \
  sara3:latest
```

## 📋 Opciones del Menú

Cuando el contenedor inicia, verás un menú interactivo con las siguientes opciones:

### 1️⃣ Ejecutar número personalizado de runners
- Te permite especificar cuántos tests ejecutar en paralelo (1-50)
- Ejemplo: `8` ejecutará 8 tests simultáneamente

### 2️⃣ Ejecutar 2 runners en paralelo
- Ejecuta 2 tests al mismo tiempo
- Ideal para máquinas con recursos limitados

### 3️⃣ Ejecutar 4 runners en paralelo
- Ejecuta 4 tests simultáneamente
- Balance entre velocidad y recursos

### 4️⃣ Ejecutar 8 runners en paralelo
- Ejecuta 8 tests al mismo tiempo
- **Configuración recomendada** para la mayoría de máquinas

### 5️⃣ Ejecutar 12 runners en paralelo
- Ejecuta 12 tests simultáneamente
- Requiere máquina con buenos recursos

### 6️⃣ Ejecutar 50 runners en paralelo (TODOS)
- Ejecuta TODOS los 50 tests al mismo tiempo
- ⚠️ **ADVERTENCIA**: Requiere recursos significativos
- Puede saturar CPU y memoria

### 7️⃣ Ejecutar 1 runner individual
- Ejecuta un solo test específico
- Te pedirá el número (1-50)
- Útil para depuración

### 8️⃣ Ver reporte HTML
- Muestra la ruta donde se encuentra el reporte generado
- Los reportes están en `target/site/serenity/index.html`
- Accesible desde tu máquina host gracias al volumen montado

### 9️⃣ Ver configuración actual
- Muestra:
  - Versión de Java
  - Versión de Chrome/Chromium
  - Configuración de paralelización
  - Variables de entorno

### 🔟 Limpiar reportes
- Elimina reportes anteriores
- Limpia: `target/site/serenity/*`, `target/test-results/*`, `build/reports/*`

### 1️⃣1️⃣ Salir del contenedor
- Cierra el menú y detiene el contenedor

## 🔧 Modo Comando Directo (Sin Menú)

Si no quieres usar el menú interactivo, puedes ejecutar comandos directamente:

### Ejecutar test específico:
```bash
docker run --rm \
  -v "$PWD/target:/app/target" \
  sara3:latest \
  "./gradlew test --tests com.sara.automation.runners.CasesRunner15"
```

### Ejecutar todos los tests:
```bash
docker run --rm \
  -v "$PWD/target:/app/target" \
  sara3:latest \
  "./gradlew test --parallel"
```

### Ejecutar bash (debugging):
```bash
docker run --rm -it \
  -v "$PWD/target:/app/target" \
  sara3:latest \
  bash
```

## 📊 Ver Reportes

Los reportes se generan en `target/site/serenity/index.html` dentro del contenedor, pero gracias al volumen montado (`-v "$PWD/target:/app/target"`), puedes acceder a ellos desde tu máquina host:

**Windows:**
```
target\site\serenity\index.html
```

**Linux/Mac:**
```
target/site/serenity/index.html
```

Simplemente abre el archivo en tu navegador.

## 🐛 Troubleshooting

### El menú no aparece
- Asegúrate de usar `-it` en el comando `docker run`
- Ejemplo: `docker run --rm -it sara3:latest`

### No puedo ver los reportes
- Verifica que montaste el volumen: `-v "$PWD/target:/app/target"`
- Los reportes se guardan en `target/site/serenity/`

### Tests fallan con Chrome
- El contenedor ya tiene Google Chrome instalado y configurado
- Usa modo headless automáticamente (ya configurado)

### Quiero usar más runners pero mi PC se traba
- Reduce el número de runners paralelos
- 8 runners es el valor recomendado
- Para debugging, usa solo 1 runner (opción 7)

## 📝 Notas

- El contenedor incluye Xvfb (servidor X virtual) para ejecutar Chrome en modo headless
- Los tests se ejecutan con `--continue`, por lo que un test fallido NO detiene los demás
- La configuración de paralelización se guarda en `gradle.properties`
- Los volumenes permiten que los reportes persistan incluso después de detener el contenedor

## 🆘 Ayuda Adicional

Para más información consulta:
- `DOCKER_GUIDE.md` - Guía completa de Docker
- `DOCKER_QUICKSTART.md` - Inicio rápido
- `run_tests.bat` - Versión Windows con menú similar
