Feature: Creacion de Expedientes en el sistema de gestion de casos

  @batch1
  Scenario: CASO-01  Autos  Grua  Antioquia  Medellin
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | GRUA     |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And diligenciamos escalamientos sura
    And cambia a estado "Programado"
    And cambia a estado "Aceptado y en desplazamiento"
    And cambia a estado "Concluido"
    And cambia a estado "Finalizado"
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor


  @batch2
  Scenario: Reclamaciones - Creacion de caso de reclamacion 75
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch3
  Scenario: CASO 03 · Autos / Grua · Antioquia – Medellin (hasta Finalizado, sin reingreso de proveedor)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | GRUA     |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And diligenciamos escalamientos sura
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And cambia a estado "Programado"
    And cambia a estado "Aceptado y en desplazamiento"
    And se han creado tareas de monitoreo automáticamente
    And cambia a estado "Concluido"
    And cambia a estado "Finalizado"

  @batch4
  Scenario: Alt 1 - Flujo con Monitoreo primero (antes de Finalización y CNM)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | GRUA     |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And creamos una novedad
    And cambia a estado "Programado"
    And cambia a estado "Aceptado y en desplazamiento"
    And se han creado tareas de monitoreo automáticamente
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And cambia a estado "Concluido"
    And cambia a estado "Finalizado"

  @batch5
  Scenario: Alt 2 - Crear tarea de monitoreo y editarla a estado Cerrada
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | GRUA     |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And cambia a estado "Programado"
    And cambia a estado "Aceptado y en desplazamiento"
    And se han creado tareas de monitoreo automáticamente
    And editamos la primera tarea de monitoreo a estado "Cerrada"
    And cambia a estado "Concluido"
    And cambia a estado "Finalizado"

  @batch6
  Scenario: Alt 3 - Flujo minimalista (solo Estados y Monitoreo, sin otros submódulos)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio | nombre_solicitante       | cedula_solicitante | telefono_1 | placa  |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | GRUA     | Sergio Luis Anaya Romero | 1015411162         | 3103904286 | AVK81H |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And cambia a estado "Programado"
    And cambia a estado "Aceptado y en desplazamiento"
    And se han creado tareas de monitoreo automáticamente
    And creamos una tarea de monitoreo a estado "Pendiente TM"
    And cambia a estado "Concluido"
    And cambia a estado "Finalizado"
