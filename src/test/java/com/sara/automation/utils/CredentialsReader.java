package com.sara.automation.utils;

import java.util.ResourceBundle;

/**
 * Lector de credenciales que utiliza UserPoolManager para asignar usuarios
 * de forma automática y thread-safe en ejecuciones paralelas
 */
public class CredentialsReader {

    private static final ResourceBundle bundle = ResourceBundle.getBundle("credentials");

    private CredentialsReader() {}

    /**
     * Obtiene el usuario asignado al thread actual
     * En ejecución paralela, cada thread obtiene un usuario diferente del pool
     */
    public static String getUsuario() {
        // Intenta usar el pool de usuarios si está disponible
        try {
            UserPoolManager.UserCredentials credentials = UserPoolManager.getCredentialsForCurrentThread();
            return credentials.getUsuario();
        } catch (Exception e) {
            // Fallback: si hay error con el pool, usa credenciales simples
            System.out.println("[CredentialsReader] Usando fallback - usuario simple");
            return bundle.getString("usuario");
        }
    }

    /**
     * Obtiene la contraseña asignada al thread actual
     * En ejecución paralela, cada thread obtiene la contraseña de su usuario asignado
     */
    public static String getContrasena() {
        // Intenta usar el pool de usuarios si está disponible
        try {
            UserPoolManager.UserCredentials credentials = UserPoolManager.getCredentialsForCurrentThread();
            return credentials.getContrasena();
        } catch (Exception e) {
            // Fallback: si hay error con el pool, usa credenciales simples
            System.out.println("[CredentialsReader] Usando fallback - contrasena simple");
            return bundle.getString("contrasena");
        }
    }
}

