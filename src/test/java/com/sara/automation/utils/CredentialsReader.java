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

    private CredentialsReader() {}

    /**
     * Detecta el número del runner actual desde el stack trace
     * Busca una clase que contenga "CasesRunnerNN" y extrae el número
     */
    private static int detectRunnerNumber() {
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        for (StackTraceElement element : stackTrace) {
            String className = element.getClassName();
            Matcher matcher = RUNNER_PATTERN.matcher(className);
            if (matcher.find()) {
                String runnerNum = matcher.group(1);
                int number = Integer.parseInt(runnerNum);
                System.out.println("[CredentialsReader] Detectado runner: CasesRunner" + runnerNum + " (número: " + number + ")");
                return number;
            }
        }
        return -1; // No se detectó runner
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
            return credentials.getUsuario();
        } catch (Exception e) {
            // Fallback: si hay error con el pool, usa credenciales simples
            System.out.println("[CredentialsReader] ERROR - Usando fallback: " + e.getMessage());
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
            return credentials.getContrasena();
        } catch (Exception e) {
            // Fallback: si hay error con el pool, usa credenciales simples
            System.out.println("[CredentialsReader] ERROR - Usando fallback: " + e.getMessage());
            return bundle.getString("contrasena");
        }
    }
}


