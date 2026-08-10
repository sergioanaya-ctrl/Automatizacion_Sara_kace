package com.sara.automation.utils;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.StaleElementReferenceException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

/**
 * Utilidades compartidas para que CUALQUIER submódulo del formulario de casos (Novedades,
 * Finalización, Documentación CNM, Escalamientos Sura, Gestión de proveedores, ...) pueda
 * ejecutarse de forma INDEPENDIENTE, sin importar el orden en que se invoque desde el feature.
 *
 * PROBLEMA QUE RESUELVE:
 * Form.io re-renderiza el DOM tras cada guardado (dialog o guardado general). Si un submódulo
 * localiza un WebElement (esperarClickable) y el guardado del submódulo ANTERIOR dispara un
 * re-render/recarga justo antes de hacer clic, ese WebElement queda "stale" y el clic revienta
 * con StaleElementReferenceException, aunque el elemento exista de nuevo en el DOM.
 *
 * SOLUCIÓN:
 * En vez de "localizar una vez y usar esa referencia", este helper localiza y hace clic dentro
 * del MISMO ciclo de reintento: si el clic falla por staleness, vuelve a localizar el elemento
 * desde cero (By, no WebElement) y reintenta. Esto hace que cada submódulo sea resiliente a
 * cambios de estado producidos por el paso previo, sin necesidad de sincronizarlos entre sí.
 */
public final class ResilientFormActions {

    private ResilientFormActions() {
    }

    /**
     * Espera a que el elemento (por selector principal, con fallback) esté clickeable y hace
     * clic, reintentando desde cero (re-localizando por By) si el elemento queda stale.
     */
    public static void clickConReintentoStaleSafe(WebDriver driver, By principal, By fallback,
                                                   int segundosTimeout, int maxIntentos) {
        JavascriptExecutor js = (JavascriptExecutor) driver;
        StaleElementReferenceException ultimoStale = null;

        for (int intento = 1; intento <= maxIntentos; intento++) {
            try {
                WebElement el = esperarClickable(driver, principal, fallback, segundosTimeout);
                js.executeScript("arguments[0].scrollIntoView({block:'center'});", el);
                clickResiliente(js, el);
                return;
            } catch (StaleElementReferenceException e) {
                ultimoStale = e;
                sleep(500); // dar tiempo a que el DOM termine de re-renderizarse antes de reintentar
            }
        }
        throw (ultimoStale != null)
                ? ultimoStale
                : new RuntimeException("No se pudo hacer clic tras " + maxIntentos + " intentos");
    }

    public static WebElement esperarClickable(WebDriver driver, By principal, By fallback, int segundos) {
        try {
            return new WebDriverWait(driver, Duration.ofSeconds(segundos))
                    .until(ExpectedConditions.elementToBeClickable(principal));
        } catch (Exception e) {
            return new WebDriverWait(driver, Duration.ofSeconds(segundos))
                    .until(ExpectedConditions.elementToBeClickable(fallback));
        }
    }

    public static WebElement esperarPresencia(WebDriver driver, By principal, By fallback, int segundos) {
        try {
            return new WebDriverWait(driver, Duration.ofSeconds(segundos))
                    .until(ExpectedConditions.presenceOfElementLocated(principal));
        } catch (Exception e) {
            return new WebDriverWait(driver, Duration.ofSeconds(segundos))
                    .until(ExpectedConditions.presenceOfElementLocated(fallback));
        }
    }

    /** Click con 3 estrategias de resiliencia (nativo, JS click, dispatchEvent). */
    public static void clickResiliente(JavascriptExecutor js, WebElement el) {
        try {
            el.click();
        } catch (StaleElementReferenceException stale) {
            throw stale; // propagar: quien llama debe re-localizar el elemento, no reintentar aquí
        } catch (Exception e1) {
            try {
                js.executeScript("arguments[0].click();", el);
            } catch (StaleElementReferenceException stale) {
                throw stale;
            } catch (Exception e2) {
                js.executeScript(
                        "var el=arguments[0];"
                      + "el.dispatchEvent(new MouseEvent('mousedown',{bubbles:true,cancelable:true,view:window}));"
                      + "el.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,cancelable:true,view:window}));"
                      + "el.click();", el);
            }
        }
    }

