# Impact Analysis: Sara3 Test Automation Flows

## Executive Summary
- **Single Feature File**: `open_cases.feature` with 76+ scenarios
- **Two Main Workflows**: Caso Express (CASO-01 to CASO-50, CASO-76) + Reclamaciones (Batch 51-75)
- **Step Definition**: `CasesStepDefinitions.java` orchestrates all steps

---

## Feature Steps → Implementing Tasks Mapping

### Common Steps (Both Workflows)

| Feature Step | Step Definition | Implementing Task | Used In |
|---|---|---|---|
| `el actor tiene un navegador disponible` | `elActorTieneUnNavegadorDisponible()` | `BrowseTheWeb.with(browser)` [Serenity built-in] | All scenarios |
| `abre la pagina de casos` | `abreLaPaginaDeCasos()` | `OpenCasesPage.now()` | All 76+ scenarios |
| `realiza login con credenciales` | `realizaLoginConCredenciales()` | `LoginWithCognito.with(user, pass)` | All 76+ scenarios |
| `navega a agent` | `navegaAAgent()` | `GoToAgentPage.now()` | All 76+ scenarios |
| `cerramos sesion del usuario` | `cerramosSesionDelUsuario()` | `LogoutFromUserMenu.now()` | CASO-01-50, CASO-76 only (Caso Express) |
| `reingresamos como el proveedor asignado` | `reingresamosComoProveedor()` | `LoginWithCognito.with()` + `GoToAgentPage.sinEsperarCasoExpress()` | CASO-01-50, CASO-76 (Caso Express) |
| `buscamos el expediente guardado y abrimos su edicion` | `buscamosElExpedienteGuardadoYAbrimosSuEdicion()` | `BuscarExpediente.now()` | CASO-01-50, CASO-76 (Caso Express) |

---

### Caso Express Workflow (CASO-01 to CASO-50, CASO-76)

**Scenario Pattern**:
```
Given el actor tiene un navegador disponible
When abre la pagina de casos
And realiza login con credenciales
And navega a agent
And diligencia caso express completo desde feature        ← **MAIN STEP**
And diligenciamos el proveedor
And creamos una novedad
And diligenciamos la finalizacion
And diligenciamos la documentacion cnm
And transicionamos los estados del caso hasta concluido
And cerramos sesion del usuario
And reingresamos como el proveedor asignado
And buscamos el expediente guardado y abrimos su edicion
And gestionamos los conceptos del proveedor
```

| Feature Step | Implementing Task | Lines in CasesStepDefinitions | Notes |
|---|---|---|---|
| `diligencia caso express completo desde feature` | `ClickCasoExpress.withManualLists(...)` | 179-184 | **OLD APPROACH** - calls `FillCasoExpressFormInOrder` |
| `diligenciamos el proveedor` | `DiligenciarProveedorGestion.conDatos(...)` | 188-206 | Critical: manages provider assignment |
| `creamos una novedad` | `CrearNovedadProveedor.now()` | 208-212 | Handles news/novelty creation |
| `diligenciamos la finalizacion` | `CrearRegistroEnTab.en("#finalizacion", ...)` | 214-218 | Generic task for creating form records |
| `diligenciamos la documentacion cnm` | `CrearRegistroEnTab.en("#documentacionCnm", ...)` | 220-224 | Generic task for creating form records |
| `transicionamos los estados del caso hasta concluido` | `TransicionarEstadosCaso.hastaConcluido()` | 254-258 | Case state transition logic |
| `gestionamos los conceptos del proveedor` | `GestionConceptosProveedor.now()` | 294-298 | Provider concepts management |

---

### Reclamaciones Workflow (Batch 51-75)

**Scenario Pattern**:
```
Given el actor tiene un navegador disponible
When abre la pagina de casos
And realiza login con credenciales
And navega a agent
And creamos un caso de reclamaciones              ← **MAIN STEP**
And gestionamos la reclamacion
```

| Feature Step | Implementing Task | Lines in CasesStepDefinitions | Notes |
|---|---|---|---|
| `creamos un caso de reclamaciones` | `CrearCasoReclamaciones.now()` | 282-286 | Independent workflow for claims |
| `gestionamos la reclamacion` | `GestionarReclamacion.now()` | 288-292 | Claims management logic |

---

## Task Dependency Analysis

### Tasks Used in MULTIPLE Workflows ✅ PRESERVE
1. **`OpenCasesPage.now()`** - Used by: Caso Express, Reclamaciones
2. **`LoginWithCognito.with()`** - Used by: Caso Express, Reclamaciones
3. **`GoToAgentPage.now()`** - Used by: Caso Express, Reclamaciones
4. **`LogoutFromUserMenu.now()`** - Used by: Caso Express, (Reclamaciones does NOT logout)
5. **`BuscarExpediente.now()`** - Used by: Caso Express, (Reclamaciones does NOT search)
6. **`GestionConceptosProveedor.now()`** - Used by: Caso Express ONLY (but critical)

### Tasks Used in SINGLE Workflow ✅ PRESERVE (Critical)
1. **`ClickCasoExpress.withManualLists()`** - Caso Express workflow ONLY
   - ⚠️ OLD IMPLEMENTATION (monolithic)
   - Currently used by: line 169-176 in CasesStepDefinitions
   - Contains internal calls to: `SwitchToOneScriptIframe`, `FillCasoExpressFormInOrder`
   - **Status**: Should be replaced with new modular approach `CrearCasoExpressAsistencia`

2. **`DiligenciarProveedorGestion.conDatos()`** - Caso Express workflow ONLY
   - Critical for provider assignment and management

3. **`CrearNovedadProveedor.now()`** - Caso Express workflow ONLY
   - Critical for novelty/news creation

