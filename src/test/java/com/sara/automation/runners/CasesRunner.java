package com.sara.automation.runners;

import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

@RunWith(CucumberWithSerenity.class)
@CucumberOptions(
        features = "src/test/resources/features/cases/open_cases.feature",
        glue = "com.sara.automation.stepdefinitions",
        tags = "@runner",
        snippets = CucumberOptions.SnippetType.UNDERSCORE
)
public class CasesRunner {
    // Runner principal con tag @runner
    // Ejecutara solo escenarios marcados con @runner
    // Los CasesRunner01-50 ejecutan los 50 escenarios individuales con @batch1-@batch50
}


