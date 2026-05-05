package com.sara.automation.tasks;

import com.sara.automation.interactions.SwitchToOneScriptIframe;
import com.sara.automation.ui.CasoCreatePage;
import net.serenitybdd.screenplay.Actor;
import net.serenitybdd.screenplay.Performable;
import net.serenitybdd.screenplay.Task;
import net.serenitybdd.screenplay.actions.Click;
import net.serenitybdd.screenplay.actions.Enter;
import net.serenitybdd.screenplay.actions.Scroll;
import net.serenitybdd.screenplay.targets.Target;
import net.serenitybdd.screenplay.waits.WaitUntil;
import net.thucydides.core.annotations.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Keys;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static net.serenitybdd.screenplay.Tasks.instrumented;
import static net.serenitybdd.screenplay.matchers.WebElementStateMatchers.isVisible;

public class DiligenciarProveedorGestion implements Task {

    private static final String TIEMPO_MONITOREO_SITIO_DEFAULT = "60";
    private static final String TIEMPO_MONITOREO_DESTINO_DEFAULT = "120";
    private static final String CELULAR_TECNICO_DEFAULT = "3103904286";

    private final String nombreProveedor;
    private final String servicio;

    public DiligenciarProveedorGestion(String nombreProveedor, String servicio) {
        this.nombreProveedor = nombreProveedor;
        this.servicio = servicio;
    }

    public static Performable conDatos(String nombreProveedor, String servicio) {
        return instrumented(DiligenciarProveedorGestion.class, nombreProveedor, servicio);
    }

