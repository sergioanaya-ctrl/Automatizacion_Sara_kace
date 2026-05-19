# ============================================================
# SARA3 - DOCKER IMAGE COMPACTA PARA TESTS HEADLESS
# ============================================================

# STAGE 1: Builder
FROM eclipse-temurin:11-jdk-jammy AS builder
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium-browser chromium-chromedriver git && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x gradlew run-tests-linux.sh && \
    ./gradlew --version && ./gradlew dependencies --write-locks 2>&1 || true

# ============================================================
# STAGE 2: Runtime - ejecutar tests con JDK (no JRE)
FROM eclipse-temurin:11-jdk-jammy
WORKDIR /app

# Instalar TODAS las dependencias runtime que Chrome necesita
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium-browser chromium-chromedriver \
    xvfb x11-utils x11-xserver-utils dbus dbus-x11 \
    libnspr4 libnss3 libatk1.0-0 libatk-bridge2.0-0 \
    libgtk-3-0 libx11-6 libxcomposite1 libxcursor1 libxdamage1 \
    libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
    libxinerama1 libxkbcommon0 libpangocairo-1.0-0 \
    fonts-liberation fonts-dejavu-core ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copiar TODO del builder
COPY --from=builder /app /app

# Copiar script de entrada
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Configurar permisos
RUN chmod +x gradlew run-tests-linux.sh /usr/bin/chromedriver && \
    mkdir -p logs target/reports

# Variables de entorno
ENV DISPLAY=:99 \
    QT_QPA_PLATFORM="offscreen" \
    JAVA_OPTS="-Xmx2048m -Xms512m" \
    CHROME_BIN="/usr/bin/chromium-browser" \
    CHROME_DBUS_STUB_ONLY=1 \
    CHROME_HEADLESS=1 \
    DBUS_SYSTEM_BUS_ADDRESS="unix:path=/run/dbus/system_bus_socket"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []
