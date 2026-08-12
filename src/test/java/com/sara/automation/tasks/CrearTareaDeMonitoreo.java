package com.sara.automation.tasks;

import com.sara.automation.interactions.OneScriptDynamicElements;
import com.sara.automation.ui.TareasDeMonitoreoPage;
import com.sara.automation.utils.ResilientFormActions;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.abilities.BrowseTheWeb;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Random;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Crea una nueva tarea de monitoreo: abre el flujo de creación desde la tabla,
 * opcionalmente cambia el estado siguiente (Cancelado TM, Cerrada, etc.) y guarda.
 *
 * Flujo:
 *   1. Abre pestaña "Tareas de monitoreo"
 *   2. Clic en botón "Crear Tarea"
 *   3. Se abre modal de creación/edición
 *   4. Cambio opcional de estado siguiente
 *   5. Clic en "Guardar" del modal
 *   6. Tarea creada
 *
 * Selectores centralizados en: TareasDeMonitoreoPage
 */
public class CrearTareaDeMonitoreo implements Task {

    private final String estadoSiguiente; // null = dejar por defecto, o nombre del estado

    public CrearTareaDeMonitoreo(String estadoSiguiente) {
        this.estadoSiguiente = estadoSiguiente;
    }

    public static Performable conEstado(String estado) {
        return instrumented(CrearTareaDeMonitoreo.class, estado);
    }

    public static Performable sinCambiarEstado() {
        return instrumented(CrearTareaDeMonitoreo.class, (String) null);
    }

