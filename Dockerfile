# ============================================================
# SARA3 - DOCKER IMAGE PARA TESTS HEADLESS
# Multi-stage build para optimizar tamaño
# ============================================================

# STAGE 1: Builder
FROM eclipse-temurin:11-jdk-jammy AS builder

# Instalar dependencias de construcción
RUN apt-get update && apt-get install -y \
    chromium-browser \
    chromium-chromedriver \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Establecer directorio de trabajo
WORKDIR /app

# Copiar proyecto
COPY . .

# Dar permisos de ejecución a scripts
RUN chmod +x gradlew run_tests.sh batch_test_8p.sh setup_linux.sh

# Compilar proyecto (cachear dependencias)
RUN ./gradlew compileTestJava -q

# ============================================================
# STAGE 2: Runtime
FROM eclipse-temurin:11-jdk-jammy

# Metadatos
LABEL maintainer="Sara3 Automation"
LABEL description="Sara3 Serenity BDD Automation Framework - Headless Tests"
LABEL version="1.0"

# Instalar dependencias runtime
RUN apt-get update && apt-get install -y \
    chromium-browser \
    chromium-chromedriver \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario no-root
RUN useradd -m -s /bin/bash sara3

# Establecer directorio de trabajo
WORKDIR /app

# Copiar proyecto desde builder
COPY --from=builder --chown=sara3:sara3 /app .

# Crear directorios necesarios
RUN mkdir -p logs target/reports && \
    chown -R sara3:sara3 /app

# Cambiar al usuario sara3
USER sara3

# Variables de entorno
ENV DISPLAY=""
ENV QT_QPA_PLATFORM="offscreen"
ENV JAVA_OPTS="-Xmx2048m -Xms512m"
ENV CHROME_BIN="/usr/bin/chromium-browser"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD java -version || exit 1

# Comando por defecto: ejecutar batch test 8 paralelo
ENTRYPOINT ["/bin/bash"]
CMD ["batch_test_8p.sh"]