4. **`CrearRegistroEnTab.en()`** - Caso Express workflow ONLY (called twice)
   - Finalization: `CrearRegistroEnTab.en("#finalizacion", ...)`
   - CNM Documentation: `CrearRegistroEnTab.en("#documentacionCnm", ...)`

5. **`TransicionarEstadosCaso.hastaConcluido()`** - Caso Express workflow ONLY
   - Case state transitions

6. **`CrearCasoReclamaciones.now()`** - Reclamaciones workflow ONLY
   - Independent claims case creation

7. **`GestionarReclamacion.now()`** - Reclamaciones workflow ONLY
   - Claims management

---

## Sub-Interactions (Used by Tasks)

### Sub-Interactions Used by OLD Caso Express Path
| Sub-Interaction | Used By | Status | Notes |
|---|---|---|---|
| `SwitchToOneScriptIframe` | `ClickCasoExpress` | **OLD** | Will be replaced by `EntrarAlIframeFormulario` |
| `FillCasoExpressFormInOrder` | `ClickCasoExpress` | **OLD MONOLITHIC** | Fills entire form in one action |

### New Modular Sub-Interactions (Created in Previous Conversation)
| Sub-Interaction | Purpose | Used In | Status |
|---|---|---|---|
| `EntrarAlIframeFormulario` | Switch driver context to iframe | `CrearCasoExpressAsistencia` | ✅ NEW |
| `HabilitarFormularioCasoExpress` | Enable form editing (read-only → editable) | `CrearCasoExpressAsistencia` | ✅ NEW |
| `RellenarCampoTexto` | Fill text fields (input/textarea) | Generic, used by any Task | ✅ NEW |
| `SeleccionarOpcionCombo` | Select combo option (with cascading support) | Generic, used by any Task | ✅ NEW |
| `GuardarFormularioCasoExpress` | Save form and exit iframe | `CrearCasoExpressAsistencia` | ✅ NEW |

---

## New Modular Tasks (Created in Previous Conversation)

| New Task | Purpose | Status | Integration |
|---|---|---|---|
| `AbrirMenuCasoExpress` | Open "Caso Express" menu | ✅ NEW | Not yet integrated into step definitions |
| `SeleccionarFormularioAsistencia` | Select "Formulario Creación de Casos (ASISTENCIA)" | ✅ NEW | Not yet integrated into step definitions |
| `CrearCasoExpressAsistencia` | **MAIN ORCHESTRATOR** - complete Caso Express flow | ✅ NEW | **Should replace `ClickCasoExpress`** |

---

## Refactoring Status

### ✅ Complete (from Previous Conversation)
- New modular Tasks/Interactions created
- New Page Object `CasoExpressPage` with localizadores
- Screenplay Pattern properly applied
- Comprehensive documentation added
- Docker configuration for Spanish locale

### ⏳ Pending (Current Work)
- **Update CasesStepDefinitions.java** to use `CrearCasoExpressAsistencia` instead of `ClickCasoExpress`
  - Line 179-184 needs to be changed:
    - FROM: `ClickCasoExpress.withManualLists(departamento, municipio, ...)`
    - TO: `CrearCasoExpressAsistencia.con(nombreSolicitante, cedulaSolicitante, email, telefono, descripcion, departamento, municipio, linea, servicio, gestor)`
  - Note: Will need to extract actual values from the provided DataTable (currently passes raw department/municipality/etc.)

### 🗑️ Can Be Deprecated Later (After Verification)
Once the new approach is verified to work:
1. `ClickCasoExpress.java` - Mark as @Deprecated
2. `FillCasoExpressFormInOrder.java` - Mark as @Deprecated
3. `SwitchToOneScriptIframe.java` - Mark as @Deprecated

---

## Summary of Safe Changes

### SAFE TO MODIFY (No impact on other flows)
- **CasesStepDefinitions.java** - Update step "diligencia caso express completo desde feature" to use new approach
- **ClickCasoExpress.java** - Mark as deprecated
- **FillCasoExpressFormInOrder.java** - Mark as deprecated
- **SwitchToOneScriptIframe.java** - Mark as deprecated

### MUST NOT MODIFY (Critical to multiple flows)
- `OpenCasesPage.now()` 
- `LoginWithCognito.with()`
- `GoToAgentPage.now()`
- `LogoutFromUserMenu.now()`
- `BuscarExpediente.now()`
- `DiligenciarProveedorGestion.conDatos()`
- `CrearNovedadProveedor.now()`
- `CrearRegistroEnTab.en()`
- `TransicionarEstadosCaso.hastaConcluido()`
- `GestionConceptosProveedor.now()`
- `CrearCasoReclamaciones.now()`
- `GestionarReclamacion.now()`

---

## CasesRunner Files Status

From git status in previous context:
- **Deleted in previous conversation**: CasesRunner21-50 (20 runners deleted)
- **Kept**: CasesRunner01-20 (still active)
- **Purpose**: Each runner is a test execution configuration for parallel batches

All deletions were safe because the actual test execution is controlled by the Cucumber feature file, not individual runner classes.

---

## Next Steps

1. ✅ **Verify new modular approach works** - Test with one scenario from CASO-01
2. ⏳ **Update CasesStepDefinitions** - Replace ClickCasoExpress call with CrearCasoExpressAsistencia
3. ⏳ **Test full Caso Express flow** - Run CASO-01 to CASO-50 with new approach
4. ⏳ **Verify Reclamaciones still works** - Batch 51-75 should not be affected
5. ✅ **Mark old code as deprecated** - Add @Deprecated annotation to old Tasks
6. 🗑️ **Delete old code** - After production verification (future PR)

