package com.sara.automation.tasks.casosexpress;

import com.sara.automation.interactions.casosexpress.*;
import com.sara.automation.ui.CasoExpressPage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.thucydides.core.annotations.Step;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * TASK PRINCIPAL: Crear un Caso Express de ASISTENCIA de inicio a fin.
 *
 * ============================================================
 * PROPÓSITO:
 * Orquestar el flujo COMPLETO de creación de un caso Express:
 * desde abrir el menú hasta guardar el caso en la base de datos.
 *
 * ARQUITECTURA (flujo de Screenplay):
 *
 *   1. AbrirMenuCasoExpress
 *      └─ Abre el menú "Caso Express"
 *         CONTEXTO: Documento principal
 *
 *   2. SeleccionarFormularioAsistencia
 *      └─ Selecciona formulario ASISTENCIA y lo carga en iframe
 *         CONTEXTO: Documento principal
 *
 *   3. EntrarAlIframeFormulario (INTERACTION)
 *      └─ Cambia el contexto del driver AL IFRAME
 *         CONTEXTO: DENTRO del iframe ← CAMBIO IMPORTANTE
 *
 *   4. HabilitarFormularioCasoExpress (INTERACTION)
 *      └─ Habilita la edición del formulario (modo read-only → editable)
 *         CONTEXTO: DENTRO del iframe
 *
 *   5. DiligenciarDatos (privado en esta Task)
 *      └─ Rellena todos los campos del formulario usando:
 *         - RellenarCampoTexto (INTERACTION) para inputs/textareas
 *         - SeleccionarOpcionCombo (INTERACTION) para selects
 *         CONTEXTO: DENTRO del iframe
 *
 *   6. GuardarFormularioCasoExpress (INTERACTION)
 *      └─ Hace clic en Guardar y espera a que el guardado complete
 *      └─ AL FINAL, vuelve al documento principal (switchTo().defaultContent())
 *         CONTEXTO FINAL: Documento principal ← CAMBIO IMPORTANTE
 *
 * IMPORTANTE - MANEJO DE IFRAME:
 * ============================================================
 * El gran challenge en esta Task es que entrar al iframe significa
 * que Screenplay PIERDE CONTEXTO entre acciones.
 *
 * SOLUCIÓN IMPLEMENTADA:
 * - Cada Interaction que funciona DENTRO del iframe comienza
 *   re-confirmando que está dentro del iframe
 * - Cada Interaction que sale del iframe es la última (GuardarFormularioCasoExpress)
 * - Esto se documenta con comentarios claros
 *
 * ============================================================
 *
 * PARÁMETROS:
 * - nombreSolicitante: Nombre completo del cliente
 * - cedulaSolicitante: Número de cédula/documento
 * - email: Email de contacto
 * - telefono: Teléfono de contacto
 * - descripcion: Descripción del caso/problema
 * - departamento: Departamento (Bogotá, Medellín, etc.)
 * - municipio: Municipio (Engativá, Suba, etc.)
 * - linea: Línea de servicio (Hogar, Automóvil, etc.)
 * - servicio: Servicio específico
 * - gestor: Gestor asignado al caso
 *
 * PRECONDICIÓN:
 * - El actor ha iniciado sesión exitosamente
 * - Se encuentra en la página principal del sistema
 * - El menú "Caso Express" es visible
 *
 * POSTCONDICIÓN:
 * - El caso está creado y guardado en la base de datos
 * - El driver está en el documento principal (fuera del iframe)
 * - El ID del caso ha sido generado por el sistema
 *
 * EJEMPLO DE USO DESDE UN STEP DEFINITION:
 * ============================================================
 * @When("crear un nuevo caso express de asistencia")
 * public void crearCasoExpress() {
 *     actor.attemptsTo(
 *         CrearCasoExpressAsistencia.con(
 *             "Juan García López",           // nombreSolicitante
 *             "1234567890",                  // cedulaSolicitante
 *             "juan.garcia@example.com",     // email
 *             "3012345678",                  // telefono
 *             "Se daño el aire acondicionado",  // descripcion
 *             "Bogotá",                      // departamento
 *             "Engativá",                    // municipio
 *             "Hogar",                       // linea
 *             "Servicio Técnico",            // servicio
 *             "Juan Pérez"                   // gestor
 *         )
 *     );
 * }
 *
 * EJEMPLO DE USO CON DATOS ALEATORIOS:
 * ============================================================
 * @When("crear un nuevo caso express con datos aleatorios")
 * public void crearCasoExpressAleatorio() {
 *     actor.attemptsTo(CrearCasoExpressAsistencia.conDatosAleatorios());
 * }
 */
public class CrearCasoExpressAsistencia implements Task {

    private final String nombreSolicitante;
    private final String cedulaSolicitante;
    private final String email;
    private final String telefono;
    private final String descripcion;
    private final String departamento;
    private final String municipio;
    private final String linea;
    private final String servicio;
    private final String gestor;

    /**
     * Constructor privado. Usar factory methods con() o conDatosAleatorios()
     */
    private CrearCasoExpressAsistencia(
            String nombreSolicitante, String cedulaSolicitante, String email, String telefono,
            String descripcion, String departamento, String municipio, String linea,
            String servicio, String gestor) {
        this.nombreSolicitante = nombreSolicitante;
        this.cedulaSolicitante = cedulaSolicitante;
        this.email = email;
        this.telefono = telefono;
        this.descripcion = descripcion;
        this.departamento = departamento;
        this.municipio = municipio;
        this.linea = linea;
        this.servicio = servicio;
        this.gestor = gestor;
    }

