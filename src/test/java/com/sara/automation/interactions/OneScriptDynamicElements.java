package com.sara.automation.interactions;

import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.StaleElementReferenceException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

public final class OneScriptDynamicElements {

    private OneScriptDynamicElements() {
    }

    public static void waitForProveedorSection(WebDriver driver, Duration timeout) {
        long startTime = System.currentTimeMillis();
        long timeoutMs = timeout.toMillis();

        while (System.currentTimeMillis() - startTime < timeoutMs) {
            try {
                Object result = ((JavascriptExecutor) driver).executeScript(
                        "const normalize = text => text.replace(/\\s+/g, ' ').trim().toLowerCase();"
                                + "const renderizado = el => !!el && el.offsetParent !== null && el.getBoundingClientRect().width > 0;"
                                + "const nombre = document.querySelector('#custom-select-e75nu5o .custom-dropdown-control, div.formio-component-custom-select.formio-component-nombre .custom-dropdown-control');"
                                + "const respuesta = document.querySelector('div.formio-component-custom-select.formio-component-respuesta_de_proveedor .custom-dropdown-control');"
                                + "const saveBtn = Array.from(document.querySelectorAll('button')).find(b => renderizado(b) && normalize(b.textContent).includes('guardar'));"
                                + "const modalAbierto = !!document.querySelector('.modal, .formio-dialog-content, [role=\"dialog\"]');"
                                + "const inputsVisibles = Array.from(document.querySelectorAll('input, select, textarea, .custom-dropdown-control')).filter(el => renderizado(el)).length;"
                                + "const selectoresEspecificos = (renderizado(nombre) && renderizado(respuesta)) || (renderizado(nombre) && saveBtn);"
                                + "const modalLista = (modalAbierto && inputsVisibles >= 2) || selectoresEspecificos;"
                                + "return {especificos: selectoresEspecificos, modalLista: modalLista, inputs: inputsVisibles, modal: modalAbierto};"
                );

                if (result instanceof java.util.Map) {
                    java.util.Map map = (java.util.Map) result;
                    Boolean especificos = (Boolean) map.get("especificos");
                    Boolean modalLista = (Boolean) map.get("modalLista");

                    // CRITERIO: si los selectores específicos están listos, retornar
                    if (especificos != null && especificos) {
                        System.out.println("[waitForProveedorSection] ✓ Selectores específicos listos");
                        sleep(200);
                        return;
                    }

                    // FALLBACK: si la modal está abierta Y hay >=2 inputs visibles, continuar sin esperar más
                    if (modalLista != null && modalLista) {
                        System.out.println("[waitForProveedorSection] ✓ Modal lista para interactuar (inputs: " + map.get("inputs") + ")");
                        sleep(200);
                        return;
                    }
                }
            } catch (Exception e) {
                // Script falló, esperar siguiente iteración
            }

            sleep(500);
        }

        // Timeout completado: log de advertencia pero continuar
        System.out.println("[waitForProveedorSection] ⚠ Timeout esperando proveedor, pero continuando...");
        sleep(200);
    }

    public static void clickVisibleButtonByText(WebDriver driver, String text) {
        Object candidate = ((JavascriptExecutor) driver).executeScript(
                "const wanted = arguments[0].toLowerCase();"
                        + "const buttons = Array.from(document.querySelectorAll('button'));"
                        + "const visible = buttons.filter(b => b.offsetParent !== null);"
                        + "const prioritized = visible.find(b => (b.getAttribute('ref') || '').toLowerCase().includes('gestion_proveedor') && b.textContent.trim().toLowerCase().includes(wanted));"
                        + "const found = prioritized || visible.find(b => b.textContent.trim().toLowerCase().includes(wanted));"
                        + "if (found) { found.scrollIntoView({block:'center', inline:'nearest'}); }"
                        + "return found || null;",
                text
        );

        if (!(candidate instanceof WebElement)) {
            throw new NoSuchElementException("No se encontró botón visible con texto: " + text);
        }

        // Clic NATIVO (isTrusted=true) primero: un editGrid "addRow" disparado con evento
        // sintético puede abrir el modal visualmente sin inicializar bien los componentes de la
        // nueva fila (mismo patrón detectado en la carga de opciones del dropdown y en el guardado
        // general). Cae a JS solo si el clic nativo falla (p. ej. elemento tapado).
        WebElement button = (WebElement) candidate;
        try {
            button.click();
        } catch (Exception e) {
            ((JavascriptExecutor) driver).executeScript(
                    "arguments[0].dispatchEvent(new MouseEvent('mousedown', {bubbles:true}));"
                            + "arguments[0].dispatchEvent(new MouseEvent('mouseup', {bubbles:true}));"
                            + "arguments[0].click();",
                    button
            );
        }
    }

