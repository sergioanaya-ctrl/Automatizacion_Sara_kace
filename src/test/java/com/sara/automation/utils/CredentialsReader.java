package com.sara.automation.utils;

import java.util.ResourceBundle;

/**
 * Lector de credenciales que utiliza UserPoolManager para asignar usuarios
 * de forma ALEATORIA en ejecuciones paralelas
 * 
 * ESTRATEGIA SIMPLE: Cada test obtiene un usuario aleatorio del pool
 * No requiere detectar runner numbers, thread names, o stack traces
 */
public class CredentialsReader {

    private static final ResourceBundle bundle = ResourceBundle.getBundle("credentials");

    private CredentialsReader() {}

    /**
     * Obtiene el usuario asignado al thread actual
     * En ejecución paralela, cada thread obtiene un usuario aleatorio del pool
     * El mismo thread SIEMPRE obtiene el MISMO usuario (cacheado por thread ID)
     */
    public static String getUsuario() {
        try {
            UserPoolManager.UserCredentials credentials = UserPoolManager.getCredentialsForCurrentThread();
            System.out.println("[CredentialsReader] ✓ USUARIO: " + credentials.getUsuario());
            return credentials.getUsuario();
        } catch (Exception e) {
            System.out.println("[CredentialsReader] ✗ ERROR: " + e.getMessage());
            e.printStackTrace();
            return bundle.getString("usuario");
        }
    }

    /**
     * Obtiene la contraseña asignada al thread actual
     * El mismo thread SIEMPRE obtiene la MISMA contraseña (cacheado por thread ID)
     */
    public static String getContrasena() {
        try {
            UserPoolManager.UserCredentials credentials = UserPoolManager.getCredentialsForCurrentThread();
            System.out.println("[CredentialsReader] ✓ CONTRASEÑA para: " + credentials.getUsuario());
            return credentials.getContrasena();
        } catch (Exception e) {
            System.out.println("[CredentialsReader] ✗ ERROR: " + e.getMessage());
            e.printStackTrace();
            return bundle.getString("contrasena");
        }
    }

    /**
     * Usuario del proveedor (PRUEBAS50) usado para reingresar tras cerrar sesión.
     * Se define en credentials.properties con la clave 'usuario_proveedor'.
     */
    public static String getUsuarioProveedor() {
        return bundle.getString("usuario_proveedor");
    }

    /**
     * Contraseña del proveedor (PRUEBAS50). Se define en credentials.properties
     * con la clave 'contrasena_proveedor'. Nunca se imprime en logs.
     */
    public static String getContrasenaProveedor() {
        return bundle.getString("contrasena_proveedor");
    }
}


