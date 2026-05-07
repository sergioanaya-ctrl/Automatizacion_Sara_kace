package com.sara.automation.runners;

import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

@RunWith(CucumberWithSerenity.class)
@CucumberOptions(
        features = "src/test/resources/features/cases/open_cases.feature",
        glue = "com.sara.automation.stepdefinitions",
        tags = "@batch1",
        snippets = CucumberOptions.SnippetType.UNDERSCORE
)
public class CasesRunner01 {
    // Establecer el número del runner cuando se carga la clase
    static {
        System.out.println("====== CARGANDO CASESRUNNER01 ======");
        System.setProperty("runnerNumber", "1");
        System.out.println("====== SYSTEM PROPERTY ESTABLECIDO: runnerNumber=1 ======");
    }
}
