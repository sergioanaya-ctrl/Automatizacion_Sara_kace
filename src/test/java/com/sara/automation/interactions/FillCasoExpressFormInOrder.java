package com.sara.automation.interactions;

import com.sara.automation.ui.CasoCreatePage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Interaction;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.actions.Click;
import net.serenitybdd.screenplay.actions.Enter;
import net.serenitybdd.screenplay.actions.Scroll;
import net.serenitybdd.screenplay.targets.Target;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import net.serenitybdd.screenplay.waits.WaitUntil;

import java.time.Duration;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Random;

import static net.serenitybdd.screenplay.Tasks.instrumented;
import static net.serenitybdd.screenplay.matchers.WebElementStateMatchers.isVisible;

public class FillCasoExpressFormInOrder implements Interaction {

    // Esta interacción se ejecuta después de ClickCasoExpress.
    // Asume que el actor ya:
    // 1) abrió el formulario correcto,
    // 2) entró al iframe OneScript,
    // 3) habilitó la edición del formulario.
    // Su responsabilidad es solo diligenciar y guardar.

    private static final Random RANDOM = new Random();
    private static final String UBICACION_SERVICIO_DEFAULT = "produccion";

    private final String departamento;
    private final String municipio;
    private final String serviciosEspeciales;
    private final String gestor;
    private final String linea;
    private final String servicio;
    private String observacionFinal;

    public FillCasoExpressFormInOrder(String departamento, String municipio, String serviciosEspeciales, String gestor, String linea, String servicio) {
        this.departamento = departamento;
        this.municipio = municipio;
        this.serviciosEspeciales = serviciosEspeciales;
        this.gestor = gestor;
        this.linea = linea;
        this.servicio = servicio;
        this.observacionFinal = null;
    }

    public static Performable withManualLists(String departamento, String municipio, String serviciosEspeciales, String gestor, String linea, String servicio) {
        return instrumented(FillCasoExpressFormInOrder.class, departamento, municipio, serviciosEspeciales, gestor, linea, servicio);
    }

    public static Performable randomData() {
        return instrumented(FillCasoExpressFormInOrder.class, null, null, null, null, null, null);
    }

    @Override
    public <T extends Actor> void performAs(T actor) {
        // Garantiza que el driver este dentro del iframe antes de cualquier accion.
        // Screenplay puede resetear el contexto entre interacciones.
        WebDriver driver = net.serenitybdd.screenplay.abilities.BrowseTheWeb.as(actor).getDriver();
        driver.switchTo().defaultContent();
        new WebDriverWait(driver, Duration.ofSeconds(20))
                .until(ExpectedConditions.frameToBeAvailableAndSwitchToIt(By.id("form_onescript_iframe")));
        System.out.println("[FillCasoExpressFormInOrder] Switched to iframe OK");

        // Orden global de ejecucion dentro del iframe, siguiendo la UI:
        // datos básicos -> combos generales -> direcciones/ubicación -> asignación -> guardar.
        try {
            llenarDatosBasicosEnOrden(actor);
        } catch (Exception e) {
            throw new RuntimeException("Error al llenar datos básicos", e);
        }

        if (tieneListasManuales()) {
            llenarCombosGeneralesEnOrden(actor);
        }

        llenarDireccionesYUbicacionEnOrden(actor);

        if (tieneListasManuales()) {
            llenarServiciosEspecialesYAsignacionEnOrden(actor);
        }

        llenarObservacionFinal(actor);

        guardarFormulario(actor);
    }

    private boolean tieneListasManuales() {
        return departamento != null && municipio != null && serviciosEspeciales != null
                && gestor != null && linea != null && servicio != null;
    }

