package com.sara.automation.runners;

import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

/**
 * Runner para ejecutar pruebas de carga con 50 usuarios en paralelo
 * 
 * Ejecutar con:
 * .\gradlew.bat test --tests LoadTestRunner
 * 
 * Esto ejecutara 50 escenarios, cada uno con un usuario diferente (BOT01-BOT50)
 * La paralelizacion se controla en:
 * - build.gradle: maxParallelForks (cuantos navegadores simultaneos)
 * - junit-platform.properties: cucumber.execution.parallel.config.fixed.parallelism
 */
@RunWith(CucumberWithSerenity.class)
@CucumberOptions(
        features = "src/test/resources/features/cases/load_test_50_users.feature",
        glue = "com.sara.automation.stepdefinitions",
        snippets = CucumberOptions.SnippetType.UNDERSCORE,
        plugin = {
            "pretty",
            "html:target/cucumber-reports/load-test.html",
            "json:target/cucumber-reports/load-test.json"
        }
)
public class LoadTestRunner {
}
