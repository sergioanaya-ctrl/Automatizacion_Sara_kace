package com.sara.automation.runners;

import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

@RunWith(CucumberWithSerenity.class)
@CucumberOptions(
        features = "src/test/resources/features/cases/open_cases.feature",
        glue = "com.sara.automation.stepdefinitions",
        tags = "@batch51",
        snippets = CucumberOptions.SnippetType.UNDERSCORE
)
public class CasesRunner51 {
    // Escenario de RECLAMACIONES (flujo independiente del de creación/proveedor).
    // Los usuarios se asignan ALEATORIAMENTE desde UserPoolManager.
}