    @Override
    @Step("Gestionar proveedor: abrir tab, crear, seleccionar nombre/respuesta y guardar")
    public <T extends Actor> void performAs(T actor) {
        // Este paso ocurre dentro del formulario OneScript luego de crear el caso.
        actor.attemptsTo(SwitchToOneScriptIframe.required());

        // Esperar a que la página se recargue completamente después de guardar
        // La página hace reload y vuelve a mostrar los elementos del formulario
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // Primero, cerrar el timer overlay si está visible para no bloquear los elementos
        WebDriver driver = net.serenitybdd.screenplay.abilities.BrowseTheWeb.as(actor).getDriver();
        try {
            // Buscar el botón de cerrar del timer (×) con múltiples selectores alternativos
            By[] timerCloseSelectors = {
                // Selector por clase específica del botón de cierre
                By.xpath("//div[contains(@class, 'kace-timer-overlay')]//button[contains(@class, 'kace-timer-icon-button--danger')]"),
                // Selector por title
                By.xpath("//div[contains(@class, 'kace-timer-overlay')]//button[@title='Cerrar']"),
                // Selector genérico para cualquier botón dentro del timer
                By.xpath("//div[contains(@class, 'kace-timer-overlay')]//button"),
                // Selector por aria-label
                By.xpath("//button[contains(@aria-label, 'Cerrar') or contains(@aria-label, 'Close')]")
            };
            
            WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
            WebElement closeBtn = null;
            for (By selector : timerCloseSelectors) {
                try {
                    closeBtn = wait.until(ExpectedConditions.elementToBeClickable(selector));
                    System.out.println("  [DiligenciarProveedorGestion] Timer close button encontrado con selector: " + selector);
                    break;
                } catch (TimeoutException e) {
                    // Continuar con el siguiente selector
                }
            }
            
            if (closeBtn != null) {
                closeBtn.click();
                Thread.sleep(1000); // Dar tiempo a que se cierre
                System.out.println("  [DiligenciarProveedorGestion] Timer cerrado OK");
            } else {
                System.out.println("  [DiligenciarProveedorGestion] Timer no encontrado con ningún selector (puede ya estar cerrado)");
            }
        } catch (Exception e) {
            System.out.println("  [DiligenciarProveedorGestion] Error al cerrar timer: " + e.getMessage());
        }

        // Esperar adicional después de cerrar timer
        try {
            Thread.sleep(1500);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // PASO CRÍTICO: Activar el tab de Gestión de proveedores
        // Estrategia optimizada: 1) 10 TABs para hacer visible, 2) Scroll, 3) Clic directo, 4) Si falla: 16 TABs completos
        System.out.println("  [DiligenciarProveedorGestion] Activando tab de Gestión de proveedores...");
        boolean tabEncontrado = false;
        JavascriptExecutor js = (JavascriptExecutor) driver;
        
        // PASO 1: Hacer 10 TABs para que el campo "Gestión de Proveedores" sea visible
        try {
            System.out.println("  [DiligenciarProveedorGestion] Paso 1: Navegando con 10 TABs para visibilidad...");
            // Re-switch al iframe para asegurar contexto
            driver.switchTo().defaultContent();
            WebElement iframeElement = driver.findElement(By.id("form_onescript_iframe"));
            driver.switchTo().frame(iframeElement);
            
            WebElement body = driver.findElement(By.tagName("body"));
            for (int i = 0; i < 10; i++) {
                body.sendKeys(Keys.TAB);
                Thread.sleep(200);
                if ((i + 1) % 5 == 0) {
                    System.out.println("  [DiligenciarProveedorGestion] TAB " + (i + 1) + "/10");
                }
            }
            Thread.sleep(800);
            System.out.println("  [DiligenciarProveedorGestion] 10 TABs completados, campo ahora visible");
        } catch (Exception e) {
            System.out.println("  [DiligenciarProveedorGestion] Error en navegación TAB (continuando): " + e.getMessage());
        }
        
        // PASO 2: Hacer scroll para asegurar que el área de tabs esté completamente visible
        try {
            System.out.println("  [DiligenciarProveedorGestion] Paso 2: Haciendo scroll hacia área de tabs...");
            // Scroll hacia el contenedor de tabs
            js.executeScript("window.scrollTo(0, 300);");
            Thread.sleep(800);
            
            // Intentar hacer scroll específico al contenedor de tabs si está disponible
            WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
            WebElement tabContainer = wait.until(ExpectedConditions.presenceOfElementLocated(By.xpath("//ul[@role='tablist']")));
            js.executeScript("arguments[0].scrollIntoView({block: 'start', inline: 'nearest'});", tabContainer);
            Thread.sleep(800);
            System.out.println("  [DiligenciarProveedorGestion] Scroll completado, área de tabs optimizada");
        } catch (Exception e) {
            System.out.println("  [DiligenciarProveedorGestion] Error en scroll (continuando): " + e.getMessage());
        }
        
        // PASO 3: Intentar clic directo en el tab "Gestión de proveedores"
        By providerTabLocator = By.xpath("//ul[@role='tablist']//a[contains(@href,'gestionDeProveedores')] | //ul[@role='tablist']//button[contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'gestión de proveedores')]");
        try {
            System.out.println("  [DiligenciarProveedorGestion] Paso 3: Intentando clic directo en tab...");
            WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
            
            WebElement providerTab = null;
            try {
                providerTab = wait.until(ExpectedConditions.elementToBeClickable(providerTabLocator));
                System.out.println("  [DiligenciarProveedorGestion] Tab encontrado con XPath");
            } catch (Exception ignored) {
                System.out.println("  [DiligenciarProveedorGestion] XPath falló, intentando JS querySelector...");
                providerTab = (WebElement) js.executeScript(
                        "const list = Array.from(document.querySelectorAll(\"ul[role='tablist'] a, ul[role='tablist'] button\"));"
                                + "const match = list.find(el => el.getAttribute('href') === '#gestionDeProveedores' || el.textContent.toLowerCase().includes('gestión de proveedores'));"
                                + "return match || null;"
                );
            }

            if (providerTab != null) {
                System.out.println("  [DiligenciarProveedorGestion] Tab encontrado, intentando clic...");
                try {
                    providerTab.click();
                    System.out.println("  [DiligenciarProveedorGestion] Clic normal exitoso");
                } catch (Exception clickException) {
                    System.out.println("  [DiligenciarProveedorGestion] Clic normal falló, usando JS click: " + clickException.getMessage());
                    js.executeScript("arguments[0].click();", providerTab);
                    System.out.println("  [DiligenciarProveedorGestion] JS click ejecutado");
                }
                Thread.sleep(2000);
                tabEncontrado = true;
                System.out.println("  [DiligenciarProveedorGestion] ✓ Tab de Gestión de Proveedores activado con clic directo");
            }
        } catch (Exception e) {
            System.out.println("  [DiligenciarProveedorGestion] Clic directo falló: " + e.getMessage());
        }

        // PASO 4 (FALLBACK FINAL): Si el clic directo falló, completar navegación por teclado (16 TABs + Enter)
        if (!tabEncontrado) {
            System.out.println("  [DiligenciarProveedorGestion] Paso 4: Completando navegación por teclado (6 TABs adicionales + Enter)...");
            try {
                // Re-switch al iframe para asegurar contexto
                driver.switchTo().defaultContent();
                WebElement iframeElement = driver.findElement(By.id("form_onescript_iframe"));
                driver.switchTo().frame(iframeElement);
                
                // Ya hicimos 10 TABs, enviamos 6 TABs más para completar los 16
                WebElement body = driver.findElement(By.tagName("body"));
                for (int i = 0; i < 6; i++) {
                    body.sendKeys(Keys.TAB);
                    Thread.sleep(200);
                }
                System.out.println("  [DiligenciarProveedorGestion] TABs completados (10+6=16)");
                
                // Presionar Enter para activar el tab
                body.sendKeys(Keys.ENTER);
                Thread.sleep(2000);
                
                tabEncontrado = true;
                System.out.println("  [DiligenciarProveedorGestion] ✓ Navegación por teclado (16 TABs totales) completada");
            } catch (Exception e) {
                System.out.println("  [DiligenciarProveedorGestion] Error en navegación por teclado: " + e.getMessage());
            }
        }

        if (!tabEncontrado) {
            System.out.println("  [ERROR DiligenciarProveedorGestion] No se pudo acceder al tab de Gestión de Proveedores");
            throw new RuntimeException("No se pudo acceder al tab de Gestión de Proveedores");
        }

        // Esperar a que el botón Crear sea visible después de acceder al tab
        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Boton_Crear_Proveedor, isVisible()).forNoMoreThan(30).seconds());
        