    @Override
    @Step("Crear tarea de monitoreo con estado '{estadoSiguiente}'")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));

        System.out.println("\n  [CrearTareaDeMonitoreo] ==================== CREAR TAREA ====================");

        // 1. Entrar al iframe
        entrarAlIframe(driver, wait);

        // 2. Abrir pestaña "Tareas de monitoreo"
        ResilientFormActions.clickConReintentoStaleSafe(driver, TareasDeMonitoreoPage.TAB_TAREAS, TareasDeMonitoreoPage.TAB_TAREAS, 20, 3);
        System.out.println("  [CrearTareaDeMonitoreo] ✓ Pestaña 'Tareas de monitoreo' abierta");
        sleep(1000);

        // 3. Esperar tabla visible
        wait.until(d -> {
            List<WebElement> tbody = d.findElements(TareasDeMonitoreoPage.TABLA_TAREAS);
            return !tbody.isEmpty() && tbody.get(0).isDisplayed();
        });
        System.out.println("  [CrearTareaDeMonitoreo] ✓ Tabla visible");

        // 4. Clic en "Crear Tarea"
        ResilientFormActions.clickConReintentoStaleSafe(driver, TareasDeMonitoreoPage.BTN_CREAR_TAREA, TareasDeMonitoreoPage.BTN_CREAR_TAREA_FALLBACK, 20, 3);
        System.out.println("  [CrearTareaDeMonitoreo] ✓ Clic en 'Crear Tarea'");
        sleep(2000); // dar tiempo a que se abra el modal

        // 5. Esperar modal de creación
        wait.until(d -> !d.findElements(TareasDeMonitoreoPage.MODAL_EDICION).isEmpty());
        System.out.println("  [CrearTareaDeMonitoreo] ✓ Modal abierto");
        sleep(1000);

        // 5.5 Seleccionar clasificación aleatoria
        seleccionarClasificacionAleatoria(driver, wait);
        sleep(800);

        // 5.6 Cambiar estado siguiente si se proporciona (DEBE ir antes de habilitar el formulario,
        // pues el modal exige elegir el estado siguiente primero).
        // subcase-state-select es un <select> nativo: usar la clase Select de Selenium.
        if (estadoSiguiente != null && !estadoSiguiente.isEmpty()) {
            try {
                WebElement selectElement = wait.until(ExpectedConditions.presenceOfElementLocated(TareasDeMonitoreoPage.DROPDOWN_ESTADO));
                org.openqa.selenium.support.ui.Select select = new org.openqa.selenium.support.ui.Select(selectElement);
                select.selectByVisibleText(estadoSiguiente);
                System.out.println("  [CrearTareaDeMonitoreo] ✓ Estado cambiado a: " + estadoSiguiente);
                sleep(800);
            } catch (Exception e) {
                System.out.println("  [CrearTareaDeMonitoreo] ⚠ No se pudo cambiar estado a: " + estadoSiguiente + " - " + e.getMessage());
            }
        }

        // 5.7 Habilitar formulario de tarea
        habilitarFormularioTarea(driver, wait);
        sleep(1000);

        // 5.8 Llenar formulario con datos aleatorios
        llenarFormularioTareaAleatorio(driver, wait);
        sleep(800);

        // 5.9 Crear fila en editGrid (opcional, con datos aleatorios)
        crearFilaEditGridAleatorio(driver, wait);
        sleep(1000);

        // 6. Llenar "Descripción" del subcaso (contenteditable, requerido) - si no se llena,
        // el modal "Crear Subcaso" no persiste nada aunque se le dé clic en Guardar.
        llenarDescripcionSubcaso(driver, wait);
        sleep(500);

        // 7. Guardar el modal "Crear Subcaso" por teclado: Tab, Tab, Enter desde el campo
        // Descripción hasta el botón Guardar. Sin fallback de clic ni reintentos: se confirmó
        // que agregar más lógica aquí (reselección, clic directo, reintentos) termina
        // interfiriendo con el flujo posterior de cambio de estados.
        intentarGuardarModalConTeclado(driver);
        System.out.println("  [CrearTareaDeMonitoreo] Enviado Tab, Tab, Enter para guardar el modal");

        // 8. Tras el Enter el modal solo se CIERRA (no hay recarga de página todavía);
        // esperar un momento a que termine de cerrarse antes de ir al Guardar general.
        sleep(2000);
        driver.switchTo().defaultContent();

        // 9. Clic en el "Guardar" general (el mismo botón flotante que usan los demás submódulos).
        actor.attemptsTo(ClickGuardarEnIframe.clickGuardarEnIframe());
        System.out.println("  [CrearTareaDeMonitoreo] ✓ Clic en 'Guardar' general realizado");

        // 10. ESPERA CRÍTICA: el guardado general dispara un reload de la página (toast "Guardado
        // exitoso" + recarga del panel de Estados). Si el siguiente paso (cambiar de estado) se
        // ejecuta mientras esa recarga sigue en curso, ambos compiten por el mismo botón y el
        // clic de estado se pierde ("Timeout al cambiar estado"). Se espera a que la página
        // termine de asentarse ANTES de devolver el control al siguiente step, igual que hace
        // DiligenciarProveedorGestion tras su propio guardado general.
        System.out.println("  [CrearTareaDeMonitoreo] Esperando a que la página se recargue completamente tras el guardado general...");
        sleep(15000);
        System.out.println("  [CrearTareaDeMonitoreo] Página recargada, lista para el siguiente paso");

        System.out.println("  [CrearTareaDeMonitoreo] ==================== ✓ FIN ====================\n");
    }

    /**
     * Llena el campo "Descripción" (contenteditable, requerido) del modal "Crear Subcaso".
     * No es un <input>/<textarea> normal: es un div[contenteditable="true"], por lo que se
     * escribe con JS (textContent + evento 'input') en vez de sendKeys.
     */
    private void llenarDescripcionSubcaso(WebDriver driver, WebDriverWait wait) {
        System.out.println("  [CrearTareaDeMonitoreo] Buscando campo 'Descripción' del subcaso (contenteditable)...");
        try {
            WebElement descripcion = wait.until(ExpectedConditions.presenceOfElementLocated(
                    By.cssSelector("div[contenteditable='true'][data-placeholder]")));
            String texto = "Tarea de monitoreo generada automáticamente - " + System.currentTimeMillis();
            ((JavascriptExecutor) driver).executeScript(
                    "arguments[0].focus();"
                            + "arguments[0].textContent = arguments[1];"
                            + "arguments[0].dispatchEvent(new Event('input', {bubbles:true}));"
                            + "arguments[0].dispatchEvent(new Event('blur', {bubbles:true}));",
                    descripcion, texto);
            System.out.println("  [CrearTareaDeMonitoreo] ✓ Descripción del subcaso llenada: \"" + texto + "\"");
        } catch (Exception e) {
            System.out.println("  [CrearTareaDeMonitoreo] ⚠ No se pudo llenar la descripción del subcaso: " + e.getMessage());
        }
    }

    /**
     * Enfoca el campo "Descripción" (foco NATIVO, no vía JS, para que los eventos de teclado
     * sean "trusted") y envía Tab, Tab, Enter para llegar al botón "Guardar" del modal por
     * navegación de teclado y activarlo con Enter, evitando depender de localizar ese botón
     * por selector (que ha demostrado ser frágil ante modales/ids duplicados en el DOM).
     * Devuelve true si el modal confirmó su cierre tras el envío de teclas.
     */
    private boolean intentarGuardarModalConTeclado(WebDriver driver) {
        try {
            WebElement descripcion = driver.findElement(By.cssSelector("div[contenteditable='true'][data-placeholder]"));
            descripcion.click();
            new org.openqa.selenium.interactions.Actions(driver)
                    .sendKeys(org.openqa.selenium.Keys.TAB)
                    .sendKeys(org.openqa.selenium.Keys.TAB)
                    .sendKeys(org.openqa.selenium.Keys.ENTER)
                    .perform();
            System.out.println("  [CrearTareaDeMonitoreo] Enviado Tab, Tab, Enter desde el campo 'Descripción'");
            return esperarCierreModal(driver, Duration.ofSeconds(8));
        } catch (Exception e) {
            System.out.println("  [CrearTareaDeMonitoreo] ⚠ Error enviando Tab/Enter: " + e.getMessage());
            return false;
        }
    }

    /**
     * Espera activamente a que el modal "Crear Subcaso" desaparezca del DOM/visibilidad,
     * en vez de un sleep fijo, para no disparar el guardado general antes de tiempo.
     */
    private boolean esperarCierreModal(WebDriver driver, Duration timeout) {
        try {
            new WebDriverWait(driver, timeout).until(
                    ExpectedConditions.invisibilityOfElementLocated(TareasDeMonitoreoPage.MODAL_EDICION));
            return true;
        } catch (Exception e) {
            System.out.println("  [CrearTareaDeMonitoreo] ⚠ Timeout esperando cierre del modal: " + e.getMessage());
            return false;
        }
    }

    private void entrarAlIframe(WebDriver driver, WebDriverWait wait) {
        boolean encontrado = wait.until(d -> {
            d.switchTo().defaultContent();
            if (!d.findElements(TareasDeMonitoreoPage.TAB_TAREAS).isEmpty()) {
                return true;
            }
            for (WebElement frame : d.findElements(By.id("form_onescript_iframe"))) {
                try {
                    d.switchTo().frame(frame);
                    if (!d.findElements(TareasDeMonitoreoPage.TAB_TAREAS).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
                d.switchTo().defaultContent();
            }
            return false;
        });
        if (!encontrado) {
            throw new AssertionError("No se encontró la pestaña 'Tareas de monitoreo'.");
        }
    }

    /**
     * @return el "value" de la opción de clasificación seleccionada, o null si no se pudo seleccionar.
     */
    private String seleccionarClasificacionAleatoria(WebDriver driver, WebDriverWait wait) {
        try {
            // subcase-classification-select es un <select> nativo: usar la clase Select de Selenium,
            // NO simular clics manuales (click en el select + click en <option> es inestable en Chrome).
            WebElement selectElement = wait.until(ExpectedConditions.presenceOfElementLocated(
                    TareasDeMonitoreoPage.DROPDOWN_CLASIFICACION));
            org.openqa.selenium.support.ui.Select select = new org.openqa.selenium.support.ui.Select(selectElement);

            List<WebElement> opciones = select.getOptions();
            // Excluir la opción vacía ("-- Seleccione una clasificación --", value="")
            List<WebElement> opcionesValidas = opciones.stream()
                    .filter(o -> !o.getAttribute("value").isEmpty())
                    .collect(java.util.stream.Collectors.toList());

            if (opcionesValidas.isEmpty()) {
                System.out.println("  [CrearTareaDeMonitoreo] ⚠ No hay opciones de clasificación disponibles");
                return null;
            }

            Random random = new Random();
            WebElement opcionAleatoria = opcionesValidas.get(random.nextInt(opcionesValidas.size()));
            String clasificacion = opcionAleatoria.getText();
            String valor = opcionAleatoria.getAttribute("value");

            select.selectByValue(valor);
            sleep(800);

            System.out.println("  [CrearTareaDeMonitoreo] ✓ Clasificación seleccionada: " + clasificacion);
            return valor;
        } catch (Exception e) {
            System.out.println("  [CrearTareaDeMonitoreo] ⚠ Error seleccionando clasificación aleatoria: " + e.getMessage());
            return null;
        }
    }

    private void habilitarFormularioTarea(WebDriver driver, WebDriverWait wait) {
        // PASO 1: expandir el panel colapsable "Habilitar formulario de la tarea de monitoreo"
        // (es solo una extensión/acordeón, NO habilita nada por sí sola).
        try {
            WebElement panelHeader = wait.until(ExpectedConditions.elementToBeClickable(
                    TareasDeMonitoreoPage.PANEL_HEADER_HABILITAR));
            panelHeader.click();
            System.out.println("  [CrearTareaDeMonitoreo] ✓ Panel 'Habilitar formulario de la tarea de monitoreo' expandido");
            sleep(600);
        } catch (Exception e) {
            System.out.println("  [CrearTareaDeMonitoreo] ⚠ No se pudo expandir el panel (puede que ya esté expandido): " + e.getMessage());
        }

        // PASO 2: clic en el botón "Habilitar Formulario" que SÍ habilita los campos del formulario.
        try {
            WebElement btn = wait.until(ExpectedConditions.elementToBeClickable(
                    TareasDeMonitoreoPage.BTN_HABILITAR_FORMULARIO));
            btn.click();
            System.out.println("  [CrearTareaDeMonitoreo] ✓ Formulario de tarea habilitado");
        } catch (Exception e) {
            System.out.println("  [CrearTareaDeMonitoreo] ⚠ Botón principal falló (" + e.getMessage() + "), probando fallback...");
            try {
                WebElement btnFallback = wait.until(ExpectedConditions.elementToBeClickable(
                        TareasDeMonitoreoPage.BTN_HABILITAR_FORMULARIO_FALLBACK));
                btnFallback.click();
                System.out.println("  [CrearTareaDeMonitoreo] ✓ Formulario de tarea habilitado (fallback)");
            } catch (Exception e2) {
                System.out.println("  [CrearTareaDeMonitoreo] ⚠ No se pudo habilitar formulario: " + e2.getMessage());
            }
        }
    }

    private void llenarFormularioTareaAleatorio(WebDriver driver, WebDriverWait wait) {
        System.out.println("  [CrearTareaDeMonitoreo] ---- Llenando formulario de tarea habilitado ----");
        try {
            // Nombre tipo de tarea (custom dropdown con buscador aleatorio)
            seleccionarOpcionCustomDropdown(driver, wait, "#custom-select-e2cy7mj", "Nombre tipo de tarea");

            sleep(500);

            // Description nombre de tarea: campo de texto con valor por defecto "tarea de monitoreo - ",
            // se completa con texto adicional (no está deshabilitado en el formulario habilitado).
            System.out.println("  [CrearTareaDeMonitoreo] Buscando campo 'Description nombre de tarea'...");
            try {
                List<WebElement> descripcionInputs = driver.findElements(TareasDeMonitoreoPage.INPUT_DESCRIPCION_TAREA);
                if (!descripcionInputs.isEmpty()) {
                    WebElement descripcionInput = descripcionInputs.get(0);
                    String valorActual = descripcionInput.getAttribute("value");
                    System.out.println("  [CrearTareaDeMonitoreo] ✓ Campo encontrado (displayed=" + descripcionInput.isDisplayed()
                            + ", enabled=" + descripcionInput.isEnabled() + "), valor actual: \"" + valorActual + "\"");
                    if (descripcionInput.isEnabled()) {
                        descripcionInput.sendKeys("automatizada " + System.currentTimeMillis());
                        System.out.println("  [CrearTareaDeMonitoreo] ✓ Descripción de tarea completada");
                    } else {
                        System.out.println("  [CrearTareaDeMonitoreo] ⚠ Campo deshabilitado, se deja el valor por defecto");
                    }
                } else {
                    System.out.println("  [CrearTareaDeMonitoreo] ⚠ No se encontró el campo 'Description nombre de tarea'");
                }
            } catch (Exception e) {
                System.out.println("  [CrearTareaDeMonitoreo] ⚠ Error llenando descripción de tarea: " + e.getMessage());
            }

            // Fecha vencimiento (fecha futura aleatoria: 1-7 días).
            // El input visible está controlado por flatpickr y normalmente no acepta sendKeys
            // directo (queda "disabled" hasta que el propio flatpickr lo habilita); se fija el valor
            // usando la API de flatpickr sobre el input real (oculto), que dispara los eventos
            // que Form.io necesita para registrar el cambio.
            System.out.println("  [CrearTareaDeMonitoreo] Fijando fecha de vencimiento...");
            LocalDateTime fechaFutura = LocalDateTime.now().plusDays(1 + new Random().nextInt(7));
            String fechaFormato = fechaFutura.format(DateTimeFormatter.ofPattern("MM/dd/yyyy HH:mm"));
            boolean fechaFijada = fijarFechaVencimientoConFlatpickr(driver, wait, fechaFormato);
            if (fechaFijada) {
                System.out.println("  [CrearTareaDeMonitoreo] ✓ Fecha vencimiento fijada vía flatpickr: " + fechaFormato);
            } else {
                System.out.println("  [CrearTareaDeMonitoreo] ⚠ No se pudo fijar la fecha vía flatpickr, probando sendKeys directo...");
                try {
                    WebElement inputFecha = wait.until(ExpectedConditions.presenceOfElementLocated(
                            TareasDeMonitoreoPage.INPUT_FECHA_VENCIMIENTO));
                    System.out.println("  [CrearTareaDeMonitoreo]   Campo encontrado (displayed=" + inputFecha.isDisplayed()
                            + ", enabled=" + inputFecha.isEnabled() + ")");
                    inputFecha.sendKeys(fechaFormato);
                    System.out.println("  [CrearTareaDeMonitoreo] ✓ Fecha vencimiento escrita por sendKeys: " + fechaFormato);
                } catch (Exception e) {
                    System.out.println("  [CrearTareaDeMonitoreo] ✗ Fallback sendKeys también falló: " + e.getMessage());
                }
            }

        } catch (Exception e) {
            System.out.println("  [CrearTareaDeMonitoreo] ⚠ Error llenando formulario: " + e.getMessage());
        }
        System.out.println("  [CrearTareaDeMonitoreo] ---- FIN llenado de formulario de tarea ----");
    }

    /**
     * Fija la fecha de vencimiento usando la instancia flatpickr adjunta al input real
     * (id="...-fecha_hora_vencimiento", tipo hidden). flatpickr expone la instancia como
     * `elemento._flatpickr` y su `setDate(valor, triggerChange)` dispara los eventos de
     * change necesarios para que Form.io detecte el nuevo valor, evitando el problema de
     * "element not interactable" del input visible (que flatpickr mantiene no-editable).
     */
    private boolean fijarFechaVencimientoConFlatpickr(WebDriver driver, WebDriverWait wait, String fechaFormato) {
        try {
            wait.until(d -> !d.findElements(By.id("e2x0n6r-fecha_hora_vencimiento")).isEmpty());
            Object resultado = ((JavascriptExecutor) driver).executeScript(
                    "const hidden = document.getElementById('e2x0n6r-fecha_hora_vencimiento');"
                            + "if (hidden && hidden._flatpickr) {"
                            + "  hidden._flatpickr.setDate(arguments[0], true);"
                            + "  return true;"
                            + "}"
                            + "return false;",
                    fechaFormato);
            return resultado instanceof Boolean && (Boolean) resultado;
        } catch (Exception e) {
            System.out.println("  [CrearTareaDeMonitoreo] ⚠ Error fijando fecha vía flatpickr: " + e.getMessage());
            return false;
        }
    }

    private static final String[][] DROPDOWNS_EDITGRID = {
            {"#custom-select-ehshd4", "Monitoreo con"},
            {"#custom-select-ecxhl4l", "Momento del servicio"},
            {"#custom-select-esi7kdj", "Respuesta a monitoreo"}
    };

    private void crearFilaEditGridAleatorio(WebDriver driver, WebDriverWait wait) {
        System.out.println("  [CrearTareaDeMonitoreo] ---- INICIO editGrid: crear fila ----");

        int intentos = 0;
        boolean guardadoSinErrores = false;

        while (intentos < 2 && !guardadoSinErrores) {
            intentos++;
            System.out.println("  [CrearTareaDeMonitoreo] editGrid intento " + intentos + "/2");

            try {
                // Clic en "Crear" del editGrid (solo en el primer intento; en reintento el dialog ya está abierto)
                if (intentos == 1) {
                    // Cerrar cualquier dropdown que haya quedado abierto (p. ej. "Nombre tipo de tarea"),
                    // pues su lista de opciones puede tapar el botón "Crear" e interceptar el clic.
                    cerrarDropdownsAbiertos(driver);
                    System.out.println("  [CrearTareaDeMonitoreo] Buscando botón 'Crear' del editGrid...");
                    WebElement btnCrearFila = wait.until(ExpectedConditions.elementToBeClickable(
                            TareasDeMonitoreoPage.BTN_CREAR_FILA_EDITGRID));
                    System.out.println("  [CrearTareaDeMonitoreo] ✓ Botón 'Crear' encontrado, clic...");
                    btnCrearFila.click();
                    sleep(1500);
                    boolean dialogAbierto = !driver.findElements(TareasDeMonitoreoPage.DIALOG_CONTENIDO).isEmpty();
                    System.out.println("  [CrearTareaDeMonitoreo] ¿Dialog de fila abierto? " + dialogAbierto);
                }

                // Seleccionar opciones aleatorias en los primeros 3 dropdowns
                for (String[] dd : DROPDOWNS_EDITGRID) {
                    seleccionarOpcionCustomDropdown(driver, wait, dd[0], dd[1]);
                    sleep(400);
                }

                // "Se generó queja" siempre en "NO" para evitar campo obligatorio "Radicado de la queja"
                seleccionarOpcionFija(driver, wait, "#custom-select-esfdm2m", "Se generó queja", "NO");
                sleep(400);

                // Log de verificación: leer el texto actual de cada control tras la selección
                System.out.println("  [CrearTareaDeMonitoreo] --- Verificación de dropdowns tras selección ---");
                for (String[] dd : DROPDOWNS_EDITGRID) {
                    String textoActual = leerTextoControl(driver, dd[0]);
                    System.out.println("  [CrearTareaDeMonitoreo]   " + dd[1] + " => \"" + textoActual + "\"");
                }
                System.out.println("  [CrearTareaDeMonitoreo]   Se generó queja => \"" + leerTextoControl(driver, "#custom-select-esfdm2m") + "\"");

                // Llenar observaciones con texto simple
                List<WebElement> textareas = driver.findElements(By.cssSelector(".formio-dialog-content textarea"));
                System.out.println("  [CrearTareaDeMonitoreo] Textareas encontradas en dialog: " + textareas.size());
                if (textareas.size() >= 2) {
                    textareas.get(0).sendKeys("Observación del asesor - generada automáticamente");
                    textareas.get(1).sendKeys("Observación del proveedor - generada automáticamente");
                    System.out.println("  [CrearTareaDeMonitoreo] ✓ Observaciones llenadas");
                } else {
                    System.out.println("  [CrearTareaDeMonitoreo] ⚠ No se encontraron las 2 textareas esperadas");
                }

                sleep(500);

                sleep(500);

                // Guardar fila (botón dentro del dialog)
                System.out.println("  [CrearTareaDeMonitoreo] Buscando botón 'Guardar' del dialog...");
                WebElement btnGuardarFila = wait.until(ExpectedConditions.elementToBeClickable(
                        By.xpath("//div[contains(@class, 'formio-dialog-content')]//button[contains(text(), 'Guardar')]")));
                btnGuardarFila.click();
                System.out.println("  [CrearTareaDeMonitoreo] ✓ Clic en 'Guardar' del dialog");
                sleep(1000);

                // Verificar si el dialog mostró un banner de validación ("Por favor corrige...")
                List<WebElement> banners = driver.findElements(
                        By.xpath("//*[contains(text(), 'Por favor corrige')]"));
                if (!banners.isEmpty()) {
                    List<WebElement> erroresLi = driver.findElements(
                            By.xpath("//*[contains(text(), 'Por favor corrige')]/following::li"));
                    System.out.println("  [CrearTareaDeMonitoreo] ⚠ Banner de validación detectado tras guardar. Campos con error:");
                    for (WebElement li : erroresLi) {
                        System.out.println("  [CrearTareaDeMonitoreo]     - " + li.getText());
                    }
                    if (intentos < 2) {
                        System.out.println("  [CrearTareaDeMonitoreo] Reintentando llenar el dialog...");
                        sleep(800);
                        continue;
                    } else {
                        System.out.println("  [CrearTareaDeMonitoreo] ✗ Se agotaron los reintentos, el editGrid pudo quedar sin guardar correctamente");
                    }
                } else {
                    guardadoSinErrores = true;
                    System.out.println("  [CrearTareaDeMonitoreo] ✓ Fila en editGrid creada y guardada sin errores de validación");
                }

            } catch (Exception e) {
                System.out.println("  [CrearTareaDeMonitoreo] ⚠ Error creando fila editGrid (intento " + intentos + "): " + e.getMessage());
            }
        }

        System.out.println("  [CrearTareaDeMonitoreo] ---- FIN editGrid: crear fila (éxito=" + guardadoSinErrores + ") ----");
    }

    /**
     * Lee el texto actualmente mostrado en el control del custom-select (para verificar si
     * realmente quedó seleccionada una opción, en vez de asumirlo solo porque se hizo clic).
     */
    private String leerTextoControl(WebDriver driver, String selectorContenedor) {
        try {
            Object texto = ((JavascriptExecutor) driver).executeScript(
                    "const el = document.querySelector(arguments[0] + ' .custom-dropdown-control');"
                            + "return el ? el.textContent.trim() : 'CONTROL_NO_ENCONTRADO';",
                    selectorContenedor);
            return texto != null ? texto.toString() : "NULL";
        } catch (Exception e) {
            return "ERROR: " + e.getMessage();
        }
    }

    /**
     * Selecciona una opción VÁLIDA (no vacía, no "sin resultados") en un "custom-select" con buscador,
     * reutilizando la misma utilidad ya probada para Departamento/Municipio en creación de casos
     * (OneScriptDynamicElements.selectRandomOptionOfControl): abre el control con clic NATIVO (no JS,
     * porque estos componentes solo cargan opciones de forma asíncrona ante eventos "trusted"), y
     * espera activamente a que aparezca al menos una opción real antes de elegirla.
     */
    private void seleccionarOpcionCustomDropdown(WebDriver driver, WebDriverWait wait, String selectorContenedor, String etiqueta) {
        System.out.println("  [CrearTareaDeMonitoreo] >> Dropdown '" + etiqueta + "' (" + selectorContenedor + ")");
        try {
            System.out.println("  [CrearTareaDeMonitoreo]    Buscando control .custom-dropdown-control...");
            WebElement control = wait.until(ExpectedConditions.presenceOfElementLocated(
                    By.cssSelector(selectorContenedor + " .custom-dropdown-control")));
            System.out.println("  [CrearTareaDeMonitoreo]    ✓ Control encontrado, texto actual: \"" + control.getText() + "\"");

            String seleccionado = OneScriptDynamicElements.selectRandomOptionOfControl(driver, control);
            sleep(300);

            String textoFinal = leerTextoControl(driver, selectorContenedor);
            System.out.println("  [CrearTareaDeMonitoreo]    Opción elegida: \"" + seleccionado + "\" | control ahora muestra: \"" + textoFinal + "\"");
            if (textoFinal.equalsIgnoreCase("Elige una opción") || textoFinal.contains("CONTROL_NO_ENCONTRADO")) {
                System.out.println("  [CrearTareaDeMonitoreo]    ✗ ADVERTENCIA: tras el clic el control sigue mostrando \"" + textoFinal + "\" - la selección NO se aplicó");
            } else {
                System.out.println("  [CrearTareaDeMonitoreo]    ✓ " + etiqueta + " seleccionado y confirmado: \"" + textoFinal + "\"");
            }
        } catch (Exception e) {
            System.out.println("  [CrearTareaDeMonitoreo]    ✗ Error en dropdown '" + etiqueta + "': " + e.getMessage());
        }
    }

    /**
     * Cierra cualquier lista de custom-dropdown que haya quedado abierta (haciendo clic en un punto
     * neutro del body), para evitar que un <li> visible intercepte el clic sobre otro botón
     * (p. ej. "Crear" del editGrid quedaba tapado por la lista de "Nombre tipo de tarea" abierta).
     */
    private void cerrarDropdownsAbiertos(WebDriver driver) {
        try {
            ((JavascriptExecutor) driver).executeScript(
                    "document.body.click();"
                            + "document.querySelectorAll('ul.custom-dropdown-list').forEach(ul => ul.style.display = 'none');");
            sleep(300);
        } catch (Exception ignored) {
        }
    }

    /**
     * Selecciona una opción específica por texto en un custom-select con buscador.
     */
    private void seleccionarOpcionFija(WebDriver driver, WebDriverWait wait, String selectorContenedor, String etiqueta, String textoOpcion) {
        System.out.println("  [CrearTareaDeMonitoreo] >> Dropdown '" + etiqueta + "' => forzando \"" + textoOpcion + "\"");
        try {
            WebElement control = wait.until(ExpectedConditions.presenceOfElementLocated(
                    By.cssSelector(selectorContenedor + " .custom-dropdown-control")));
            control.click();
            sleep(400);
            // Buscar la opción por texto exacto en la lista desplegada
            WebElement opcion = wait.until(ExpectedConditions.elementToBeClickable(
                    By.xpath("//ul[contains(@class,'custom-dropdown-list')]//li[normalize-space(text())='" + textoOpcion + "']")));
            opcion.click();
            sleep(300);
            String textoFinal = leerTextoControl(driver, selectorContenedor);
            System.out.println("  [CrearTareaDeMonitoreo]    ✓ " + etiqueta + " fijado a \"" + textoFinal + "\"");
        } catch (Exception e) {
            System.out.println("  [CrearTareaDeMonitoreo]    ✗ Error fijando '" + etiqueta + "' a \"" + textoOpcion + "\": " + e.getMessage());
        }
    }

    private void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
