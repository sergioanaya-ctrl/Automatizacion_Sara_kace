package com.sara.automation.runners;

import com.sara.automation.utils.RunnerContext;
import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

@RunWith(CucumberWithSerenity.class)
@CucumberOptions(
        features = "src/test/resources/features/cases/open_cases.feature",
        glue = "com.sara.automation.stepdefinitions",
        tags = "@batch27",
        snippets = CucumberOptions.SnippetType.UNDERSCORE
)
public class CasesRunner27 {
    // Establecer el numero del runner cuando se carga la clase
    static {
        System.out.println("====== CARGANDO CASESRUNNER27 ======");
        RunnerContext.setRunnerNumber(27);
        System.out.println("====== RUNNERCONTEXT ESTABLECIDO: #27 ======");
    }
}