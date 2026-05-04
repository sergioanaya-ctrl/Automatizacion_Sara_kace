package com.sara.automation.ui;

import net.serenitybdd.screenplay.targets.Target;
import org.openqa.selenium.By;

public class LoginPage {

    public static final Target USERNAME = Target.the("username field")
            .located(By.cssSelector("input[name='username'], input[id='username'], input[name='email'], input[type='email']"));

    public static final Target PASSWORD = Target.the("password field")
            .located(By.cssSelector("input[name='password'], input[type='password']"));

    public static final Target LOGIN_BUTTON = Target.the("login button")
            .located(By.cssSelector("button[type='submit'], input[type='submit'], button[id*='login'], button[class*='login']"));

    private LoginPage() {}
}