        // Hacer clic en el botón Crear del grid de proveedores 
        actor.attemptsTo(Click.on(CasoCreatePage.Boton_Crear_Proveedor));
        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Proveedor_Dialog, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Nombre_Proveedor_Dropdown_Control, isVisible()).forNoMoreThan(15).seconds());

        seleccionarDesdeDropdownCustom(
                actor,
                CasoCreatePage.Nombre_Proveedor_Dropdown_Control,
                CasoCreatePage.CustomDropdownSearch,
                nombreProveedor
        );

        seleccionarDesdeDropdownCustom(
                actor,
                CasoCreatePage.Respuesta_Proveedor_Dropdown_Control,
                CasoCreatePage.CustomDropdownSearch,
                servicio
        );

        // Estos campos se habilitan después de elegir la respuesta del proveedor (ej. TOMA SERVICIO).
        llenarCampo(actor, CasoCreatePage.Tiempo_Monitoreo_Sitio_Minutos, TIEMPO_MONITOREO_SITIO_DEFAULT);
        llenarCampo(actor, CasoCreatePage.Tiempo_Monitoreo_Destino_Minutos, TIEMPO_MONITOREO_DESTINO_DEFAULT);
        llenarCampo(actor, CasoCreatePage.Celular_Tecnico_Proveedor, CELULAR_TECNICO_DEFAULT);

        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Guardar_Proveedor, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(Click.on(CasoCreatePage.Guardar_Proveedor));

        // Después de guardar el proveedor, hacer click en el guardado general flotante para aplicar cambios.
        actor.attemptsTo(WaitUntil.the(CasoCreatePage.Guardar_General_Flotante, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(Click.on(CasoCreatePage.Guardar_General_Flotante));
    }

    private <T extends Actor> void llenarCampo(T actor, Target campo, String valor) {
        actor.attemptsTo(Scroll.to(campo));
        actor.attemptsTo(WaitUntil.the(campo, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(Enter.theValue(valor).into(campo));
    }

    private <T extends Actor> void seleccionarDesdeDropdownCustom(T actor, Target control, Target searchInput, String valor) {
        actor.attemptsTo(WaitUntil.the(control, isVisible()).forNoMoreThan(20).seconds());
        actor.attemptsTo(Click.on(control));

        actor.attemptsTo(WaitUntil.the(searchInput, isVisible()).forNoMoreThan(10).seconds());
        actor.attemptsTo(Enter.theValue(valor).into(searchInput));

        actor.attemptsTo(WaitUntil.the(CasoCreatePage.CustomDropdownListItem.of(valor), isVisible()).forNoMoreThan(10).seconds());
        actor.attemptsTo(Click.on(CasoCreatePage.CustomDropdownListItem.of(valor)));
    }
}
