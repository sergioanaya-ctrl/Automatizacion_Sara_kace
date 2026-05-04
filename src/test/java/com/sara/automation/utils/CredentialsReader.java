package com.sara.automation.utils;

import java.util.ResourceBundle;

public class CredentialsReader {

    private static final ResourceBundle bundle = ResourceBundle.getBundle("credentials");

    private CredentialsReader() {}

    public static String getUsuario() {
        return bundle.getString("usuario");
    }

    public static String getContrasena() {
        return bundle.getString("contrasena");
    }
}