    public static void selectCustomDropdownByComponentClass(WebDriver driver, String componentClass, String value) {
        selectCustomDropdownByComponentClass(driver, componentClass, value, null);
    }

    /**
     * Igual que {@link #selectCustomDropdownByComponentClass(WebDriver, String, String)} pero
     * acota la búsqueda del control a un contenedor (CSS scope, p. ej. ".formio-dialog-content"),
     * para no confundir el dropdown de un modal con otro homónimo del resto de la página
     * (p. ej. el resumen del editGrid).
     */
    public static void selectCustomDropdownByComponentClass(WebDriver driver, String componentClass, String value, String scope) {
        // Espera ACTIVA del control: Form.io puede renderizar/re-renderizar el dropdown un instante
        // después de que la sección esté "lista", lo que causaba NoSuchElement intermitente.
        WebElement control = waitForDropdownControl(driver, componentClass, scope, Duration.ofSeconds(15));
        if (control == null) {
            throw new NoSuchElementException("No se encontró el dropdown control para componente: " + componentClass);
        }

        abrirDropdown(driver, componentClass, scope, control);

        // Espera ACTIVA del campo de búsqueda (en vez de un sleep fijo): retorna apenas aparece
        // (rápido si el dropdown abre rápido) y tolera hasta 5s si bajo carga abre lento,
        // garantizando que el filtrado se aplique.
        WebElement search = waitForSearchInput(driver, componentClass, scope, Duration.ofSeconds(5));
        if (search != null) {
            escribirEnBusqueda(driver, componentClass, scope, search, value);
        }

        // Espera ACTIVA a que aparezca la opción: la búsqueda es asíncrona contra el backend y
        // puede tardar de forma variable. Mientras espera, re-verifica que el input de búsqueda
        // conserve el valor escrito (Form.io puede re-renderizarlo y perderlo) y lo reescribe si
        // hace falta, en vez de depender de un timeout fijo adivinado.
        WebElement option;
        try {
            option = findOptionByText(driver, value, componentClass, scope);
        } catch (org.openqa.selenium.TimeoutException e) {
            throw new NoSuchElementException(
                    "No se encontró la opción '" + value + "' del dropdown '" + componentClass + "'. "
                            + diagnosticoDropdown(driver, componentClass, scope), e);
        }
        if (option == null) {
            throw new NoSuchElementException("No se encontró la opción del dropdown: " + value);
        }

        clickWithJs(driver, option);
        sleep(150); // breve, para que la selección asiente antes de continuar
    }

    /**
     * Abre el dropdown custom del componente indicado y selecciona la PRIMERA opción válida
     * (sin importar el texto). Útil para campos requeridos donde cualquier opción sirve
     * (p. ej. "Tipo de gestión", "Persona de gestión").
     *
     * @return el texto de la opción seleccionada.
     */
    public static String selectFirstCustomDropdownOption(WebDriver driver, String componentClass) {
        return selectFirstCustomDropdownOption(driver, componentClass, null);
    }

