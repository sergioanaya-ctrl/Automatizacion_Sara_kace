package com.sara.automation.runners;

import com.sara.automation.utils.RunnerContext;
import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

@RunWith(CucumberWithSerenity.class)
@CucumberOptions(
        features = "src/test/resources/features/cases/open_cases.feature",
        glue = "com.sara.automation.stepdefinitions",
        tags = "@batch20",
        snippets = CucumberOptions.SnippetType.UNDERSCORE
)
public class CasesRunner20 {
    // Establecer el numero del runner cuando se carga la clase
    static {
        System.out.println("====== CARGANDO CASESRUNNER20 ======");
        System.setProperty("runnerNumber", "20");
        System.out.println("====== SYSTEM PROPERTY ESTABLECIDO: runnerNumber=20 ======");
    }
}