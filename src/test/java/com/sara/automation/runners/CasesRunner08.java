package com.sara.automation.runners;

import com.sara.automation.utils.RunnerContext;
import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

@RunWith(CucumberWithSerenity.class)
@CucumberOptions(
        features = "src/test/resources/features/cases/open_cases.feature",
        glue = "com.sara.automation.stepdefinitions",
        tags = "@batch8",
        snippets = CucumberOptions.SnippetType.UNDERSCORE
)
public class CasesRunner08 {
    // Establecer el numero del runner cuando se carga la clase
    static {
        System.out.println("====== CARGANDO CASESRUNNER08 ======");
        RunnerContext.setRunnerNumber(8);
        System.out.println("====== RUNNERCONTEXT ESTABLECIDO: #8 ======");
    }
}