    /**
     * Variante con scope (CSS) para acotar el control a un contenedor (p. ej. un modal).
     * Espera ACTIVAMENTE a que la lista cargue opciones VÁLIDAS (descarta placeholders/"cargando")
     * antes de elegir la primera, ya que las opciones pueden venir de forma asíncrona del backend.
     */
    public static String selectFirstCustomDropdownOption(WebDriver driver, String componentClass, String scope) {
        WebElement control = waitForDropdownControl(driver, componentClass, scope, Duration.ofSeconds(15));
        if (control == null) {
            throw new NoSuchElementException("No se encontró el dropdown control para componente: " + componentClass);
        }
        abrirDropdown(driver, componentClass, scope, control);

        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        WebElement primera = wait.until(d -> {
            Object found = ((JavascriptExecutor) d).executeScript(
                    "const malos = ['cargando','loading','no hay','sin resultados','no results','no se encontr','elige una','seleccion'];"
                            + "const items = Array.from(document.querySelectorAll('ul.custom-dropdown-list li, div.custom-dropdown-item, div[role=\\\"option\\\"]'));"
                            + "const visible = items.filter(el => el.offsetParent !== null && el.textContent.trim().length > 0"
                            + "    && !malos.some(m => el.textContent.trim().toLowerCase().includes(m)));"
                            + "return visible.length ? visible[0] : null;");
            return found instanceof WebElement ? (WebElement) found : null;
        });
        String texto = primera.getText().trim();
        clickWithJs(driver, primera);
        sleep(150);
        return texto;
    }

    /**
     * Abre el control de dropdown dado (un .custom-dropdown-control concreto) y selecciona la
     * PRIMERA opción válida. Útil para diligenciar genéricamente todos los dropdowns de un dialog
     * sin conocer sus nombres de componente. Devuelve el texto elegido.
     */
    public static String selectFirstOptionOfControl(WebDriver driver, WebElement control) {
        clickWithJs(driver, control);
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        WebElement primera = wait.until(d -> {
            Object found = ((JavascriptExecutor) d).executeScript(
                    "const malos = ['cargando','loading','no hay','sin resultados','no results','no se encontr','elige una','seleccion'];"
                            + "const items = Array.from(document.querySelectorAll('ul.custom-dropdown-list li, div.custom-dropdown-item, div[role=\\\"option\\\"]'));"
                            + "const visible = items.filter(el => el.offsetParent !== null && el.textContent.trim().length > 0"
                            + "    && !malos.some(m => el.textContent.trim().toLowerCase().includes(m)));"
                            + "return visible.length ? visible[0] : null;");
            return found instanceof WebElement ? (WebElement) found : null;
        });
        String texto = primera.getText().trim();
        clickWithJs(driver, primera);
        sleep(150);
        return texto;
    }

