package com.sara.automation.runners;

import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

@RunWith(CucumberWithSerenity.class)
@CucumberOptions(
        features = "src/test/resources/features/cases/open_cases.feature",
        glue = "com.sara.automation.stepdefinitions",
        tags = "@batch7",
        snippets = CucumberOptions.SnippetType.UNDERSCORE
)
public class CasesRunner04 {
    // Escenario del submódulo Renting (linea RENTING).
    // Los usuarios se asignan ALEATORIAMENTE desde UserPoolManager
    // No es necesario establecer propiedades del sistema
}