    /**
     * Espera a que un editGrid específico esté "verdaderamente listo" para interacción:
     * no solo que exista en el DOM, sino que su renderer haya inicializado completamente
     * (tabla visible, sin filas en modo edición inline, botón "Crear" clickeable).
     *
     * Form.io editGrid sufre un glitch ocasional donde la primera carga muestra una fila
     * en modo edición inline Y el diálogo al mismo tiempo (doble-render). Este método
     * detecta ese estado e interviene: espera a que la fila inline desaparezca antes de
     * permitir que el clic en "Crear" se ejecute.
     *
     * @param driver WebDriver
     * @param editGridComponentClass clase CSS del contenedor editGrid (p. ej. "formio-component-novedades_asistencia_movilidad")
     * @param segundos timeout en segundos
     */
    public static void esperarEditGridListo(WebDriver driver, String editGridComponentClass, int segundos) {
        new WebDriverWait(driver, Duration.ofSeconds(segundos)).until(d -> {
            // 1. Contenedor editGrid presente
            java.util.List<WebElement> containers = d.findElements(
                    By.cssSelector(".formio-component." + editGridComponentClass));
            if (containers.isEmpty()) {
                return false;
            }

            WebElement container = containers.get(0);
            try {
                // 2. Tabla presente y visible
                java.util.List<WebElement> tables = container.findElements(By.cssSelector("table.table"));
                if (tables.isEmpty() || !tables.get(0).isDisplayed()) {
                    return false;
                }

                // 3. NO hay filas en modo edición inline (si hay <tr>, no deben tener estado "editing")
                //    Indicadores de edición inline: clase "editing", o presencia de botones Guardar/Cancelar en <tr>
                java.util.List<WebElement> filasConEdicion = container.findElements(
                        By.cssSelector("tbody tr:has(button.btn[title*='Guardar']), tbody tr:has(button.btn[title*='Cancelar'])"));
                if (!filasConEdicion.isEmpty()) {
                    // Hay filas en edición inline; esperar a que desaparezcan
                    return false;
                }

                // 4. Botón "Crear" presente y clickeable
                java.util.List<WebElement> btnCrear = container.findElements(
                        By.xpath(".//button[contains(@class,'btn-primary') and contains(normalize-space(.),'Crear')]"));
                if (btnCrear.isEmpty() || !btnCrear.get(0).isDisplayed()) {
                    return false;
                }

                return true;
            } catch (Exception e) {
                return false;
            }
        });
    }

    /**
     * Localiza el iframe "form_onescript_iframe" (con fallback a cualquier iframe de la página)
     * y se posiciona dentro de él, verificando que el selector `marcador` esté presente.
     * Reintenta durante `segundos` por si el iframe está en medio de una recarga.
     */
    public static void entrarAlFrameConMarcador(WebDriver driver, WebDriverWait wait, By marcador, String nombreLog) {
        boolean encontrado = wait.until(d -> {
            d.switchTo().defaultContent();
            if (!d.findElements(marcador).isEmpty()) {
                return true;
            }
            for (WebElement frame : d.findElements(By.id("form_onescript_iframe"))) {
                try {
                    d.switchTo().frame(frame);
                    if (!d.findElements(marcador).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
                d.switchTo().defaultContent();
            }
            for (WebElement frame : d.findElements(By.tagName("iframe"))) {
                try {
                    d.switchTo().defaultContent();
                    d.switchTo().frame(frame);
                    if (!d.findElements(marcador).isEmpty()) {
                        return true;
                    }
                } catch (Exception ignored) {
                }
            }
            d.switchTo().defaultContent();
            return false;
        });
        if (!encontrado) {
            throw new AssertionError("[" + nombreLog + "] No se encontró el marcador " + marcador
                    + " en la página ni en sus iframes.");
        }
    }

    public static void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