    /**
     * Espera ACTIVAMENTE a que el control del dropdown exista y sea visible, reintentando ante
     * ausencia o staleness (Form.io re-renderiza). Devuelve null si no apareció en el timeout.
     */
    private static WebElement waitForDropdownControl(WebDriver driver, String componentClass, String scope, Duration timeout) {
        long deadline = System.currentTimeMillis() + timeout.toMillis();
        WebElement control = null;
        while (System.currentTimeMillis() < deadline) {
            try {
                control = getDropdownControl(driver, componentClass, scope);
                if (control != null && control.isDisplayed()) {
                    return control;
                }
            } catch (StaleElementReferenceException ignored) {
                // Re-render en curso: se reintenta.
            }
            try {
                Thread.sleep(200);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
        return control;
    }

    /**
     * Abre el dropdown clickeando su control, re-localizándolo si quedó stale tras un re-render.
     */
    private static void abrirDropdown(WebDriver driver, String componentClass, String scope, WebElement control) {
        try {
            clickReal(driver, control);
        } catch (StaleElementReferenceException e) {
            WebElement fresco = waitForDropdownControl(driver, componentClass, scope, Duration.ofSeconds(5));
            if (fresco == null) {
                throw new NoSuchElementException("El dropdown control quedó stale y no reapareció: " + componentClass);
            }
            clickReal(driver, fresco);
        }
    }

    /**
     * Clic NATIVO de Selenium (no sintético vía JS): algunos componentes solo disparan la carga
     * asíncrona de opciones ante un evento de usuario "trusted" (isTrusted=true). El click vía
     * JavascriptExecutor (dispatchEvent/candidate.click()) es isTrusted=false y puede abrir el
     * dropdown visualmente sin disparar esa carga, dejando la lista vacía indefinidamente.
     * Cae a clic por JS solo si el nativo falla (p. ej. elemento tapado por otro overlay).
     */
    private static void clickReal(WebDriver driver, WebElement element) {
        try {
            ((JavascriptExecutor) driver).executeScript(
                    "arguments[0].scrollIntoView({block:'center', inline:'nearest'});", element);
            element.click();
        } catch (Exception e) {
            clickWithJs(driver, element);
        }
    }

    private static WebElement getDropdownControl(WebDriver driver, String componentClass, String scope) {
        Object element = ((JavascriptExecutor) driver).executeScript(
                "const scope = arguments[1] ? (arguments[1] + ' ') : '';"
                        + "const selector = scope + 'div.formio-component-custom-select.' + arguments[0] + ' .custom-dropdown-control';"
                        + "const found = document.querySelector(selector);"
                        + "if (found) return found;"
                        + "const root = arguments[1] ? (document.querySelector(arguments[1]) || document) : document;"
                        + "const normalize = text => text.replace(/\\s+/g, ' ').trim().toLowerCase();"
                        + "const wanted = arguments[0].replace('formio-component-', '').replace(/_/g, ' ');"
                        + "const label = Array.from(root.querySelectorAll('label')).find(l => normalize(l.textContent).includes(wanted));"
                        + "if (!label) return null;"
                        + "const container = label.closest('.formio-component') || label.closest('.formio-component-custom-select') || label.parentElement;"
                        + "return container ? container.querySelector('.custom-dropdown-control') : null;",
                componentClass, scope
        );
        return element instanceof WebElement ? (WebElement) element : null;
    }

    /**
     * Espera activa del campo de búsqueda del dropdown: reintenta {@link #getSearchInput} hasta
     * que aparezca o se agote el timeout. Devuelve null si no apareció (el llamador continúa:
     * findOptionByText buscará entre las opciones visibles sin filtrar).
     */
    private static WebElement waitForSearchInput(WebDriver driver, String componentClass, String scope, Duration timeout) {
        long deadline = System.currentTimeMillis() + timeout.toMillis();
        WebElement search = getSearchInput(driver, componentClass, scope);
        while (search == null && System.currentTimeMillis() < deadline) {
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
            search = getSearchInput(driver, componentClass, scope);
        }
        return search;
    }

    private static WebElement getSearchInput(WebDriver driver, String componentClass, String scope) {
        Object element = ((JavascriptExecutor) driver).executeScript(
                "const scope = arguments[1] ? (arguments[1] + ' ') : '';"
                        + "const base = document.querySelector(scope + 'div.formio-component-custom-select.' + arguments[0]);"
                        + "if (base) {"
                        + "  const inside = base.querySelector('input.custom-dropdown-search, input[placeholder*=\\\"buscar\\\"], input[placeholder*=\\\"Buscar\\\"]');"
                        + "  if (inside) return inside;"
                        + "}"
                        + "const root = arguments[1] ? (document.querySelector(arguments[1]) || document) : document;"
                        + "const normalize = text => text.replace(/\\s+/g, ' ').trim().toLowerCase();"
                        + "const wanted = arguments[0].replace('formio-component-', '').replace(/_/g, ' ');"
                        + "const label = Array.from(root.querySelectorAll('label')).find(l => normalize(l.textContent).includes(wanted));"
                        + "if (label) { const container = label.closest('.formio-component') || label.closest('.formio-component-custom-select') || label.parentElement; if (container) { const inside = container.querySelector('input.custom-dropdown-search, input[placeholder*=\\\"buscar\\\"], input[placeholder*=\\\"Buscar\\\"]'); if (inside) return inside; } }"
                        + "const active = document.activeElement;"
                        + "if (active && active.tagName === 'INPUT') return active;"
                        + "return document.querySelector('input.custom-dropdown-search, input[placeholder*=\\\"buscar\\\"], input[placeholder*=\\\"Buscar\\\"]');",
                componentClass, scope
        );
        return element instanceof WebElement ? (WebElement) element : null;
    }

    /**
     * Recolecta info de diagnóstico cuando no se encuentra una opción: si el input de búsqueda
     * existe y qué valor quedó escrito, y el texto de las opciones actualmente visibles.
     * Solo se usa para enriquecer el mensaje de error, no afecta el flujo normal.
     */
    private static String diagnosticoDropdown(WebDriver driver, String componentClass, String scope) {
        try {
            Object info = ((JavascriptExecutor) driver).executeScript(
                    "const scope = arguments[1] ? (arguments[1] + ' ') : '';"
                            + "const base = document.querySelector(scope + 'div.formio-component-custom-select.' + arguments[0]);"
                            + "const search = base ? base.querySelector('input.custom-dropdown-search, input[placeholder*=\\\"uscar\\\"]') : null;"
                            + "const items = Array.from(document.querySelectorAll('ul.custom-dropdown-list li, div.custom-dropdown-item, div[role=\\\"option\\\"]'))"
                            + "  .filter(el => el.offsetParent !== null)"
                            + "  .map(el => el.textContent.trim())"
                            + "  .slice(0, 20);"
                            + "return 'search_input_encontrado=' + (!!search) + ', valor_actual=\"' + (search ? search.value : '') "
                            + "  + '\", opciones_visibles=[' + items.join(' | ') + ']';",
                    componentClass, scope
            );
            return String.valueOf(info);
        } catch (Exception ex) {
            return "(no se pudo obtener diagnóstico: " + ex.getMessage() + ")";
        }
    }

    /**
     * Escribe el valor en el input de búsqueda del dropdown, relocalizándolo si Form.io lo
     * re-renderiza (stale) justo al escribir.
     */
    private static void escribirEnBusqueda(WebDriver driver, String componentClass, String scope,
                                            WebElement search, String value) {
        try {
            setInputValue(driver, search, value);
        } catch (StaleElementReferenceException e) {
            WebElement searchFresco = waitForSearchInput(driver, componentClass, scope, Duration.ofSeconds(5));
            if (searchFresco != null) {
                setInputValue(driver, searchFresco, value);
            }
        }
    }

    private static WebElement findOptionByText(WebDriver driver, String value, String componentClass, String scope) {
        // La lista se llena vía búsqueda asíncrona contra el backend: no hay un tiempo fijo
        // confiable, así que se espera activamente hasta que aparezca (con un techo de
        // seguridad), reescribiendo el valor de búsqueda si el input lo perdió en el camino.
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(60));
        return wait.until(d -> {
            Object found = ((JavascriptExecutor) d).executeScript(
                    "const wanted = arguments[0].toLowerCase();"
                            + "const items = Array.from(document.querySelectorAll('ul.custom-dropdown-list li, div.custom-dropdown-item, div[role=\\\"option\\\"]'));"
                            + "const visible = items.filter(el => el.offsetParent !== null);"
                            + "const exact = visible.find(el => el.textContent.trim().toLowerCase() === wanted);"
                            + "if (exact) return exact;"
                            + "return visible.find(el => el.textContent.trim().toLowerCase().includes(wanted)) || null;",
                    value
            );
            if (found instanceof WebElement) {
                return (WebElement) found;
            }
            // Reafirma el valor de búsqueda por si el input se limpió o quedó stale a mitad de espera.
            try {
                WebElement search = getSearchInput(d, componentClass, scope);
                if (search != null && !value.equalsIgnoreCase(search.getAttribute("value"))) {
                    escribirEnBusqueda(d, componentClass, scope, search, value);
                }
            } catch (StaleElementReferenceException ignored) {
                // Se reintenta en la próxima vuelta del poll.
            }
            return null;
        });
    }

    private static void clickWithJs(WebDriver driver, WebElement element) {
        ((JavascriptExecutor) driver).executeScript(
                "arguments[0].scrollIntoView({block:'center', inline:'nearest'});"
                        + "arguments[0].dispatchEvent(new MouseEvent('mousedown', {bubbles:true}));"
                        + "arguments[0].dispatchEvent(new MouseEvent('mouseup', {bubbles:true}));"
                        + "arguments[0].click();",
                element
        );
    }

    private static void setInputValue(WebDriver driver, WebElement input, String value) {
        ((JavascriptExecutor) driver).executeScript(
                "arguments[0].focus();"
                        + "arguments[0].value = '';"
                        + "arguments[0].value = arguments[1];"
                        + "arguments[0].dispatchEvent(new Event('input', {bubbles:true}));"
                        + "arguments[0].dispatchEvent(new Event('change', {bubbles:true}));",
                input,
                value
        );
    }

    private static void sleep(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
