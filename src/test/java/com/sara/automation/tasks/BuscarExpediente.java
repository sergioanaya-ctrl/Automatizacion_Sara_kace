package com.sara.automation.tasks;

import com.sara.automation.utils.ExpedienteContext;
import com.sara.automation.utils.ProveedorContext;
import com.sara.automation.utils.ProveedorPoolManager;
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

import static net.serenitybdd.screenplay.Tasks.instrumented;

/**
 * Busca el expediente previamente guardado ({@link ExpedienteContext}) y abre su edición:
 *   1. Click en "Búsqueda avanzada" (id=btn_update_and_filter, en el shell).
 *   2. Dentro del iframe del formulario formio, escribe el expediente en el campo
 *      Expediente (name=data[external_code]).
 *   3. Click en "Filtrar" (id=customSubmit).
 *   4. Cuando el expediente aparece en la tabla de resultados, click en el botón
 *      "Editar" (button.btn-primary[title='Editar']) de esa fila.
 *   5. Espera a que la página de edición cargue.
 */
public class BuscarExpediente implements Task {

    private static final By BUSQUEDA_AVANZADA = By.id("btn_update_and_filter");
    private static final By CAMPO_EXPEDIENTE = By.cssSelector("input[name='data[external_code]']");
    private static final By BTN_FILTRAR = By.id("customSubmit");

    public static Performable now() {
        return instrumented(BuscarExpediente.class);
    }