    /**
     * Factory method con datos específicos.
     */
    public static Performable con(
            String nombreSolicitante, String cedulaSolicitante, String email, String telefono,
            String descripcion, String departamento, String municipio, String linea,
            String servicio, String gestor) {
        return instrumented(CrearCasoExpressAsistencia.class,
                nombreSolicitante, cedulaSolicitante, email, telefono,
                descripcion, departamento, municipio, linea, servicio, gestor);
    }

    /**
     * Factory method con datos aleatorios.
     */
    public static Performable conDatosAleatorios() {
        return instrumented(CrearCasoExpressAsistencia.class,
                "Cliente Aleatorio", "1234567890", "cliente@test.com",
                "3012345678", "Descripción de caso", "Bogotá", "Engativá",
                "Hogar", "Servicio Técnico", "Gestor Asignado");
    }

    @Override
    @Step("Crear Caso Express de ASISTENCIA: {nombreSolicitante}")
    public <T extends Actor> void performAs(T actor) {
        System.out.println("\n");
        System.out.println("═══════════════════════════════════════════════════════════════════════════════");
        System.out.println("  INICIANDO CREACIÓN DE CASO EXPRESS - ASISTENCIA");
        System.out.println("═══════════════════════════════════════════════════════════════════════════════\n");

        // ============================================================
        // SECCIÓN 1: OPERACIONES EN DOCUMENTO PRINCIPAL
        // (antes de entrar al iframe)
        // ============================================================
        System.out.println("[SECCIÓN 1] Abriendo menú y seleccionando formulario (DOCUMENTO PRINCIPAL)\n");

        // 1.1) Abrir el menú "Caso Express"
        actor.attemptsTo(AbrirMenuCasoExpress.now());

        // 1.2) Seleccionar el formulario ASISTENCIA
        actor.attemptsTo(SeleccionarFormularioAsistencia.now());

        // ============================================================
        // SECCIÓN 2: OPERACIONES DENTRO DEL IFRAME
        // (ahora estamos dentro del iframe)
        // ============================================================
        System.out.println("[SECCIÓN 2] Entrando al iframe y habilitando formulario (DENTRO DEL IFRAME)\n");

        // 2.1) Entrar al iframe
        actor.attemptsTo(EntrarAlIframeFormulario.now());

        // 2.2) Habilitar el formulario (pasar de read-only a editable)
        actor.attemptsTo(HabilitarFormularioCasoExpress.now());

        // 2.3) Diligenciar todos los campos del formulario
        System.out.println("[SECCIÓN 3] Diligenciando todos los campos (DENTRO DEL IFRAME)\n");
        diligenciarDatos(actor);

        // ============================================================
        // SECCIÓN 3: GUARDAR Y VOLVER A DOCUMENTO PRINCIPAL
        // ============================================================
        System.out.println("[SECCIÓN 4] Guardando el caso (DENTRO DEL IFRAME)\n");
        actor.attemptsTo(GuardarFormularioCasoExpress.now());

        System.out.println("═══════════════════════════════════════════════════════════════════════════════");
        System.out.println("  ✓ CASO CREADO Y GUARDADO EXITOSAMENTE");
        System.out.println("═══════════════════════════════════════════════════════════════════════════════\n");
    }

    /**
     * Diligencia todos los campos del formulario.
     * Esta sección SOLO se ejecuta DENTRO del iframe.
     */
    private <T extends Actor> void diligenciarDatos(T actor) {
        System.out.println("[DiligenciarDatos] Rellenando campos básicos...");

        // Campos de texto
        actor.attemptsTo(RellenarCampoTexto.con(CasoExpressPage.CAMPO_NOMBRE, nombreSolicitante));
        actor.attemptsTo(RellenarCampoTexto.con(CasoExpressPage.CAMPO_CEDULA, cedulaSolicitante));
        actor.attemptsTo(RellenarCampoTexto.con(CasoExpressPage.CAMPO_EMAIL, email));
        actor.attemptsTo(RellenarCampoTexto.con(CasoExpressPage.CAMPO_TELEFONO, telefono));
        actor.attemptsTo(RellenarCampoTexto.con(CasoExpressPage.CAMPO_DESCRIPCION, descripcion));

        System.out.println("[DiligenciarDatos] Rellenando combos/selects...");

        // Combos
        actor.attemptsTo(SeleccionarOpcionCombo.en(CasoExpressPage.COMBO_DEPARTAMENTO, departamento));
        actor.attemptsTo(SeleccionarOpcionCombo.en(CasoExpressPage.COMBO_MUNICIPIO, municipio));
        actor.attemptsTo(SeleccionarOpcionCombo.en(CasoExpressPage.COMBO_LINEA, linea));
        actor.attemptsTo(SeleccionarOpcionCombo.en(CasoExpressPage.COMBO_SERVICIO, servicio));
        actor.attemptsTo(SeleccionarOpcionCombo.en(CasoExpressPage.COMBO_GESTOR, gestor));

        System.out.println("[DiligenciarDatos] ✓ Todos los campos rellenados\n");
    }

}
