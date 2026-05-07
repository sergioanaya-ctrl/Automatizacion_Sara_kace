package com.sara.automation.utils;

import java.util.ResourceBundle;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Lector de credenciales que utiliza UserPoolManager para asignar usuarios
 * de forma automática y thread-safe en ejecuciones paralelas
 */
public class CredentialsReader {

    private static final ResourceBundle bundle = ResourceBundle.getBundle("credentials");
    private static final Pattern RUNNER_PATTERN = Pattern.compile("CasesRunner(\\d+)");
    private static final Pattern GRADLE_WORKER_PATTERN = Pattern.compile("Worker-(\\d+)");

    private CredentialsReader() {}

    /**
     * Detecta el número del runner actual desde múltiples fuentes:
     * 1. Nombre del thread de Gradle (Worker-N)
     * 2. Stack trace (CasesRunnerNN)
     * Esto asegura que cada runner paralelo obtiene un usuario diferente
     */
    private static int detectRunnerNumber() {
        String threadName = Thread.currentThread().getName();
        int runnerNumber = -1;
        
        // INTENTO 1: Buscar en nombre del thread (Gradle asigna "Worker-1", "Worker-2", etc.)
        Matcher workerMatcher = GRADLE_WORKER_PATTERN.matcher(threadName);
        if (workerMatcher.find()) {
            String workerNum = workerMatcher.group(1);
            runnerNumber = Integer.parseInt(workerNum);
            System.out.println("[CredentialsReader] ✓ Detectado Worker: " + threadName + " → Número: " + runnerNumber);
            return runnerNumber;
        }
        
        // INTENTO 2: Buscar en stack trace (CasesRunner01, CasesRunner02, etc.)
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        for (StackTraceElement element : stackTrace) {
            String className = element.getClassName();
            Matcher matcher = RUNNER_PATTERN.matcher(className);
            if (matcher.find()) {
                String runnerNum = matcher.group(1);
                runnerNumber = Integer.parseInt(runnerNum);
                System.out.println("[CredentialsReader] ✓ Detectado CasesRunner: " + className + " → Número: " + runnerNumber);
                return runnerNumber;
            }
        }
        
        // Si no se detectó, usar round-robin con logging detallado
        if (runnerNumber == -1) {
            System.out.println("[CredentialsReader] ℹ No detectado runner específico, usando round-robin (Thread: " + threadName + ")");
        }
        return -1;
    }

    /**
     * Obtiene el usuario asignado al thread actual
     * En ejecución paralela, cada thread obtiene un usuario diferente del pool
     */
    public static String getUsuario() {
        try {
            int runnerNumber = detectRunnerNumber();
            UserPoolManager.UserCredentials credentials;
            
            if (runnerNumber > 0) {
                // Si se detectó un runner, usa su número para obtener usuario específico
                credentials = UserPoolManager.getUserByNumber(runnerNumber);
            } else {
                // Si no se detectó runner, usa round-robin
                credentials = UserPoolManager.getCredentialsForCurrentThread();
            }
            
            String usuario = credentials.getUsuario();
            System.out.println("[CredentialsReader] Usuario seleccionado: " + usuario);
            return usuario;
        } catch (Exception e) {
            // Fallback: si hay error con el pool, usa credenciales simples
            System.out.println("[CredentialsReader] ✗ ERROR - Usando fallback: " + e.getMessage());
            return bundle.getString("usuario");
        }
    }

    /**
     * Obtiene la contraseña asignada al thread actual
     * En ejecución paralela, cada thread obtiene la contraseña de su usuario asignado
     */
    public static String getContrasena() {
        try {
            int runnerNumber = detectRunnerNumber();
            UserPoolManager.UserCredentials credentials;
            
            if (runnerNumber > 0) {
                // Si se detectó un runner, usa su número para obtener usuario específico
                credentials = UserPoolManager.getUserByNumber(runnerNumber);
            } else {
                // Si no se detectó runner, usa round-robin
                credentials = UserPoolManager.getCredentialsForCurrentThread();
            }
            
            String contrasena = credentials.getContrasena();
            System.out.println("[CredentialsReader] Contraseña seleccionada para usuario: " + credentials.getUsuario());
            return contrasena;
        } catch (Exception e) {
            // Fallback: si hay error con el pool, usa credenciales simples
            System.out.println("[CredentialsReader] ✗ ERROR - Usando fallback: " + e.getMessage());
            return bundle.getString("contrasena");
        }
    }
}


