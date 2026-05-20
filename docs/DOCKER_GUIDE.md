# 🐳 GUÍA DOCKER - SARA3 AUTOMATION

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Construcción de Imagen](#construcción-de-imagen)
3. [Ejecución de Contenedores](#ejecución-de-contenedores)
4. [Docker Compose](#docker-compose)
5. [Volúmenes y Reportes](#volúmenes-y-reportes)
6. [CI/CD Integration](#cicd-integration)
7. [Troubleshooting](#troubleshooting)

---

## 📦 Requisitos Previos

### En tu máquina host

- Docker instalado (v20.10+)
- Docker Compose instalado (v1.29+)
- ~5 GB de espacio en disco

### Verificar instalación

```bash
docker --version
docker-compose --version
```

---

## 🔨 Construcción de Imagen

### 1. **Build básico**

```bash
# Clonar proyecto
git clone https://github.com/sergio129/Sara3.git
cd Sara3

# Construir imagen
docker build -t sara3:latest .

# Verificar imagen
docker images | grep sara3
```

### 2. **Build con etiquetas específicas**

```bash
# Por fecha
docker build -t sara3:$(date +%Y%m%d) .

# Por versión
docker build -t sara3:1.0 .
docker build -t sara3:latest .

# Con múltiples tags
docker build -t sara3:latest -t sara3:1.0 -t sara3:prod .
```

### 3. **Build optimizado (sin cache)**

```bash
docker build --no-cache -t sara3:latest .
```

### 4. **Ver proceso de build**

```bash
docker build -t sara3:latest . --progress=plain
```

---

## 🚀 Ejecución de Contenedores

### 1. **Batch Tests 8 Paralelo (sin menú)**

```bash
# Ejecución simple
docker run --rm sara3:latest batch_test_8p.sh

# Con volúmenes para reportes
docker run --rm \
  -v $(pwd)/reports:/app/target/reports \
  -v $(pwd)/logs:/app/logs \
  sara3:latest \
  batch_test_8p.sh

# Con límite de recursos
docker run --rm \
  --cpus="2" \
  --memory="4g" \
  -v $(pwd)/reports:/app/target/reports \
  sara3:latest \
  batch_test_8p.sh
```

### 2. **Menú Interactivo (para desarrollo)**

```bash
# Ejecutar menú interactivo
docker run -it --rm \
  -v $(pwd)/reports:/app/target/reports \
  -v $(pwd)/logs:/app/logs \
  sara3:latest \
  ./run_tests.sh
```

### 3. **Test Individual (debugging)**

```bash
# Ejecutar test número 1
docker run --rm \
  -v $(pwd)/reports:/app/target/reports \
  sara3:latest \
  bash -c "./gradlew test --tests 'com.sara.automation.runners.CasesRunner01'"

# Ejecutar test número 15
docker run --rm \
  -v $(pwd)/reports:/app/target/reports \
  sara3:latest \
  bash -c "./gradlew test --tests 'com.sara.automation.runners.CasesRunner15'"
```

### 4. **Ejecutar shell interactivo (debugging)**

```bash
docker run -it --rm \
  -v $(pwd)/reports:/app/target/reports \
  sara3:latest \
  /bin/bash
```

### 5. **Con variables de entorno**

```bash
docker run --rm \
  -e JAVA_OPTS="-Xmx4096m -Xms1024m" \
  -e maxParallelForks=8 \
  -v $(pwd)/reports:/app/target/reports \
  sara3:latest \
  batch_test_8p.sh
```

---

## 🐋 Docker Compose

### 1. **Ejecutar batch tests (recomendado)**

```bash
# Batchtests 8 paralelo
docker-compose up sara3-batch

# Sin ver logs
docker-compose up -d sara3-batch
```

### 2. **Menú interactivo**

```bash
# Ejecutar servicio interactivo
docker-compose up sara3-interactive
```

### 3. **Test individual**

```bash
# Cambiar TEST_NUM en docker-compose.yml primero
docker-compose up sara3-single

# O pasar variable
docker-compose run -e TEST_NUM=05 sara3-single
```

### 4. **Ver logs**

```bash
# Logs en tiempo real
docker-compose logs -f sara3-batch

# Últimas 100 líneas
docker-compose logs --tail=100 sara3-batch

# Ver todos los servicios
docker-compose logs -f
```

### 5. **Limpiar contenedores**

```bash
# Parar todos
docker-compose stop

# Eliminar contenedores
docker-compose down

# Eliminar todo incluyendo volúmenes
docker-compose down -v

# Eliminar imágenes también
docker-compose down --rmi all
```

---

## 📁 Volúmenes y Reportes

### 1. **Volúmenes nombrados**

```bash
# Crear volumen
docker volume create sara3-reports

# Ver volúmenes
docker volume ls

# Inspeccionar volumen
docker volume inspect sara3-reports

# Eliminar volumen
docker volume rm sara3-reports
```

### 2. **Montar directorios locales**

```bash
# En Linux/Mac
docker run --rm \
  -v $(pwd)/reports:/app/target/reports \
  sara3:latest \
  batch_test_8p.sh

# En Windows (PowerShell)
docker run --rm `
  -v ${PWD}/reports:C:/app/target/reports `
  sara3:latest `
  batch_test_8p.sh

# En Windows (cmd)
docker run --rm ^
  -v %cd%/reports:C:/app/target/reports ^
  sara3:latest ^
  batch_test_8p.sh
```

### 3. **Acceder a reportes**

```bash
# Después de ejecutar
ls -lh reports/
cat reports/step_details_*.csv

# Ver reporte HTML
open reports/step_details_*.html  # Mac
xdg-open reports/step_details_*.html  # Linux
start reports\step_details_*.html  # Windows

# Copiar reportes desde contenedor
docker cp <container-id>:/app/target/reports ./reports_local
```

---

## 🔄 CI/CD Integration

### **GitLab CI**

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test

variables:
  DOCKER_DRIVER: overlay2

build_image:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t sara3:$CI_COMMIT_SHA -t sara3:latest .
    - docker run --rm sara3:latest batch_test_8p.sh
  artifacts:
    paths:
      - target/reports/
    reports:
      junit: build/test-results/test/**/*.xml

batch_tests:
  stage: test
  image: sara3:latest
  script:
    - ./batch_test_8p.sh
  artifacts:
    paths:
      - target/reports/
      - logs/
  schedule:
    - cron: "0 2 * * *"  # Diariamente a las 2 AM
```

### **GitHub Actions**

```yaml
# .github/workflows/docker-batch-tests.yml
name: Docker Batch Tests

on:
  schedule:
    - cron: "0 2 * * *"  # Diariamente a las 2 AM
  workflow_dispatch:

jobs:
  batch_tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
      
      - name: Build Docker image
        uses: docker/build-push-action@v2
        with:
          context: .
          push: false
          load: true
          tags: sara3:latest
      
      - name: Run batch tests
        run: |
          docker run --rm \
            -v $(pwd)/reports:/app/target/reports \
            sara3:latest \
            batch_test_8p.sh
      
      - name: Upload reports
        if: always()
        uses: actions/upload-artifact@v2
        with:
          name: batch-reports
          path: reports/
```

---

## 📊 Ejemplos Avanzados

### 1. **Batch tests con notificación (webhook)**

```bash
docker run --rm \
  -e WEBHOOK_URL="https://hooks.slack.com/..." \
  -v $(pwd)/reports:/app/target/reports \
  sara3:latest \
  batch_test_8p.sh
```

### 2. **Ejecutar tests en paralelo (3 contenedores simultáneamente)**

```bash
# Terminal 1: Tests 1-16
docker run --rm \
  -e TEST_RANGE="1-16" \
  -v $(pwd)/reports1:/app/target/reports \
  sara3:latest \
  batch_test_8p.sh

# Terminal 2: Tests 17-33
docker run --rm \
  -e TEST_RANGE="17-33" \
  -v $(pwd)/reports2:/app/target/reports \
  sara3:latest \
  batch_test_8p.sh

# Terminal 3: Tests 34-50
docker run --rm \
  -e TEST_RANGE="34-50" \
  -v $(pwd)/reports3:/app/target/reports \
  sara3:latest \
  batch_test_8p.sh
```

### 3. **Contenedor que se ejecuta indefinidamente**

```bash
docker run -d \
  --name sara3-daemon \
  --restart unless-stopped \
  -v $(pwd)/reports:/app/target/reports \
  sara3:latest \
  tail -f /dev/null
```

### 4. **Inspeccionar contenedor ejecutándose**

```bash
# Ver procesos dentro del contenedor
docker exec sara3-daemon ps aux

# Ejecutar bash dentro del contenedor corriendo
docker exec -it sara3-daemon /bin/bash

# Ver archivos generados
docker exec sara3-daemon ls -lh /app/target/reports/
```

---

## 🔍 Troubleshooting

### 1. **"No space left on device"**

```bash
# Ver uso de disco de Docker
docker system df

# Limpiar sistemas no utilizados
docker system prune

# Limpiar todo (agresivo)
docker system prune -a --volumes
```

### 2. **"Cannot connect to Docker daemon"**

```bash
# Iniciar servicio Docker (Linux)
sudo systemctl start docker

# O en macOS
open /Applications/Docker.app

# Verificar que funciona
docker ps
```

### 3. **"Permission denied"**

```bash
# En Linux, agregar usuario al grupo docker
sudo usermod -aG docker $USER
newgrp docker

# O usar sudo
sudo docker run ...
```

### 4. **Contenedor sale inmediatamente**

```bash
# Ver logs
docker logs <container-id>

# Ver con más detalle
docker logs --details <container-id>

# Ejecutar con stdout
docker run -it sara3:latest batch_test_8p.sh
```

### 5. **Reportes no se generan**

```bash
# Verificar volúmenes
docker volume ls

# Inspeccionar volumen
docker volume inspect sara3-reports

# Ver contenido del volumen
docker run --rm -v sara3-reports:/data busybox ls -lh /data

# Verificar permisos
docker run --rm -v sara3-reports:/data busybox stat /data
```

### 6. **Chrome crashea dentro del contenedor**

```bash
# Aumentar memoria
docker run --rm \
  --memory="4g" \
  -v $(pwd)/reports:/app/target/reports \
  sara3:latest \
  batch_test_8p.sh

# Agregar opciones de Chrome
docker run --rm \
  -e CHROME_ARGS="--disable-gpu --no-sandbox" \
  -v $(pwd)/reports:/app/target/reports \
  sara3:latest \
  batch_test_8p.sh
```

---

## 📈 Monitoreo

### 1. **Monitorear contenedores corriendo**

```bash
# Ver stats en tiempo real
docker stats

# Ver stats de contenedor específico
docker stats sara3-batch
```

### 2. **Ver historial de ejecuciones**

```bash
# Contenedores que terminaron
docker ps -a

# Ver logs históricos
docker logs --since 2h <container-id>

# Exportar logs
docker logs <container-id> > container_logs.txt
```

---

## 🎯 Cheat Sheet Rápido

```bash
# Build
docker build -t sara3:latest .

# Batch tests
docker run --rm -v $(pwd)/reports:/app/target/reports sara3:latest batch_test_8p.sh

# Menú interactivo
docker run -it --rm -v $(pwd)/reports:/app/target/reports sara3:latest ./run_tests.sh

# Con Compose
docker-compose up sara3-batch
docker-compose down

# Ver logs
docker logs -f <container-id>

# Limpiar
docker system prune -a
```

---

## 📞 Soporte

- **Dockerfile**: Multi-stage build optimizado
- **docker-compose.yml**: 3 servicios (batch, interactive, single)
- **.dockerignore**: Excluye archivos innecesarios
- **Volúmenes**: Para reportes y logs persistentes
- **Health Checks**: Monitoreo de contenedores




