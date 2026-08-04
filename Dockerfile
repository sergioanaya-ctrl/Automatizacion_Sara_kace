# ============================================================
# SARA3 - DOCKER IMAGE COMPACTA PARA TESTS HEADLESS + ESPAÑOL
# ============================================================

# STAGE 1: Builder (JDK + Gradle Dependencies)
FROM eclipse-temurin:11-jdk-jammy AS builder
WORKDIR /app

# ========================================================
# CAPA 1: Dependencias de Gradle (se cachean)
# Copiar SOLO archivos de configuración para descargar dependencias
# Si build.gradle no cambia, esta capa se reutiliza (MUCHO más rápido)
# ========================================================
COPY build.gradle settings.gradle gradle.properties ./
COPY gradle/ ./gradle/
COPY gradlew ./
RUN apt-get update && apt-get install -y --no-install-recommends wget gnupg git && \
    find . -type f \( -name "*.sh" -o -name "gradlew" \) -exec sed -i 's/\r$//' {} + && \
    chmod +x gradlew && \
    ./gradlew --version && \
    ./gradlew dependencies --write-locks 2>&1 || true && \
    ./gradlew build -x test --dry-run 2>&1 || true

# ========================================================
# CAPA 2: Código fuente (se cachea independientemente)
# ========================================================
COPY . .
RUN find . -type f \( -name "*.sh" -o -name "gradlew" \) -exec sed -i 's/\r$//' {} + && \
    chmod +x gradlew run-tests-linux.sh

# ============================================================
# STAGE 2: Runtime - ejecutar tests con JDK + Chrome + ESPAÑOL
FROM eclipse-temurin:11-jdk-jammy
WORKDIR /app

# Instalar Google Chrome stable + dependencias X11 + locales de español
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget gnupg xvfb x11-utils x11-xserver-utils dbus dbus-x11 \
    language-pack-es language-pack-es-base locales && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y --no-install-recommends google-chrome-stable && \
    locale-gen es_ES.UTF-8 && \
    update-locale LANG=es_ES.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# Copiar TODO del builder (incluyendo .gradle cache)
COPY --from=builder /app /app

# Copiar scripts de entrada y menú
COPY docker-entrypoint.sh /usr/local/bin/
COPY docker-menu.sh /app/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh /app/docker-menu.sh

# Configurar permisos
RUN chmod +x gradlew run-tests-linux.sh && \
    mkdir -p logs target/reports

# Variables de entorno - Chrome en ESPAÑOL
ENV DISPLAY=:99 \
    QT_QPA_PLATFORM="offscreen" \
    JAVA_OPTS="-Xmx2048m -Xms512m" \
    CHROME_BIN="/usr/bin/google-chrome" \
    CHROME_DBUS_STUB_ONLY=1 \
    CHROME_HEADLESS=1 \
    DBUS_SYSTEM_BUS_ADDRESS="unix:path=/run/dbus/system_bus_socket" \
    LANG=es_ES.UTF-8 \
    LANGUAGE=es_ES:es \
    LC_ALL=es_ES.UTF-8 \
    LC_CTYPE=es_ES.UTF-8 \
    TZ=America/Bogota

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []
