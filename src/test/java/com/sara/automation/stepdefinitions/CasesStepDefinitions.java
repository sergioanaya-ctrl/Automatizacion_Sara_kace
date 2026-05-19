package com.sara.automation.stepdefinitions;

import com.sara.automation.tasks.ClickCasoExpress;
import com.sara.automation.tasks.DiligenciarProveedorGestion;
import com.sara.automation.tasks.GoToAgentPage;
import com.sara.automation.tasks.LoginWithCognito;
import com.sara.automation.tasks.OpenCasesPage;
import com.sara.automation.tasks.TransicionarEstadosCaso;
import com.sara.automation.tasks.ValidarEstadoCaso;
import com.sara.automation.utils.CredentialsReader;
import com.sara.automation.utils.ApplicationPerformanceMonitor;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.Before;
import io.cucumber.java.After;
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
    private ApplicationPerformanceMonitor perfMonitor;

    @Before
    public void prepararEscenario() {
        OnStage.setTheStage(new OnlineCast());
        actor = OnStage.theActorCalled("Sara");
        // Inicializar monitor de performance para capturar métricas reales de la app
        perfMonitor = new ApplicationPerformanceMonitor("CasesTest_" + System.currentTimeMillis(), null);
        // Guardar el monitor en ActorMemory para que las Tasks puedan acceder a él
        actor.remember("perfMonitor", perfMonitor);
    }

    @After
    public void finalizarEscenario() {
        // Capturar Web Vitals antes de cerrar navegador
        if (perfMonitor != null && browser != null) {
            try {
                perfMonitor.setDriver(browser);
                perfMonitor.captureWebVitals("Final_Page");
                perfMonitor.generateReport();
                System.out.println(perfMonitor.getSummary());
            } catch (Exception e) {
                System.out.println("Warning: No se pudo generar reporte final - " + e.getMessage());
            }
        }
    }

    @Given("el actor tiene un navegador disponible")
    public void elActorTieneUnNavegadorDisponible() {
        actor.can(BrowseTheWeb.with(browser));
        // Asignar driver al monitor
        if (perfMonitor != null) {
            perfMonitor.setDriver(browser);
        }
    }

    @When("abre la pagina de casos")
    public void abreLaPaginaDeCasos() {
        long startTime = System.currentTimeMillis();
        actor.attemptsTo(OpenCasesPage.now());
        long duration = System.currentTimeMillis() - startTime;
        
        if (perfMonitor != null) {
            perfMonitor.captureWebVitals("OpenCasesPage");
            perfMonitor.captureNetworkTiming("OpenCasesPage");
        }
        System.out.println("[APP-PERF] OpenCasesPage completado en " + duration + "ms");
    }

    @When("realiza login con credenciales")
    public void realizaLoginConCredenciales() {
        long startTime = System.currentTimeMillis();
        String user = CredentialsReader.getUsuario();
        String pass = CredentialsReader.getContrasena();
        actor.attemptsTo(LoginWithCognito.with(user, pass));
        long duration = System.currentTimeMillis() - startTime;
        
        if (perfMonitor != null) {
            perfMonitor.captureAPIResponseTime("POST /login", duration);
            perfMonitor.captureNetworkTiming("LoginStep");
        }
        System.out.println("[APP-PERF] Login completado en " + duration + "ms");
    }

    @When("navega a agent")
    public void navegaAAgent() {
        long startTime = System.currentTimeMillis();
        actor.attemptsTo(GoToAgentPage.now());
        long duration = System.currentTimeMillis() - startTime;
        
        if (perfMonitor != null) {
            perfMonitor.captureNetworkTiming("GoToAgent");
        }
        System.out.println("[APP-PERF] Navigate to Agent completado en " + duration + "ms");
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
        // El StepDefinition no llena campos directamente.
        // Solo dispara la Task principal, que a su vez orquesta interacciones y navegación al iframe.
        actor.attemptsTo(ClickCasoExpress.now());
    }

    @When("completa listas manuales desde feature")
    public void completaListasManualesDesdeFeature(DataTable dataTable) {
        // La DataTable del feature alimenta la Task principal.
        // Esta Task abre el formulario, entra al iframe OneScript y delega el diligenciamiento
        // a la interacción FillCasoExpressFormInOrder.
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
        long startTime = System.currentTimeMillis();
        // Este step funciona como alias legible del feature.
        // Reutiliza el mismo flujo para no duplicar lógica de negocio en los steps.
        completaListasManualesDesdeFeature(dataTable);
        long duration = System.currentTimeMillis() - startTime;
        
        if (perfMonitor != null) {
            perfMonitor.captureNetworkTiming("DiligenciaCasoExpress");
        }
        System.out.println("[APP-PERF] Caso Express completado en " + duration + "ms");
    }

    @When("diligenciamos el proveedor")
    @When("digilenciamos el poriveedor")
    public void diligenciamosElProveedor(DataTable dataTable) {
        long startTime = System.currentTimeMillis();
        List<Map<String, String>> rows = dataTable.asMaps(String.class, String.class);
        Map<String, String> row = rows.get(0);

        String nombreProveedor = requiredAnyKey(row, "Nombre del proveedor", "nombre del proveedor", "proveedor", "Nombre");
        String servicio = requiredAnyKey(row, "Servicio", "servicio", "Respuesta", "respuesta de proveedor");

        actor.attemptsTo(DiligenciarProveedorGestion.conDatos(nombreProveedor, servicio));
        long duration = System.currentTimeMillis() - startTime;
        
        if (perfMonitor != null) {
            perfMonitor.captureFormSubmissionTime("GestionProveedor", duration);
            perfMonitor.captureNetworkTiming("GestionProveedor");
        }
        System.out.println("[APP-PERF] Gestión Proveedor completada en " + duration + "ms");
    }

    private String required(Map<String, String> row, String key) {
        String value = row.get(key);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Falta valor requerido en feature para: " + key);
        }
        return value.trim();
    }

    private String requiredAnyKey(Map<String, String> row, String... keys) {
        for (String key : keys) {
            for (Map.Entry<String, String> entry : row.entrySet()) {
                if (entry.getKey() != null && entry.getKey().trim().equalsIgnoreCase(key.trim())) {
                    String value = entry.getValue();
                    if (value != null && !value.trim().isEmpty()) {
                        return value.trim();
                    }
                }
            }
        }
        throw new IllegalArgumentException("Falta valor requerido en feature. Llaves esperadas: " + String.join(", ", keys));
    }

    @When("transicionamos los estados del caso")
    public void transicionamosLosEstadosDelCaso() {
        long startTime = System.currentTimeMillis();
        // Transiciona el caso a través de: Programado -> Aceptado y en desplazamiento -> Concluido -> Finalizado
        actor.attemptsTo(TransicionarEstadosCaso.completarSecuencia());
        long duration = System.currentTimeMillis() - startTime;
        
        if (perfMonitor != null) {
            perfMonitor.captureNetworkTiming("TransicionesEstados");
        }
        System.out.println("[APP-PERF] Transiciones de estados completadas en " + duration + "ms");
    }

    @Then("Se valida que quede en estado {string}")
    public void seValidaQueQuedeEnEstado(String estado) {
        long startTime = System.currentTimeMillis();
        // Valida que el caso haya finalizado en el estado esperado
        actor.attemptsTo(ValidarEstadoCaso.conEstado(estado));
        long duration = System.currentTimeMillis() - startTime;
        
        if (perfMonitor != null) {
            perfMonitor.captureNetworkTiming("ValidarEstado");
        }
        System.out.println("[APP-PERF] Validación de estado completada en " + duration + "ms");
    }
}
