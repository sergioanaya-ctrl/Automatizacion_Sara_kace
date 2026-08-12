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
import java.util.List;
import java.util.Random;

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Edita una tarea de monitoreo existente: abre el formulario de edición,
 * cambia su estado (Cerrada, Cancelada, etc.) y guarda.
 *
 * Flujo:
 *   1. Abre pestaña "Tareas de monitoreo"
 *   2. Localiza la primera tarea en la tabla
 *   3. Clic en botón "Editar" (icono lápiz)
 *   4. Se abre modal de edición
 *   5. Cambia estado en dropdown "Estado siguiente"
 *   6. Guarda
 *
 * Selectores centralizados en: TareasDeMonitoreoPage
 */
public class EditarTareaDeMonitoreo implements Task {

    private final String nuevoEstado;

    public EditarTareaDeMonitoreo(String nuevoEstado) {
        this.nuevoEstado = nuevoEstado;
    }

    public static Performable aEstado(String nuevoEstado) {
        return instrumented(EditarTareaDeMonitoreo.class, nuevoEstado);
    }

    @Override
    @Step("Editar primera tarea de monitoreo a estado '{nuevoEstado}'")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));

        System.out.println("\n  [EditarTareaDeMonitoreo] ==================== EDITAR TAREA ====================");

        // 1. Entrar al iframe
        entrarAlIframe(driver, wait);

        // 2. Abrir pestaña "Tareas de monitoreo"
        ResilientFormActions.clickConReintentoStaleSafe(driver, TareasDeMonitoreoPage.TAB_TAREAS, TareasDeMonitoreoPage.TAB_TAREAS, 20, 3);
        System.out.println("  [EditarTareaDeMonitoreo] ✓ Pestaña 'Tareas de monitoreo' abierta");
        sleep(1000);

        // 3. Esperar tabla visible
        wait.until(d -> {
            List<WebElement> tbody = d.findElements(TareasDeMonitoreoPage.TABLA_TAREAS);
            return !tbody.isEmpty() && tbody.get(0).isDisplayed();
        });
        System.out.println("  [EditarTareaDeMonitoreo] ✓ Tabla visible");

        // 4. Validar que hay al menos 1 tarea
        List<WebElement> filas = driver.findElements(TareasDeMonitoreoPage.FILAS_TABLA);
        if (filas.isEmpty()) {
            throw new AssertionError("No hay tareas de monitoreo para editar.");
        }

        // 5. Clic en botón "Editar" de la primera tarea
        ResilientFormActions.clickConReintentoStaleSafe(driver, TareasDeMonitoreoPage.BTN_EDITAR_PRIMERA, TareasDeMonitoreoPage.BTN_EDITAR_PRIMERA_FALLBACK, 20, 3);
        System.out.println("  [EditarTareaDeMonitoreo] ✓ Clic en botón 'Editar' de primera tarea");
        sleep(1500);

        // 6. Esperar modal de edición
        wait.until(d -> !d.findElements(TareasDeMonitoreoPage.MODAL_EDICION).isEmpty());
        System.out.println("  [EditarTareaDeMonitoreo] ✓ Modal de edición abierto");
        sleep(1000);

        // 6.5 Crear fila en editGrid (opcional, con datos aleatorios)
        crearFilaEditGridAleatorio(driver, wait);
        sleep(1000);

        // 7. Cambiar estado en dropdown (subcase-state-select es un <select> nativo)
        try {
            WebElement selectElement = wait.until(ExpectedConditions.presenceOfElementLocated(TareasDeMonitoreoPage.DROPDOWN_ESTADO));
            org.openqa.selenium.support.ui.Select select = new org.openqa.selenium.support.ui.Select(selectElement);
            select.selectByVisibleText(nuevoEstado);
            System.out.println("  [EditarTareaDeMonitoreo] ✓ Estado cambiado a: " + nuevoEstado);
        } catch (Exception e) {
            throw new RuntimeException("No se pudo cambiar el estado a: " + nuevoEstado, e);
        }

        // 8. Guardar el modal por teclado: Tab, Tab, Enter desde el campo Descripción hasta el
        // botón Guardar. Sin fallback de clic ni reintentos.
        intentarGuardarModalConTeclado(driver);
        System.out.println("  [EditarTareaDeMonitoreo] Enviado Tab, Tab, Enter para guardar el modal");

        // 9. Tras el Enter el modal solo se CIERRA (no hay recarga de página todavía);
        // esperar un momento a que termine de cerrarse antes de ir al Guardar general.
        sleep(2000);
        driver.switchTo().defaultContent();

        // 10. Clic en el "Guardar" general.
        actor.attemptsTo(ClickGuardarEnIframe.clickGuardarEnIframe());
        System.out.println("  [EditarTareaDeMonitoreo] ✓ Clic en 'Guardar' general realizado");

        // 11. ESPERA CRÍTICA: el guardado general dispara un reload de la página. Si el siguiente
        // paso (cambiar de estado) se ejecuta mientras esa recarga sigue en curso, compiten por el
        // mismo botón y el clic de estado se pierde ("Timeout al cambiar estado").
        System.out.println("  [EditarTareaDeMonitoreo] Esperando a que la página se recargue completamente tras el guardado general...");
        sleep(15000);
        System.out.println("  [EditarTareaDeMonitoreo] Página recargada, lista para el siguiente paso");

        System.out.println("  [EditarTareaDeMonitoreo] ==================== ✓ FIN ====================\n");
    }

    /**
     * Enfoca el campo "Descripción" (foco NATIVO, para que los eventos de teclado sean
     * "trusted") y envía Tab, Tab, Enter para llegar al botón "Guardar" del modal por
     * navegación de teclado, evitando depender de localizar ese botón por selector.
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
            System.out.println("  [EditarTareaDeMonitoreo] Enviado Tab, Tab, Enter desde el campo 'Descripción'");
            return esperarCierreModal(driver, Duration.ofSeconds(8));
        } catch (Exception e) {
            System.out.println("  [EditarTareaDeMonitoreo] ⚠ Error enviando Tab/Enter: " + e.getMessage());
            return false;
        }
    }

    /**
     * Espera activamente a que el modal de edición desaparezca del DOM/visibilidad,
     * en vez de un sleep fijo, para no disparar el guardado general antes de tiempo.
     */
    private boolean esperarCierreModal(WebDriver driver, Duration timeout) {
        try {
            new WebDriverWait(driver, timeout).until(
                    ExpectedConditions.invisibilityOfElementLocated(TareasDeMonitoreoPage.MODAL_EDICION));
            return true;
        } catch (Exception e) {
            System.out.println("  [EditarTareaDeMonitoreo] ⚠ Timeout esperando cierre del modal: " + e.getMessage());
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

    private static final String[][] DROPDOWNS_EDITGRID = {
            {"#custom-select-ehshd4", "Monitoreo con"},
            {"#custom-select-ecxhl4l", "Momento del servicio"},
            {"#custom-select-esi7kdj", "Respuesta a monitoreo"},
            {"#custom-select-esfdm2m", "Se generó queja"}
    };

    private void crearFilaEditGridAleatorio(WebDriver driver, WebDriverWait wait) {
        System.out.println("  [EditarTareaDeMonitoreo] ---- INICIO editGrid: crear fila ----");

        int intentos = 0;
        boolean guardadoSinErrores = false;

        while (intentos < 2 && !guardadoSinErrores) {
            intentos++;
            System.out.println("  [EditarTareaDeMonitoreo] editGrid intento " + intentos + "/2");

            try {
                if (intentos == 1) {
                    cerrarDropdownsAbiertos(driver);
                    System.out.println("  [EditarTareaDeMonitoreo] Buscando botón 'Crear' del editGrid...");
                    WebElement btnCrearFila = wait.until(ExpectedConditions.elementToBeClickable(
                            TareasDeMonitoreoPage.BTN_CREAR_FILA_EDITGRID));
                    System.out.println("  [EditarTareaDeMonitoreo] ✓ Botón 'Crear' encontrado, clic...");
                    btnCrearFila.click();
                    sleep(1500);
                    boolean dialogAbierto = !driver.findElements(TareasDeMonitoreoPage.DIALOG_CONTENIDO).isEmpty();
                    System.out.println("  [EditarTareaDeMonitoreo] ¿Dialog de fila abierto? " + dialogAbierto);
                }

                for (String[] dd : DROPDOWNS_EDITGRID) {
                    seleccionarOpcionCustomDropdown(driver, wait, dd[0], dd[1]);
                    sleep(400);
                }

                System.out.println("  [EditarTareaDeMonitoreo] --- Verificación de dropdowns tras selección ---");
                for (String[] dd : DROPDOWNS_EDITGRID) {
                    String textoActual = leerTextoControl(driver, dd[0]);
                    System.out.println("  [EditarTareaDeMonitoreo]   " + dd[1] + " => \"" + textoActual + "\"");
                }

                // Llenar observaciones con texto simple
                List<WebElement> textareas = driver.findElements(By.cssSelector(".formio-dialog-content textarea"));
                System.out.println("  [EditarTareaDeMonitoreo] Textareas encontradas en dialog: " + textareas.size());
                if (textareas.size() >= 2) {
                    textareas.get(0).sendKeys("Observación del asesor - editada automáticamente");
                    textareas.get(1).sendKeys("Observación del proveedor - editada automáticamente");
                    System.out.println("  [EditarTareaDeMonitoreo] ✓ Observaciones llenadas");
                } else {
                    System.out.println("  [EditarTareaDeMonitoreo] ⚠ No se encontraron las 2 textareas esperadas");
                }

                sleep(500);

                // Verificar si "Se generó queja" tiene valor "SÍ", y si es así, llenar "Radicado de la queja"
                try {
                    List<WebElement> seGeneroQuejaControls = driver.findElements(
                            By.cssSelector("div.custom-dropdown-control"));
                    // Buscar el que muestre "SÍ" (generalmente el cuarto dropdown es "Se generó queja")
                    boolean quejaEnSi = false;
                    for (WebElement control : seGeneroQuejaControls) {
                        String texto = control.getText().trim().toUpperCase();
                        if (texto.equals("SÍ")) {
                            quejaEnSi = true;
                            break;
                        }
                    }

                    if (quejaEnSi) {
                        System.out.println("  [EditarTareaDeMonitoreo] ✓ 'Se generó queja' es SÍ, llenando 'Radicado de la queja'...");
                        List<WebElement> radicadoInputs = driver.findElements(
                                By.xpath("//input[contains(@name, 'radicado_de_la_queja')]"));
                        if (!radicadoInputs.isEmpty()) {
                            String radicado = "QUEJA-" + System.currentTimeMillis();
                            radicadoInputs.get(0).clear();
                            radicadoInputs.get(0).sendKeys(radicado);
                            System.out.println("  [EditarTareaDeMonitoreo] ✓ Radicado llenado: " + radicado);
                        }
                    }
                } catch (Exception e) {
                    System.out.println("  [EditarTareaDeMonitoreo] ⚠ Error verificando/llenando Radicado de la queja: " + e.getMessage());
                }

                sleep(500);

                System.out.println("  [EditarTareaDeMonitoreo] Buscando botón 'Guardar' del dialog...");
                WebElement btnGuardarFila = wait.until(ExpectedConditions.elementToBeClickable(
                        By.xpath("//div[contains(@class, 'formio-dialog-content')]//button[contains(text(), 'Guardar')]")));
                btnGuardarFila.click();
                System.out.println("  [EditarTareaDeMonitoreo] ✓ Clic en 'Guardar' del dialog");
                sleep(1000);

                List<WebElement> banners = driver.findElements(
                        By.xpath("//*[contains(text(), 'Por favor corrige')]"));
                if (!banners.isEmpty()) {
                    List<WebElement> erroresLi = driver.findElements(
                            By.xpath("//*[contains(text(), 'Por favor corrige')]/following::li"));
                    System.out.println("  [EditarTareaDeMonitoreo] ⚠ Banner de validación detectado tras guardar. Campos con error:");
                    for (WebElement li : erroresLi) {
                        System.out.println("  [EditarTareaDeMonitoreo]     - " + li.getText());
                    }
                    if (intentos < 2) {
                        System.out.println("  [EditarTareaDeMonitoreo] Reintentando llenar el dialog...");
                        sleep(800);
                        continue;
                    } else {
                        System.out.println("  [EditarTareaDeMonitoreo] ✗ Se agotaron los reintentos, el editGrid pudo quedar sin guardar correctamente");
                    }
                } else {
                    guardadoSinErrores = true;
                    System.out.println("  [EditarTareaDeMonitoreo] ✓ Fila en editGrid creada y guardada sin errores de validación");
                }

            } catch (Exception e) {
                System.out.println("  [EditarTareaDeMonitoreo] ⚠ Error creando fila editGrid (intento " + intentos + "): " + e.getMessage());
            }
        }

        System.out.println("  [EditarTareaDeMonitoreo] ---- FIN editGrid: crear fila (éxito=" + guardadoSinErrores + ") ----");
    }

    /**
     * Selecciona una opción VÁLIDA en un "custom-select" con buscador, reutilizando la misma
     * utilidad ya probada para Departamento/Municipio en creación de casos
     * (OneScriptDynamicElements.selectRandomOptionOfControl).
     */
    private void seleccionarOpcionCustomDropdown(WebDriver driver, WebDriverWait wait, String selectorContenedor, String etiqueta) {
        System.out.println("  [EditarTareaDeMonitoreo] >> Dropdown '" + etiqueta + "' (" + selectorContenedor + ")");
        try {
            System.out.println("  [EditarTareaDeMonitoreo]    Buscando control .custom-dropdown-control...");
            WebElement control = wait.until(ExpectedConditions.presenceOfElementLocated(
                    By.cssSelector(selectorContenedor + " .custom-dropdown-control")));
            System.out.println("  [EditarTareaDeMonitoreo]    ✓ Control encontrado, texto actual: \"" + control.getText() + "\"");

            String seleccionado = OneScriptDynamicElements.selectRandomOptionOfControl(driver, control);
            sleep(300);

            String textoFinal = leerTextoControl(driver, selectorContenedor);
            System.out.println("  [EditarTareaDeMonitoreo]    Opción elegida: \"" + seleccionado + "\" | control ahora muestra: \"" + textoFinal + "\"");
            if (textoFinal.equalsIgnoreCase("Elige una opción") || textoFinal.contains("CONTROL_NO_ENCONTRADO")) {
                System.out.println("  [EditarTareaDeMonitoreo]    ✗ ADVERTENCIA: tras el clic el control sigue mostrando \"" + textoFinal + "\" - la selección NO se aplicó");
            } else {
                System.out.println("  [EditarTareaDeMonitoreo]    ✓ " + etiqueta + " seleccionado y confirmado: \"" + textoFinal + "\"");
            }
        } catch (Exception e) {
            System.out.println("  [EditarTareaDeMonitoreo]    ✗ Error en dropdown '" + etiqueta + "': " + e.getMessage());
        }
    }

    private void cerrarDropdownsAbiertos(WebDriver driver) {
        try {
            ((JavascriptExecutor) driver).executeScript(
                    "document.body.click();"
                            + "document.querySelectorAll('ul.custom-dropdown-list').forEach(ul => ul.style.display = 'none');");
            sleep(300);
        } catch (Exception ignored) {
        }
    }

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

    private void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
