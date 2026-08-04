package com.sara.automation.ui;

import net.serenitybdd.screenplay.targets.Target;
import org.openqa.selenium.By;

public class LoginPage {

    // Generic locators for compatibility
    public static final Target USERNAME = Target.the("Campo de usuario")
            .located(By.cssSelector("input[name='username'], input[id='username'], input[name='email'], input[type='email']"));

    public static final Target PASSWORD = Target.the("Campo de contraseña")
            .located(By.cssSelector("input[name='password'], input[type='password']"));

    public static final Target LOGIN_BUTTON = Target.the("Botón de inicio de sesión")
            .located(By.cssSelector("button[type='submit'], input[type='submit'], button[id*='login'], button[class*='login']"));

    // Cognito specific locators
    public static final String COGNITO_LOGIN_URL = "https://us-east-19gjum8s1z.auth.us-east-1.amazoncognito.com/login?redirect_uri=https%3A%2F%2Frelease-asistencia.kace-cloudtest.com%2Fauth&response_type=code&client_id=761l8390vd1uq3en0n0gt8u2qa";

    public static final Target COGNITO_USERNAME = Target.the("Campo de usuario de Cognito")
            .located(By.cssSelector("input[name='username']"));

    public static final Target COGNITO_NEXT_BUTTON = Target.the("Botón siguiente de Cognito")
            .located(By.cssSelector("button[type='submit']"));

    public static final Target COGNITO_PASSWORD = Target.the("Campo de contraseña de Cognito")
            .located(By.cssSelector("input[name='password']"));

    public static final Target COGNITO_CONTINUE_BUTTON = Target.the("Botón continuar de Cognito")
            .located(By.cssSelector("button[type='submit']"));

    private LoginPage() {}
}

