package com.sara.automation.utils;

import org.openqa.selenium.chrome.ChromeOptions;

/**
 * Configuración de Chrome para ejecutar en Windows y Linux (headless)
 */
public class ChromeHeadlessConfig {

    public static ChromeOptions getChromeOptions() {
        ChromeOptions options = new ChromeOptions();
        
        // Detectar sistema operativo
        String os = System.getProperty("os.name").toLowerCase();
        boolean isLinux = os.contains("linux");
        
        // Opciones comunes
        options.addArguments("--start-maximized");
        options.addArguments("--remote-allow-origins=*");
        options.addArguments("--disable-blink-features=AutomationControlled");
        options.addArguments("--disable-dev-shm-usage");  // Importante para Linux
        options.addArguments("--no-sandbox");              // Importante para Linux en contenedores
        
        // Modo headless solo en Linux
        if (isLinux) {
            options.addArguments("--headless");
            options.addArguments("--disable-gpu");
            System.out.println("[ChromeHeadlessConfig] ✓ Modo HEADLESS activado para Linux");
        } else {
            System.out.println("[ChromeHeadlessConfig] ✓ Modo NORMAL (GUI) para Windows");
        }
        
        return options;
    }
    
    public static boolean isHeadlessMode() {
        String os = System.getProperty("os.name").toLowerCase();
        return os.contains("linux");
    }
}