    private <T extends Actor> void llenarDatosBasicosEnOrden(T actor) throws Exception {
        String numeroExpediente = generarNumeroExpediente15();
        String nombreSolicitante = "Solicitante " + randomLetras(6);
        String cedulaSolicitante = randomDigitos(10);
        String telefono1 = "3" + randomDigitos(9);
        String telefono2 = "3" + randomDigitos(9);
        String placa = randomLetras(3) + randomDigitos(3);

        WebDriver driver = net.serenitybdd.screenplay.abilities.BrowseTheWeb.as(actor).getDriver();
        
        // Re-asegura que estamos en el iframe
        driver.switchTo().defaultContent();
        new WebDriverWait(driver, Duration.ofSeconds(20))
                .until(ExpectedConditions.frameToBeAvailableAndSwitchToIt(By.id("form_onescript_iframe")));
        System.out.println("  Driver en iframe OK");

        // Esperar a que campos sean visibles
        new WebDriverWait(driver, Duration.ofSeconds(20))
                .until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("input[name='data[numero_expediente]']")));
        System.out.println("  Campos del formulario visibles OK");
        
        // TODO con raw WebDriver - mantener contexto del iframe sin llamar a Screenplay
        
        // 1) Numero expediente - pegar desde clipboard
        WebElement expedienteField = driver.findElement(By.cssSelector("input[name='data[numero_expediente]']"));
        expedienteField.click();
        ((JavascriptExecutor) driver).executeScript(
            "var text = arguments[0];" +
            "var textarea = document.createElement('textarea');" +
            "textarea.textContent = text;" +
            "document.body.appendChild(textarea);" +
            "textarea.select();" +
            "document.execCommand('copy');" +
            "document.body.removeChild(textarea);",
            numeroExpediente
        );
        expedienteField.sendKeys(Keys.chord(Keys.CONTROL, "v"));
        Thread.sleep(300);
        System.out.println("  Numero expediente: " + numeroExpediente);
        this.observacionFinal = "OBS-" + numeroExpediente;
        
        // 2) Nombre solicitante
        WebElement nombreField = driver.findElement(By.cssSelector("input[name='data[nombre_solicitante]']"));
        nombreField.clear();
        nombreField.sendKeys(nombreSolicitante);
        System.out.println("  Nombre: " + nombreSolicitante);
        
        // 3) Cedula
        try {
            WebElement cedulaField = driver.findElement(By.cssSelector("input[name='data[cedula_del_solicitante]'], input[name='data[cedula_solicitante]']"));
            cedulaField.clear();
            cedulaField.sendKeys(cedulaSolicitante);
            System.out.println("  Cedula: " + cedulaSolicitante);
        } catch (Exception e) {
            System.out.println("  ERROR en cedula: " + e.getMessage());
            throw e;
        }
        
        // 4) Telefono 1
        try {
            WebElement tel1Field = driver.findElement(By.cssSelector("input[name='data[telefono_1]']"));
            tel1Field.clear();
            tel1Field.sendKeys(telefono1);
            System.out.println("  Telefono 1: " + telefono1);
        } catch (Exception e) {
            System.out.println("  ERROR en telefono 1: " + e.getMessage());
            throw e;
        }
        
        // 5) Telefono 2
        try {
            WebElement tel2Field = driver.findElement(By.cssSelector("input[name='data[telefono_2]']"));
            tel2Field.clear();
            tel2Field.sendKeys(telefono2);
            System.out.println("  Telefono 2: " + telefono2);
        } catch (Exception e) {
            System.out.println("  ERROR en telefono 2: " + e.getMessage());
            throw e;
        }
        
        // 6) Placa
        try {
            WebElement placaField = driver.findElement(By.cssSelector("input[name='data[placa]']"));
            placaField.clear();
            placaField.sendKeys(placa);
            System.out.println("  Placa: " + placa);
        } catch (Exception e) {
            System.out.println("  ERROR en placa: " + e.getMessage());
            throw e;
        }
        System.out.println("  Datos basicos completados OK");
    }

    private <T extends Actor> void llenarCombosGeneralesEnOrden(T actor) {
        // Estos combos aparecen en la sección General y dependen de los valores enviados desde el feature.
        WebDriver driver = net.serenitybdd.screenplay.abilities.BrowseTheWeb.as(actor).getDriver();
        seleccionarComboWebDriver(driver, "//div[contains(@class,'formio-component-departamento_solicita')]//div[contains(@class,'custom-dropdown-control')]", departamento);
        seleccionarComboMunicipioWebDriver(driver, "//div[contains(@class,'formio-component-municipio_solicita')]//div[contains(@class,'custom-dropdown-control')]", municipio);
    }

    private void seleccionarComboMunicipioWebDriver(WebDriver driver, String comboXpath, String valor) {
        WebDriverWait waitShort = new WebDriverWait(driver, Duration.ofSeconds(12));
        WebDriverWait waitLong = new WebDriverWait(driver, Duration.ofSeconds(60));

        By searchSelector = By.cssSelector("input.custom-dropdown-search, input[placeholder*='buscar'], input[placeholder*='Buscar']");
        By listItemExact = By.xpath("//ul[contains(@class,'custom-dropdown-list')]//li[normalize-space(.)='" + valor + "'] | //li[normalize-space(.)='" + valor + "']");
        By listItems = By.xpath("//ul[contains(@class,'custom-dropdown-list')]//li");

        try {
            WebElement combo = waitShort.until(ExpectedConditions.elementToBeClickable(By.xpath(comboXpath)));
            combo.click();
            WebElement search = waitLong.until(ExpectedConditions.visibilityOfElementLocated(searchSelector));
            search.clear();
            search.sendKeys(valor);

            System.out.println("  [seleccionarComboMunicipioWebDriver] Escribi: " + valor + ", esperando a que el municipio sea visible...");

            waitLong.until(driver1 -> {
                List<WebElement> items = driver1.findElements(listItemExact);
                return items.stream().anyMatch(item -> item.isDisplayed());
            });

            WebElement option = waitLong.until(ExpectedConditions.elementToBeClickable(listItemExact));
            option.click();
            return;
        } catch (Exception e) {
            System.out.println("  [seleccionarComboMunicipioWebDriver] ERROR: " + e.getMessage());
            throw new RuntimeException("Error seleccionando municipio: " + valor, e);
        }
    }

    private void seleccionarComboLineaWebDriver(WebDriver driver, String comboXpath, String valor) {
        seleccionarComboMunicipioWebDriver(driver, comboXpath, valor);
    }

    private void seleccionarComboServicioWebDriver(WebDriver driver, String comboXpath, String valor) {
        WebDriverWait waitShort = new WebDriverWait(driver, Duration.ofSeconds(12));
        WebDriverWait waitLong = new WebDriverWait(driver, Duration.ofSeconds(60));

        By searchSelector = By.cssSelector("input.custom-dropdown-search, input[placeholder*='buscar'], input[placeholder*='Buscar']");
        By listItemExact = By.xpath("//ul[contains(@class,'custom-dropdown-list')]//li[normalize-space(.)='" + valor + "'] | //li[normalize-space(.)='" + valor + "']");

        Exception lastError = null;
        for (int intento = 1; intento <= 3; intento++) {
            try {
                // Asegurar iframe en cada intento para evitar referencias obsoletas
                driver.switchTo().defaultContent();
                new WebDriverWait(driver, Duration.ofSeconds(20))
                        .until(ExpectedConditions.frameToBeAvailableAndSwitchToIt(By.id("form_onescript_iframe")));

                // 1) Clic en el combo Servicio
                WebElement combo = waitShort.until(ExpectedConditions.elementToBeClickable(By.xpath(comboXpath)));
                combo.click();

                // 2) Escribir en el campo de búsqueda del dropdown
                WebElement search = waitLong.until(driver1 -> {
                    List<WebElement> inputs = driver1.findElements(searchSelector);
                    for (WebElement input : inputs) {
                        if (input.isDisplayed() && input.isEnabled()) {
                            return input;
                        }
                    }
                    return null;
                });

                try {
                    ((JavascriptExecutor) driver).executeScript("arguments[0].focus();", search);
                    search.click();
                    search.sendKeys(Keys.chord(Keys.CONTROL, "a"), Keys.DELETE);
                    search.sendKeys(valor);
                } catch (org.openqa.selenium.ElementNotInteractableException e) {
                    ((JavascriptExecutor) driver).executeScript(
                            "arguments[0].value = arguments[1]; arguments[0].dispatchEvent(new Event('input', {bubbles:true}));",
                            search,
                            valor
                    );
                }

                System.out.println("  [seleccionarComboServicioWebDriver] Escribi: " + valor + ", esperando a que el servicio sea visible... (intento " + intento + ")");

                // 3) Esperar opción visible
                waitLong.until(driver1 -> {
                    List<WebElement> items = driver1.findElements(listItemExact);
                    return items.stream().anyMatch(WebElement::isDisplayed);
                });

                // 4) Clic en la opción visible
                boolean clicked = waitLong.until(driver1 -> {
                    List<WebElement> items = driver1.findElements(listItemExact);
                    for (WebElement item : items) {
                        if (item.isDisplayed()) {
                            try {
                                item.click();
                                return true;
                            } catch (org.openqa.selenium.StaleElementReferenceException ignored) {
                                // Reintentar en el siguiente poll
                            } catch (org.openqa.selenium.ElementNotInteractableException ignored) {
                                ((JavascriptExecutor) driver).executeScript("arguments[0].click();", item);
                                return true;
                            }
                        }
                    }
                    return false;
                });

                if (!clicked) {
                    throw new RuntimeException("No se pudo hacer clic en la opción visible de Servicio: " + valor);
                }
                return;
            } catch (org.openqa.selenium.StaleElementReferenceException stale) {
                lastError = stale;
                System.out.println("  [seleccionarComboServicioWebDriver] Stale detectado, reintentando... intento " + intento);
            } catch (Exception e) {
                lastError = e;
                if (e.getCause() instanceof org.openqa.selenium.StaleElementReferenceException && intento < 3) {
                    System.out.println("  [seleccionarComboServicioWebDriver] Stale en causa, reintentando... intento " + intento);
                    continue;
                }
                break;
            }
        }

        System.out.println("  [seleccionarComboServicioWebDriver] ERROR: " + (lastError != null ? lastError.getMessage() : "sin detalle"));
        throw new RuntimeException("Error seleccionando servicio: " + valor, lastError);
    }

    private void esperarServicioHabilitado(WebDriver driver) {
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));
        // Usar selectores basados en clases CSS, NO en IDs dinámicos
        By servicioDropdown = By.cssSelector(".formio-component-servicio .custom-dropdown");
        By servicioControl = By.cssSelector(".formio-component-servicio .custom-dropdown-control");

        wait.until(d -> {
            WebElement dropdown = d.findElement(servicioDropdown);
            String classes = dropdown.getAttribute("class");
            return classes != null && !classes.contains("kace-component--disabled");
        });

        wait.until(ExpectedConditions.elementToBeClickable(servicioControl));
        System.out.println("  [esperarServicioHabilitado] Servicio habilitado y clickable.");
    }

    private void seleccionarComboWebDriver(WebDriver driver, String comboXpath, String valor) {
        WebDriverWait waitShort = new WebDriverWait(driver, Duration.ofSeconds(12));

        By searchSelector = By.cssSelector("input.custom-dropdown-search, input[placeholder*='buscar'], input[placeholder*='Buscar']");
        By listItemExact = By.xpath("//ul[contains(@class,'custom-dropdown-list')]//li[normalize-space(.)='" + valor + "'] | //li[normalize-space(.)='" + valor + "']");
        By listItems = By.xpath("//ul[contains(@class,'custom-dropdown-list')]//li");

        try {
            WebElement combo = waitShort.until(ExpectedConditions.elementToBeClickable(By.xpath(comboXpath)));
            combo.click();
            WebElement search = waitShort.until(ExpectedConditions.visibilityOfElementLocated(searchSelector));
            search.clear();
            search.sendKeys(valor);
            Thread.sleep(300);

            System.out.println("  [seleccionarComboWebDriver] Escribi: " + valor + ", esperando a que aparezca el listado...");

            waitShort.until(driver1 -> {
                List<WebElement> items = driver1.findElements(listItems);
                return items.stream().anyMatch(item ->
                    item.isDisplayed() && valor.equals(item.getText().trim()));
            });

            Thread.sleep(200);
            List<WebElement> items = driver.findElements(listItems);
            for (WebElement item : items) {
                if (valor.equals(item.getText().trim()) && item.isDisplayed()) {
                    System.out.println("  [seleccionarComboWebDriver] Haciendo clic en: " + valor);
                    item.click();
                    Thread.sleep(300);
                    return;
                }
            }
            WebElement option = waitShort.until(ExpectedConditions.elementToBeClickable(listItemExact));
            option.click();
            return;
        } catch (Exception e) {
            System.out.println("  [seleccionarComboWebDriver] ERROR: " + e.getMessage());
            throw new RuntimeException("Error seleccionando combo: " + valor, e);
        }
    }

    private <T extends Actor> void llenarDireccionesYUbicacionEnOrden(T actor) {
        ensureIframeContext(actor);

        String direccionServicio = "Calle " + (10 + RANDOM.nextInt(80)) + " #" + (1 + RANDOM.nextInt(99)) + "-" + (1 + RANDOM.nextInt(99));
        String direccionDestino = "Carrera " + (10 + RANDOM.nextInt(80)) + " #" + (1 + RANDOM.nextInt(99)) + "-" + (1 + RANDOM.nextInt(99));
        String detalleDireccionServicio = "Apto " + (1 + RANDOM.nextInt(50)) + ", Torre " + (char) ('A' + RANDOM.nextInt(6));
        String detalleDireccionDestino = "Referencia " + randomLetras(5) + " " + randomDigitos(3);
        String marcaVehiculo = "Marca " + randomLetras(4).toUpperCase();

        // Bloque de direcciones respetando la vista del formulario.
        llenarCampo(actor, CasoCreatePage.Direccion_Servicio, direccionServicio);
        llenarCampo(actor, CasoCreatePage.Direccion_Destino, direccionDestino);
        llenarCampo(actor, CasoCreatePage.Detalle_Direccion_Destino, detalleDireccionDestino);
        llenarCampo(actor, CasoCreatePage.Detalle_Direccion_Servicio, detalleDireccionServicio);
        llenarCampo(actor, CasoCreatePage.Marca_Vehiculo, marcaVehiculo);
        llenarCampo(actor, CasoCreatePage.Ubicacion_Servicio, UBICACION_SERVICIO_DEFAULT);
    }

    private <T extends Actor> void llenarServiciosEspecialesYAsignacionEnOrden(T actor) {
        // Servicios especiales deshabilitado - saltamos directo a Línea y Servicio
        
        // Obtener el driver y asegurar contexto del iframe
        WebDriver driver = net.serenitybdd.screenplay.abilities.BrowseTheWeb.as(actor).getDriver();
        
        // Asegurar que estamos en el iframe antes de cualquier scroll
        driver.switchTo().defaultContent();
        new WebDriverWait(driver, Duration.ofSeconds(20))
                .until(ExpectedConditions.frameToBeAvailableAndSwitchToIt(By.id("form_onescript_iframe")));
        System.out.println("  [llenarServiciosEspecialesYAsignacionEnOrden] Contexto del iframe OK");
        
        // Hacer scroll dentro del iframe usando JavaScriptExecutor
        try {
            String scrollScript = "var linea = document.evaluate(\"//label[normalize-space()='Línea *' or normalize-space()='Línea']\", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; " +
                                  "if (linea) { linea.scrollIntoView(true); }";
            ((JavascriptExecutor) driver).executeScript(scrollScript);
            Thread.sleep(500);
            System.out.println("  [llenarServiciosEspecialesYAsignacionEnOrden] Scroll a Línea OK");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        // Línea y Servicio usan custom dropdowns - usar selectores basados en clases, NO en IDs dinámicos
        seleccionarComboLineaWebDriver(driver, "//div[contains(@class,'formio-component-linea')]//div[contains(@class,'custom-dropdown-control')]", linea);
        // Asegurarse de que el dropdown de Línea se cerró antes de abrir Servicio
        ((JavascriptExecutor) driver).executeScript("document.activeElement.blur();");
        esperarServicioHabilitado(driver);
        // Usar selector específico que busca por el label "Servicio" (no "Servicio Especial")
        seleccionarComboServicioWebDriver(driver, "//div[contains(@class,'formio-component-servicio') and .//label[normalize-space()='Servicio' and not(contains(., 'Especial'))]]//div[contains(@class,'custom-dropdown-control')]", servicio);
    }

    private <T extends Actor> void llenarObservacionFinal(T actor) {
        // Último campo editable del formulario antes de accionar Guardar.
        actor.attemptsTo(Scroll.to(CasoCreatePage.Observacion_Final));
        String observacion = this.observacionFinal != null ? this.observacionFinal : generarObservacionAleatoria();
        llenarCampo(actor, CasoCreatePage.Observacion_Final, observacion);
    }

    private String generarObservacionAleatoria() {
        return "OBS-" + randomLetras(4) + randomDigitos(6);
    }

    private <T extends Actor> void guardarFormulario(T actor) {
        ensureIframeContext(actor);
        try {
            actor.attemptsTo(Scroll.to(CasoCreatePage.Guardar_Formulario));
            actor.attemptsTo(WaitUntil.the(CasoCreatePage.Guardar_Formulario, isVisible()).forNoMoreThan(20).seconds());
            actor.attemptsTo(Click.on(CasoCreatePage.Guardar_Formulario));
            // Esperar a que la página procese el guardado y se recargue completamente
            // La página hace reload dentro del iframe, necesitamos dar tiempo para que termine
            Thread.sleep(500);
        } catch (Throwable e) {
            actor.attemptsTo(WaitUntil.the(CasoCreatePage.Guardar_Formulario_FALLBACK, isVisible()).forNoMoreThan(10).seconds());
            actor.attemptsTo(Click.on(CasoCreatePage.Guardar_Formulario_FALLBACK));
            try {
                Thread.sleep(500);
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private <T extends Actor> void llenarCampo(T actor, Target target, String valor) {
        // Reingresar al iframe antes de interactuar con el campo.
        ensureIframeContext(actor);
        actor.attemptsTo(Scroll.to(target));
        actor.attemptsTo(WaitUntil.the(target, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(Enter.theValue(valor).into(target));
    }

    private <T extends Actor> void ensureIframeContext(T actor) {
        WebDriver driver = net.serenitybdd.screenplay.abilities.BrowseTheWeb.as(actor).getDriver();
        driver.switchTo().defaultContent();
        new WebDriverWait(driver, Duration.ofSeconds(20))
                .until(ExpectedConditions.frameToBeAvailableAndSwitchToIt(By.id("form_onescript_iframe")));
    }

    private <T extends Actor> void seleccionar(T actor, Target combo, String valor) {
        // Helper común para listas: abre el combo y busca la opción.
        actor.attemptsTo(WaitUntil.the(combo, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(Click.on(combo));

        try {
            actor.attemptsTo(WaitUntil.the(CasoCreatePage.CustomDropdownSearch, isVisible()).forNoMoreThan(3).seconds());
            actor.attemptsTo(Enter.theValue(valor).into(CasoCreatePage.CustomDropdownSearch));
            actor.attemptsTo(WaitUntil.the(CasoCreatePage.CustomDropdownListItem.of(valor), isVisible()).forNoMoreThan(10).seconds());
            actor.attemptsTo(Click.on(CasoCreatePage.CustomDropdownListItem.of(valor)));
            return;
        } catch (Throwable ignore) {
            // Si no existe búsqueda custom, continuar con opciones visibles.
        }

        try {
            actor.attemptsTo(WaitUntil.the(CasoCreatePage.Opcion_Lista.of(valor), isVisible()).forNoMoreThan(10).seconds());
            actor.attemptsTo(Click.on(CasoCreatePage.Opcion_Lista.of(valor)));
            return;
        } catch (Throwable ignore) {
            // Ignorar y probar la opción por texto parcial.
        }

        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Opcion_Lista_Contiene.of(valor), isVisible()).forNoMoreThan(10).seconds());
        actor.attemptsTo(Click.on(CasoCreatePage.Opcion_Lista_Contiene.of(valor)));
    }

    private String generarNumeroExpediente15() {
        return randomDigitos(15);
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

