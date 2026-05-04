package com.sara.automation.tasks;

import com.sara.automation.ui.CasoCreatePage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.actions.Click;
import net.serenitybdd.screenplay.actions.Enter;
import net.serenitybdd.screenplay.waits.WaitUntil;
import net.thucydides.core.annotations.Step;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Random;

import static net.serenitybdd.screenplay.Tasks.instrumented;
import static net.serenitybdd.screenplay.matchers.WebElementStateMatchers.isVisible;

public class ClickCasoExpress implements Task {

    private static final Random RANDOM = new Random();

    private final String departamento;
    private final String municipio;
    private final String serviciosEspeciales;
    private final String gestor;
    private final String linea;
    private final String servicio;

    public ClickCasoExpress() {
        this.departamento = null;
        this.municipio = null;
        this.serviciosEspeciales = null;
        this.gestor = null;
        this.linea = null;
        this.servicio = null;
    }

    public ClickCasoExpress(String departamento, String municipio, String serviciosEspeciales, String gestor, String linea, String servicio) {
        this.departamento = departamento;
        this.municipio = municipio;
        this.serviciosEspeciales = serviciosEspeciales;
        this.gestor = gestor;
        this.linea = linea;
        this.servicio = servicio;
    }

    public static Performable now() {
        return instrumented(ClickCasoExpress.class);
    }

    public static Performable withManualLists(String departamento, String municipio, String serviciosEspeciales, String gestor, String linea, String servicio) {
        return instrumented(ClickCasoExpress.class, departamento, municipio, serviciosEspeciales, gestor, linea, servicio);
    }

    @Override
    @Step("Abrir Caso Express, seleccionar asistencia, habilitar y diligenciar formulario")
    public <T extends Actor> void performAs(T actor) {
        entrarAlIframeSiExiste(actor);
        abrirCasoExpress(actor);
        seleccionarFormularioAsistencia(actor);
        habilitarFormulario(actor);
        diligenciarCampos(actor);

        // Si vienen valores manuales, ejecuta la selección dependiente en secuencia.
        if (departamento != null && municipio != null && serviciosEspeciales != null && gestor != null && linea != null && servicio != null) {
            actor.attemptsTo(SelectManualLists.withValues(departamento, municipio, serviciosEspeciales, gestor, linea, servicio));
        }
    }

    private <T extends Actor> void entrarAlIframeSiExiste(T actor) {
        try {
            WebDriver driver = BrowseTheWeb.as(actor).getDriver();
            driver.switchTo().defaultContent();
            actor.attemptsTo(WaitUntil.the(CasoCreatePage.Form_OneScript_Iframe, isVisible()).forNoMoreThan(8).seconds());
            WebElement iframe = CasoCreatePage.Form_OneScript_Iframe.resolveFor(actor);
            driver.switchTo().frame(iframe);
        } catch (Exception ignored) {
            // Si el formulario no está dentro de iframe en este entorno, continuar sin switch.
        }
    }

    private <T extends Actor> void abrirCasoExpress(T actor) {
        try {
            actor.attemptsTo(WaitUntil.the(CasoCreatePage.Caso_Express, isVisible()).forNoMoreThan(8).seconds());
            actor.attemptsTo(Click.on(CasoCreatePage.Caso_Express));
        } catch (Exception e) {
            try {
                actor.attemptsTo(Click.on(CasoCreatePage.Caso_Express_FALLBACK));
            } catch (Exception ex) {
                throw new RuntimeException("No se pudo abrir el menú 'Caso Express'", ex);
            }
        }
    }

    private <T extends Actor> void seleccionarFormularioAsistencia(T actor) {
        try {
            actor.attemptsTo(WaitUntil.the(CasoCreatePage.Formulario_Creacion_ASISTENCIA, isVisible()).forNoMoreThan(10).seconds());
            actor.attemptsTo(Click.on(CasoCreatePage.Formulario_Creacion_ASISTENCIA));
        } catch (Exception e) {
            throw new RuntimeException("No se pudo seleccionar 'Formulario Creación de Casos (ASISTENCIA)'", e);
        }
    }

    private <T extends Actor> void habilitarFormulario(T actor) {
        try {
            actor.attemptsTo(WaitUntil.the(CasoCreatePage.Habilitar_Formulario, isVisible()).forNoMoreThan(25).seconds());
            actor.attemptsTo(Click.on(CasoCreatePage.Habilitar_Formulario));
        } catch (Exception e) {
            try {
                actor.attemptsTo(WaitUntil.the(CasoCreatePage.Habilitar_Formulario_FALLBACK, isVisible()).forNoMoreThan(10).seconds());
                actor.attemptsTo(Click.on(CasoCreatePage.Habilitar_Formulario_FALLBACK));
            } catch (Exception ex) {
                throw new RuntimeException("No se pudo hacer click en 'Habilitar Formulario'", ex);
            }
        }
    }

    private <T extends Actor> void diligenciarCampos(T actor) {
        String numeroExpediente = generarNumeroExpediente15();
        String nombreSolicitante = "Solicitante " + randomLetras(6);
        String cedulaSolicitante = randomDigitos(10);
        String telefono1 = "3" + randomDigitos(9);
        String telefono2 = "3" + randomDigitos(9);
        String placa = randomLetras(3) + randomDigitos(3);
        String direccionServicio = "Calle " + (10 + RANDOM.nextInt(80)) + " #" + (1 + RANDOM.nextInt(99)) + "-" + (1 + RANDOM.nextInt(99));
        String detalleDireccionServicio = "Apto " + (1 + RANDOM.nextInt(50)) + ", Torre " + (char) ('A' + RANDOM.nextInt(6));
        String detalleDireccionDestino = "Referencia " + randomLetras(5) + " " + randomDigitos(3);

        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Numero_Expediente, isVisible()).forNoMoreThan(20).seconds());

        actor.attemptsTo(
                Enter.theValue(numeroExpediente).into(CasoCreatePage.Numero_Expediente),
                Enter.theValue(nombreSolicitante).into(CasoCreatePage.Nombre_Solicitante),
                Enter.theValue(cedulaSolicitante).into(CasoCreatePage.Cedula_Solicitante),
                Enter.theValue(telefono1).into(CasoCreatePage.Telefono_1),
                Enter.theValue(telefono2).into(CasoCreatePage.Telefono_2),
                Enter.theValue(placa).into(CasoCreatePage.Placa),
                Enter.theValue(direccionServicio).into(CasoCreatePage.Direccion_Servicio),
                Enter.theValue(detalleDireccionServicio).into(CasoCreatePage.Detalle_Direccion_Servicio),
                Enter.theValue(detalleDireccionDestino).into(CasoCreatePage.Detalle_Direccion_Destino),
                Enter.theValue("produccion").into(CasoCreatePage.Ubicacion_Servicio)
        );
    }

    private String generarNumeroExpediente15() {
        // 15 dígitos: yyyyMMdd + 7 aleatorios
        String fecha = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        return fecha + randomDigitos(7);
    }

    private String randomDigitos(int longitud) {
        StringBuilder sb = new StringBuilder(longitud);
        for (int i = 0; i < longitud; i++) {
            sb.append(RANDOM.nextInt(10));
        }
        return sb.toString();
    }

    private String randomLetras(int longitud) {
        StringBuilder sb = new StringBuilder(longitud);
        for (int i = 0; i < longitud; i++) {
            sb.append((char) ('A' + RANDOM.nextInt(26)));
        }
        return sb.toString();
    }
}
