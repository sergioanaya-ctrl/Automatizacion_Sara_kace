package com.sara.automation.stepdefinitions;

import com.sara.automation.tasks.ClickCasoExpress;
import com.sara.automation.tasks.GoToAgentPage;
import com.sara.automation.tasks.LoginWithCredentials;
import com.sara.automation.tasks.OpenCasesPage;
import com.sara.automation.utils.CredentialsReader;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.Before;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import net.serenitybdd.screenplay.actors.OnStage;
import net.serenitybdd.screenplay.actors.OnlineCast;
import net.thucydides.core.annotations.Managed;
import org.assertj.core.api.Assertions;
import org.openqa.selenium.WebDriver;

import java.util.List;
import java.util.Map;

public class CasesStepDefinitions {

    @Managed(driver = "chrome")
    WebDriver browser;

    private Actor actor;

    @Before
    public void prepararEscenario() {
        OnStage.setTheStage(new OnlineCast());
        actor = OnStage.theActorCalled("Sara");
    }

    @Given("el actor tiene un navegador disponible")
    public void elActorTieneUnNavegadorDisponible() {
        actor.can(BrowseTheWeb.with(browser));
    }

    @When("abre la pagina de casos")
    public void abreLaPaginaDeCasos() {
        actor.attemptsTo(OpenCasesPage.now());
    }

    @When("realiza login con credenciales")
    public void realizaLoginConCredenciales() {
        String user = CredentialsReader.getUsuario();
        String pass = CredentialsReader.getContrasena();
        actor.attemptsTo(LoginWithCredentials.with(user, pass));
    }

    @When("navega a agent")
    public void navegaAAgent() {
        actor.attemptsTo(GoToAgentPage.now());
    }

    @Then("deberia estar en la ruta cases")
    public void deberiaEstarEnLaRutaCases() {
        String currentUrl = BrowseTheWeb.as(actor).getDriver().getCurrentUrl();
        Assertions.assertThat(currentUrl).contains("konecta");
    }

    @Then("deberia ver la ruta agent")
    public void deberiaVerLaRutaAgent() {
        String currentUrl = BrowseTheWeb.as(actor).getDriver().getCurrentUrl();
        boolean isAgent = currentUrl.contains("/agent");
        boolean isSSO = currentUrl.contains("id.konecta.cloud") || currentUrl.contains("konecta-cloud");
        Assertions.assertThat(isAgent || isSSO).isTrue();
    }

    @When("diligencia caso express con datos aleatorios")
    public void diligenciaCasoExpressConDatosAleatorios() {
        actor.attemptsTo(ClickCasoExpress.now());
    }

    @When("completa listas manuales desde feature")
    public void completaListasManualesDesdeFeature(DataTable dataTable) {
        List<Map<String, String>> rows = dataTable.asMaps(String.class, String.class);
        Map<String, String> row = rows.get(0);

        actor.attemptsTo(ClickCasoExpress.withManualLists(
                required(row, "departamento_solicita"),
                required(row, "municipio_solicita"),
                row.getOrDefault("servicios_especiales", ""),
                required(row, "gestor_coordinacion"),
                required(row, "linea"),
                required(row, "servicio")
        ));
    }

    @When("diligencia caso express completo desde feature")
    public void diligenciaCasoExpressCompletoDesdeFeature(DataTable dataTable) {
        completaListasManualesDesdeFeature(dataTable);
    }

    private String required(Map<String, String> row, String key) {
        String value = row.get(key);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Falta valor requerido en feature para: " + key);
        }
        return value.trim();
    }
}
