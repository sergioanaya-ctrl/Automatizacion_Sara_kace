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
     * 1. Nombre del thread de Gradle (Worker-N) - mapea a índice del runner
     * 2. Stack trace (CasesRunnerNN) - FUENTE CONFIABLE - retorna directo
     * El stack trace de CasesRunnerNN es la fuente de verdad para el número del runner
     */
    private static int detectRunnerNumber() {
        // INTENTO 1: Buscar en stack trace (CasesRunner01, CasesRunner02, etc.)
        // ESTO ES LA FUENTE DE VERDAD - cada CasesRunnerNN retorna su número directamente
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        for (StackTraceElement element : stackTrace) {
            String className = element.getClassName();
            Matcher matcher = RUNNER_PATTERN.matcher(className);
            if (matcher.find()) {
                String runnerNum = matcher.group(1);
                int number = Integer.parseInt(runnerNum);
                System.out.println("[CredentialsReader] ✓✓✓ DETECTADO CASESRUNNER: " + className + " → USUARIO #" + number);
                return number;
            }
        }
        
        // INTENTO 2: Fallback a Worker-N de Gradle solo si no hay CasesRunner en stack
        String threadName = Thread.currentThread().getName();
        Matcher workerMatcher = GRADLE_WORKER_PATTERN.matcher(threadName);
        if (workerMatcher.find()) {
            String workerNum = workerMatcher.group(1);
            int number = Integer.parseInt(workerNum);
            System.out.println("[CredentialsReader] ℹ Fallback Worker: " + threadName + " → USUARIO #" + number);
            return number;
        }
        
        // Si no se detectó nada, retornar -1 para usar round-robin
        System.out.println("[CredentialsReader] ⚠ NO DETECTADO - Usando round-robin (Thread: " + threadName + ")");
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
                System.out.println("[CredentialsReader] → USUARIO SELECCIONADO: " + credentials.getUsuario());
            } else {
                // Si no se detectó runner, usa round-robin
                credentials = UserPoolManager.getCredentialsForCurrentThread();
                System.out.println("[CredentialsReader] → USUARIO (round-robin): " + credentials.getUsuario());
            }
            
            return credentials.getUsuario();
        } catch (Exception e) {
            // Fallback: si hay error con el pool, usa credenciales simples
            System.out.println("[CredentialsReader] ✗✗✗ ERROR CRÍTICO: " + e.getMessage());
            e.printStackTrace();
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
                System.out.println("[CredentialsReader] → CONTRASEÑA para: " + credentials.getUsuario());
            } else {
                // Si no se detectó runner, usa round-robin
                credentials = UserPoolManager.getCredentialsForCurrentThread();
                System.out.println("[CredentialsReader] → CONTRASEÑA (round-robin) para: " + credentials.getUsuario());
            }
            
            return credentials.getContrasena();
        } catch (Exception e) {
            // Fallback: si hay error con el pool, usa credenciales simples
            System.out.println("[CredentialsReader] ✗✗✗ ERROR CRÍTICO: " + e.getMessage());
            e.printStackTrace();
            return bundle.getString("contrasena");
        }
    }
}