    @Override
    @Step("Buscar el expediente guardado y abrir su edición")
    public <T extends Actor> void performAs(T actor) {
        WebDriver driver = BrowseTheWeb.as(actor).getDriver();
        JavascriptExecutor js = (JavascriptExecutor) driver;
        String expediente = ExpedienteContext.getExpediente();

        ProveedorPoolManager.Proveedor prov = ProveedorContext.getOrNull();
        String provLogin = (prov != null) ? prov.getUsuario() : "(desconocido)";
        System.out.println("\n  [BuscarExpediente] ==================== BÚSQUEDA DE EXPEDIENTE '" + expediente + "' ====================");
        System.out.println("  [BuscarExpediente] Proveedor esperado en sesión: " + provLogin);
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));

        // 1. Abrir búsqueda avanzada (en el shell, fuera del iframe).
        driver.switchTo().defaultContent();
        WebElement botonBusqueda = wait.until(ExpectedConditions.elementToBeClickable(BUSQUEDA_AVANZADA));
        clickResiliente(js, botonBusqueda);
        System.out.println("  [BuscarExpediente] ✓ Click en 'Búsqueda avanzada'");

        // 2. Ubicar el iframe del formulario de filtros y entrar a él.
        entrarAlFrameDelFormulario(driver, wait);

        // 3. Escribir el expediente en el campo Expediente.
        WebElement campo = wait.until(ExpectedConditions.visibilityOfElementLocated(CAMPO_EXPEDIENTE));
        escribirEnFormio(js, campo, expediente);
        System.out.println("  [BuscarExpediente] ✓ Expediente escrito en el campo 'Expediente'");

        // 4. Click en Filtrar.
        WebElement filtrar = wait.until(ExpectedConditions.elementToBeClickable(BTN_FILTRAR));
        clickResiliente(js, filtrar);
        System.out.println("  [BuscarExpediente] ✓ Click en 'Filtrar'");

        // 5. Intentar abrir por la Búsqueda avanzada (botón 'Editar' de la fila).
        WebElement editar = buscarEditarConReintento(driver, js, expediente);
        if (editar != null) {
            clickResiliente(js, editar);
            System.out.println("  [BuscarExpediente] ✓ Click en 'Editar' (búsqueda avanzada)");
        } else {
            // FALLBACK: la búsqueda avanzada a veces devuelve "sin resultados" aunque el
            // expediente exista. Lo abrimos desde la TABLA PRINCIPAL (el caso recién creado
            // queda arriba): fila -> menú '...' -> 'Ver caso'.
            System.out.println("  [BuscarExpediente] ↪ Búsqueda avanzada sin resultado; usando fallback de la tabla principal...");
            // Cerrar la ventana de búsqueda avanzada (X): si queda abierta, tapa la tabla y el
            // fallback no puede ver/clickear la fila ni el menú 'Ver caso'.
            cerrarBusquedaAvanzada(driver, js);
            if (!verCasoDesdeTablaPrincipal(driver, js, expediente)) {
                String sinRes = mensajeSinResultados(driver);
                throw new AssertionError("No se pudo abrir el expediente '" + expediente
                        + "' ni por búsqueda avanzada ni por la tabla principal (Ver caso)."
                        + (sinRes != null ? " Tabla: SIN RESULTADOS (\"" + sinRes + "\")." : ""));
            }
        }

        // 6. Esperar a que cargue la página de edición / caso.
        driver.switchTo().defaultContent();
        esperarCargaPagina(driver);
        System.out.println("  [BuscarExpediente] ==================== ✓ EXPEDIENTE ABIERTO ====================\n");
    }

    /**
     * Entra al iframe que contiene el formulario de filtros. Intenta primero el id conocido
     * 'form_onescript_iframe'; si el campo no está ahí, recorre todos los iframes de la página
     * hasta encontrar el campo Expediente (robusto ante un id de iframe distinto en esta vista).
     */
    private void entrarAlFrameDelFormulario(WebDriver driver, WebDriverWait wait) {
        boolean encontrado = wait.until(d -> {
            d.switchTo().defaultContent();

            // Caso 0: el formulario está directamente en el documento principal.
            if (!d.findElements(CAMPO_EXPEDIENTE).isEmpty()) {
                return true;
            }

            // Caso 1: iframe conocido del proyecto.
            List<WebElement> conocido = d.findElements(By.id("form_onescript_iframe"));
            if (!conocido.isEmpty()) {
                try {
                    d.switchTo().frame(conocido.get(0));
                    if (!d.findElements(CAMPO_EXPEDIENTE).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
                d.switchTo().defaultContent();
            }

            // Caso 2: cualquier otro iframe de la página.
            List<WebElement> frames = d.findElements(By.tagName("iframe"));
            for (WebElement frame : frames) {
                try {
                    d.switchTo().defaultContent();
                    d.switchTo().frame(frame);
                    if (!d.findElements(CAMPO_EXPEDIENTE).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
            }
            d.switchTo().defaultContent();
            return false;
        });

        if (!encontrado) {
            throw new AssertionError("No se encontró el campo 'Expediente' (data[external_code]) en la página ni en sus iframes.");
        }
        System.out.println("  [BuscarExpediente] ✓ Formulario de filtros localizado");
    }

    /**
     * Busca el botón "Editar" de la fila del expediente, tolerante a carga lenta y a que los
     * resultados estén en un frame distinto. Si no aparece en la primera ventana, reintenta
     * 'Filtrar' una vez (por si el valor no se aplicó) y vuelve a esperar.
     */
    private WebElement buscarEditarConReintento(WebDriver driver, JavascriptExecutor js, String expediente) {
        WebElement btn = localizarEditarEnAlgunFrame(driver, expediente, Duration.ofSeconds(20));
        if (btn != null) {
            return btn;
        }
        String sinRes1 = mensajeSinResultados(driver);
        if (sinRes1 != null) {
            System.out.println("  [BuscarExpediente] ⚠ El filtro indica SIN RESULTADOS: \"" + sinRes1 + "\".");
        }
        System.out.println("  [BuscarExpediente] ↻ Reintentando 'Filtrar'...");
        reintentarFiltrar(driver, js, expediente);
        return localizarEditarEnAlgunFrame(driver, expediente, Duration.ofSeconds(20));
    }

    /**
     * Cierra la ventana/panel de "Búsqueda avanzada" con su botón X (svg.lucide-x). Si queda
     * abierta, tapa la tabla principal y el fallback no puede interactuar con ella.
     */
    private void cerrarBusquedaAvanzada(WebDriver driver, JavascriptExecutor js) {
        try {
            driver.switchTo().defaultContent();
            By closeBy = By.xpath(
                    "//button[.//*[local-name()='svg' and contains(@class,'lucide-x')]]");
            WebElement x = null;
            for (WebElement b : driver.findElements(closeBy)) {
                try {
                    if (b.isDisplayed() && b.isEnabled()) {
                        x = b;
                        break;
                    }
                } catch (Exception ignored) {
                }
            }
            if (x != null) {
                clickResiliente(js, x);
                System.out.println("  [BuscarExpediente] ✓ Ventana de búsqueda avanzada cerrada");
                sleep(800); // dejar que el panel se cierre y el tablero quede visible
            } else {
                System.out.println("  [BuscarExpediente] (no se halló el botón X de búsqueda avanzada; continúo)");
            }
        } catch (Exception e) {
            System.out.println("  [BuscarExpediente] ⚠ No se pudo cerrar búsqueda avanzada: " + e.getMessage());
        }
    }

    /**
     * Fallback: abre el expediente desde la TABLA PRINCIPAL de expedientes (React/radix, en el
     * documento shell, fuera del iframe de filtros). Ubica la fila cuyo texto coincide con el
     * expediente, abre el menú de acciones ('...', button[aria-haspopup='menu']) y hace clic en
     * 'Ver caso'. Devuelve true si lo logró.
     */
    private boolean verCasoDesdeTablaPrincipal(WebDriver driver, JavascriptExecutor js, String expediente) {
        // Preferir el tablero "Mis cierres de expediente en gestión" (el de conceptos): el menú '...'
        // de otros tableros (p. ej. "Reporte para los Proveedores") NO tiene 'Ver caso'.
        By filaGestion = By.xpath(
                "//div[contains(@class,'border-b')][.//span[contains(normalize-space(.),'cierres de expediente')]]"
              + "//table//tbody//tr[.//td[normalize-space(.)='" + expediente + "']]");
        By filaCualquiera = By.xpath("//table//tbody//tr[.//td[normalize-space(.)='" + expediente + "']]");
        // OJO: 'Ver detalle del caso' abre el formulario en SOLO LECTURA. El que permite
        // gestionar conceptos es 'Ver caso' (tablero "Mis cierres de expediente en gestión").
        // Match EXACTO para NO caer en 'Ver detalle del caso'.
        By verCasoBy = By.xpath("//div[@role='menuitem'][normalize-space(.)='Ver caso']");
        By refreshGestion = By.xpath(
                "//div[contains(@class,'border-b')][.//span[contains(normalize-space(.),'cierres de expediente')]]"
              + "//button[@title='Actualizar tabla']");

        By seccionGestion = By.xpath("//span[contains(normalize-space(.),'cierres de expediente')]");

        driver.switchTo().defaultContent();

        // El expediente tarda en reflejarse en el tablero (puede ser minutos). Se pulsa
        // "Actualizar" y se espera de forma creciente: 15s el primer intento y +5s cada vez.
        final int MAX_INTENTOS = 6;
        long espera = 15000;
        for (int intento = 1; intento <= MAX_INTENTOS; intento++) {
            // Llevar el tablero de gestión a la vista (sus filas pueden no renderizarse fuera del viewport).
            try {
                WebElement sec = driver.findElement(seccionGestion);
                js.executeScript("arguments[0].scrollIntoView({block:'center'});", sec);
            } catch (Exception e) {
                js.executeScript("window.scrollBy(0, 500);");
            }
            sleep(400);

            // Clic en "Actualizar tabla" para refrescar el listado.
            WebElement refresh = primerClickable(driver, refreshGestion);
            if (refresh != null) {
                clickSinScroll(js, refresh);
                System.out.println("  [BuscarExpediente] ↻ Actualizar tabla (intento " + intento + "/" + MAX_INTENTOS
                        + ", esperando " + (espera / 1000) + "s)");
            }
            sleep(espera); // espera creciente: el expediente tarda en reflejarse

            // DIAGNÓSTICO: qué expedientes lista el tablero y si el nuestro ya está.
            String enTablero = expedientesEnTableroGestion(js);
            boolean presente = enTablero != null && enTablero.contains(expediente);
            System.out.println("  [BuscarExpediente] [diag] intento " + intento + " | buscado=" + expediente
                    + (presente ? " -> PRESENTE" : " -> NO está") + " | tablero=[" + enTablero + "]");

            espera += 5000; // aumentar la espera para el siguiente intento

            if (!presente) {
                continue; // no apareció aún: volver a "Actualizar"
            }

            // Está en el tablero: abrir su menú '...' -> 'Ver caso'.
            WebElement fila = primerClickable(driver, filaGestion);
            if (fila == null) {
                fila = primerClickable(driver, filaCualquiera);
            }
            if (fila != null) {
                try {
                    WebElement acciones = fila.findElement(By.xpath(".//button[@aria-haspopup='menu']"));
                    clickResiliente(js, acciones); // abrir menú (clic nativo: radix abre confiable)
                    WebElement verCaso = new WebDriverWait(driver, Duration.ofSeconds(6))
                            .until(ExpectedConditions.presenceOfElementLocated(verCasoBy));
                    clickSinScroll(js, verCaso);   // 'Ver caso' (portal): clic JS sin scroll
                    System.out.println("  [BuscarExpediente] ✓ Abierto desde tablero de gestión ('Ver caso')");
                    return true;
                } catch (Exception e) {
                    System.out.println("  [BuscarExpediente] ⚠ Presente pero no se pudo abrir 'Ver caso': " + e.getMessage());
                    try {
                        js.executeScript("document.body.dispatchEvent(new KeyboardEvent('keydown',{key:'Escape',bubbles:true}));");
                    } catch (Exception ignored) {
                    }
                }
            }
        }
        System.out.println("  [BuscarExpediente] ⚠ El expediente '" + expediente
                + "' NO aparece en el tablero de gestión tras " + MAX_INTENTOS + " actualizaciones.");
        return false;
    }

    /**
     * DIAGNÓSTICO: devuelve los números de expediente (15 dígitos) listados actualmente en el
     * tablero "Mis cierres de expediente en gestión", separados por coma.
     */
    private String expedientesEnTableroGestion(JavascriptExecutor js) {
        try {
            Object r = js.executeScript(
                    "var sp=Array.from(document.querySelectorAll('span')).find(s=>s.textContent.indexOf('cierres de expediente')>=0);"
                  + "if(!sp) return 'SIN_SECCION';"
                  + "var b=sp.closest('.border-b'); if(!b) return 'SIN_BOARD';"
                  + "var tds=Array.from(b.querySelectorAll('table tbody tr td'));"
                  + "var nums=tds.map(td=>td.textContent.trim()).filter(t=>/^[0-9]{15}$/.test(t));"
                  + "return nums.join(',');");
            return r == null ? null : r.toString();
        } catch (Exception e) {
            return "ERR:" + e.getMessage();
        }
    }

    /**
     * Recorre el documento principal y todos los iframes buscando el botón Editar de la fila
     * cuyo texto contiene el expediente. Deja el driver en el frame donde lo encuentra (para
     * que el click posterior funcione). Devuelve null si no aparece dentro del timeout.
     */
    private WebElement localizarEditarEnAlgunFrame(WebDriver driver, String expediente, Duration timeout) {
        By rowEditar = By.xpath(
                "//table//tbody//tr[.//td[contains(normalize-space(.), '" + expediente + "')]]"
              + "//button[@title='Editar']");
        long deadline = System.currentTimeMillis() + timeout.toMillis();
        while (System.currentTimeMillis() < deadline) {
            driver.switchTo().defaultContent();
            WebElement f = primerClickable(driver, rowEditar);
            if (f != null) {
                return f;
            }
            for (WebElement frame : driver.findElements(By.tagName("iframe"))) {
                try {
                    driver.switchTo().defaultContent();
                    driver.switchTo().frame(frame);
                    f = primerClickable(driver, rowEditar);
                    if (f != null) {
                        return f;
                    }
                } catch (Exception ignored) {
                }
            }
            driver.switchTo().defaultContent();
            sleep(500);
        }
        return null;
    }

    /**
     * Busca en el documento principal y en los iframes un mensaje típico de "sin resultados".
     * Devuelve el texto encontrado (recortado) o null. Sirve para distinguir "filtro vacío"
     * (el proveedor no ve ese expediente) de "carga lenta / frame distinto".
     */
    private String mensajeSinResultados(WebDriver driver) {
        String script =
                "var pats=['no se encontr','sin resultados','no hay registros','no hay datos',"
              + "'0 resultados','no matching','no records','ningún resultado','ningun resultado'];"
              + "var t=(document.body?document.body.innerText:'').toLowerCase();"
              + "for (var i=0;i<pats.length;i++){var k=t.indexOf(pats[i]); if(k>=0){return document.body.innerText.substring(Math.max(0,k-10), k+50);}}"
              + "return null;";
        try {
            driver.switchTo().defaultContent();
            Object r = ((JavascriptExecutor) driver).executeScript(script);
            if (r instanceof String) {
                return ((String) r).replaceAll("\\s+", " ").trim();
            }
            for (WebElement frame : driver.findElements(By.tagName("iframe"))) {
                try {
                    driver.switchTo().defaultContent();
                    driver.switchTo().frame(frame);
                    Object rf = ((JavascriptExecutor) driver).executeScript(script);
                    if (rf instanceof String) {
                        return ((String) rf).replaceAll("\\s+", " ").trim();
                    }
                } catch (Exception ignored) {
                }
            }
        } catch (Exception ignored) {
        } finally {
            try { driver.switchTo().defaultContent(); } catch (Exception ignored) {}
        }
        return null;
    }

    /** Primer elemento visible y habilitado para el locator dado, o null. */
    private WebElement primerClickable(WebDriver driver, By locator) {
        for (WebElement el : driver.findElements(locator)) {
            try {
                if (el.isDisplayed() && el.isEnabled()) {
                    return el;
                }
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    /** Re-entra al frame del formulario de filtros, reescribe el expediente y vuelve a Filtrar. */
    private void reintentarFiltrar(WebDriver driver, JavascriptExecutor js, String expediente) {
        try {
            WebDriverWait w = new WebDriverWait(driver, Duration.ofSeconds(15));
            entrarAlFrameDelFormulario(driver, w);
            WebElement campo = w.until(ExpectedConditions.visibilityOfElementLocated(CAMPO_EXPEDIENTE));
            escribirEnFormio(js, campo, expediente);
            WebElement filtrar = w.until(ExpectedConditions.elementToBeClickable(BTN_FILTRAR));
            clickResiliente(js, filtrar);
            System.out.println("  [BuscarExpediente] ✓ Reintento de 'Filtrar' enviado");
        } catch (Exception e) {
            System.out.println("  [BuscarExpediente] ⚠ No se pudo reintentar 'Filtrar': " + e.getMessage());
        }
    }

    private void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    /**
     * Escribe en un input de Form.io: además de sendKeys, dispara los eventos input/change
     * para que Form.io registre el valor en su modelo interno.
     */
    private void escribirEnFormio(JavascriptExecutor js, WebElement input, String valor) {
        try {
            input.clear();
            input.sendKeys(valor);
        } catch (Exception ignored) {
        }
        String actual = input.getAttribute("value");
        if (actual == null || !actual.equals(valor)) {
            js.executeScript(
                    "arguments[0].value = arguments[1];"
                  + "arguments[0].dispatchEvent(new Event('input', {bubbles:true}));"
                  + "arguments[0].dispatchEvent(new Event('change', {bubbles:true}));",
                    input, valor);
        } else {
            js.executeScript(
                    "arguments[0].dispatchEvent(new Event('input', {bubbles:true}));"
                  + "arguments[0].dispatchEvent(new Event('change', {bubbles:true}));",
                    input);
        }
    }

    /**
     * Clic con JavaScript SIN hacer scrollIntoView. Útil para menús radix (portal): cualquier
     * scroll cierra el menú. JS .click() dispara el handler aunque el elemento no esté en viewport.
     */
    private void clickSinScroll(JavascriptExecutor js, WebElement el) {
        try {
            js.executeScript("arguments[0].click();", el);
        } catch (Exception e) {
            js.executeScript(
                    "var el=arguments[0];"
                  + "el.dispatchEvent(new MouseEvent('mousedown',{bubbles:true,cancelable:true,view:window}));"
                  + "el.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,cancelable:true,view:window}));"
                  + "el.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true,view:window}));",
                    el);
        }
    }

    private void clickResiliente(JavascriptExecutor js, WebElement elemento) {
        try {
            js.executeScript("arguments[0].scrollIntoView({block:'center'});", elemento);
        } catch (Exception ignored) {
        }
        try {
            elemento.click();
        } catch (Exception e1) {
            try {
                js.executeScript("arguments[0].click();", elemento);
            } catch (Exception e2) {
                js.executeScript(
                        "var evt = new MouseEvent('click', { bubbles: true, cancelable: true, view: window });"
                      + "arguments[0].dispatchEvent(evt);",
                        elemento);
            }
        }
    }

    private void esperarCargaPagina(WebDriver driver) {
        try {
            new WebDriverWait(driver, Duration.ofSeconds(30)).until(
                    d -> "complete".equals(((JavascriptExecutor) d).executeScript("return document.readyState")));
        } catch (Exception e) {
            System.out.println("  [BuscarExpediente] ⚠ Timeout esperando readyState, continuando...");
        }
    }
}
