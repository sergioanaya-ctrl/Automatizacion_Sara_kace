package com.sara.automation.runners;

import com.sara.automation.utils.RunnerContext;
import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

@RunWith(CucumberWithSerenity.class)
@CucumberOptions(
        features = "src/test/resources/features/cases/open_cases.feature",
        glue = "com.sara.automation.stepdefinitions",
        tags = "@batch40",
        snippets = CucumberOptions.SnippetType.UNDERSCORE
)
public class CasesRunner40 {
    // Establecer el numero del runner cuando se carga la clase
    static {
        System.out.println("====== CARGANDO CASESRUNNER40 ======");
        System.setProperty("runnerNumber", "40");
        System.out.println("====== SYSTEM PROPERTY ESTABLECIDO: runnerNumber=40 ======");
    }
}