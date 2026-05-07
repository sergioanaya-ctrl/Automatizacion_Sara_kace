package com.sara.automation.runners;

import com.sara.automation.utils.RunnerContext;
import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

@RunWith(CucumberWithSerenity.class)
@CucumberOptions(
        features = "src/test/resources/features/cases/open_cases.feature",
        glue = "com.sara.automation.stepdefinitions",
        tags = "@batch28",
        snippets = CucumberOptions.SnippetType.UNDERSCORE
)
public class CasesRunner28 {
    // Establecer el numero del runner cuando se carga la clase
    static {
        System.out.println("====== CARGANDO CASESRUNNER28 ======");
        System.setProperty("runnerNumber", "28");
        System.out.println("====== SYSTEM PROPERTY ESTABLECIDO: runnerNumber=28 ======");
    }
}