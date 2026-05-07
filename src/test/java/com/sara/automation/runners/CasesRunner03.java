package com.sara.automation.runners;

import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

@RunWith(CucumberWithSerenity.class)
@CucumberOptions(
        features = "src/test/resources/features/cases/open_cases.feature",
        glue = "com.sara.automation.stepdefinitions",
        tags = "@batch3",
        snippets = CucumberOptions.SnippetType.UNDERSCORE
)
public class CasesRunner03 {
    // Establecer el numero del runner cuando se carga la clase
    static {
        System.out.println("====== CARGANDO CASESRUNNER03 ======");
        System.setProperty("runnerNumber", "3");
        System.out.println("====== SYSTEM PROPERTY ESTABLECIDO: runnerNumber=3 ======");
    }
}