Feature: Apertura de la pagina de casos
  Como equipo de automatizacion
  Quiero abrir la pagina de casos con multiples departamentos y municipios
  Para validar que funciona en toda Colombia

  @batch1
  Scenario: Test Usuario 01 - ANTIOQUIA - MEDELLIN - AUTOS - PASO DE GASOLINA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea             | servicio          |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch2
  Scenario: Test Usuario 02 - BOGOTA - BOGOTA - AUTOS - ABOGADO EN SITIO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch3
  Scenario: Test Usuario 03 - VALLE DEL CAUCA - CALI - AUTOS - MECANICA BASICA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch4
  Scenario: Test Usuario 04 - ATLANTICO - BARRANQUILLA - AUTOS - FRENOS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch5
  Scenario: Test Usuario 05 - CUNDINAMARCA - SOACHA - AUTOS - AMBULANCIA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch6
  Scenario: Test Usuario 06 - SANTANDER - BUCARAMANGA - AUTOS - GRUA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch7
  Scenario: Test Usuario 07 - NORTE DE SANTANDER - CUCUTA - AUTOS - CAMBIO LLANTAS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch8
  Scenario: Test Usuario 08 - MAGDALENA - SANTA MARTA - AUTOS - CERRAJERO AUTOS COMPLEJIDAD BAJA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch9
  Scenario: Test Usuario 09 - BOLIVAR - CARTAGENA - AUTOS - DESPLAZAMIENTO POR HORAS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch10
  Scenario: Test Usuario 10 - NARIÑO - PASTO - AUTOS - FACILITADOR VIRTUAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch11
  Scenario: Test Usuario 11 - CAUCA - POPAYAN - AUTOS - ABOGADO VIRTUAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch12
  Scenario: Test Usuario 12 - QUINDIO - ARMENIA - AUTOS - ORIENTACION JURIDICA TELEFONICA AUTOS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch13
  Scenario: Test Usuario 13 - RISARALDA - PEREIRA - AUTOS - CONDUCTOR PROFESIONAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch14
  Scenario: Test Usuario 14 - TOLIMA - IBAGUE - AUTOS - CONDUCTOR FAMILIAR
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch15
  Scenario: Test Usuario 15 - META - VILLAVICENCIO - AUTOS - ESTANCIA CONDUCTOR POR HURTO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch16
  Scenario: Test Usuario 16 - SUCRE - SINCELEJO - AUTOS - DESPLAZAMIENTO VIAJERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch17
  Scenario: Test Usuario 17 - CORDOBA - MONTERIA - AUTOS - HOSPEDAJE VIAJERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch18
  Scenario: Test Usuario 18 - CESAR - VALLEDUPAR - AUTOS - TRASLADO VEHICULO DE REEMPLAZO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch19
  Scenario: Test Usuario 19 - GUAJIRA - RIOHACHA - AUTOS - RESCATE PARQUEADERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch20
  Scenario: Test Usuario 20 - ARAUCA - ARAUCA - AUTOS - PARQUEADERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch21
  Scenario: Test Usuario 21 - CASANARE - YOPAL - AUTOS - DIAGNOSTICO VEHICULO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch22
  Scenario: Test Usuario 22 - VICHADA - PUERTO CARREÑO - AUTOS - CAMBIO DE BATERIA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch23
  Scenario: Test Usuario 23 - GUAINIA - INIRIDA - AUTOS - CAMBIO DE DISPOSITIVO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch24
  Scenario: Test Usuario 24 - VAUPÉS - MITÚ - AUTOS - INSTALACION
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch25
  Scenario: Test Usuario 25 - AMAZONAS - LETICIA - AUTOS - MANTENIMIENTO PREVENTIVO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch26
  Scenario: Test Usuario 26 - PUTUMAYO - MOCOA - HOGARES - ATENCION VIRTUAL HOGAR
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch27
  Scenario: Test Usuario 27 - ANTIOQUIA - ENVIGADO - HOGARES - ABOGADO EN SITIO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch28
  Scenario: Test Usuario 28 - BOGOTA - SOACHA - HOGARES - ELECTRICISTA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch29
  Scenario: Test Usuario 29 - VALLE DEL CAUCA - PALMIRA - HOGARES - PLOMERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch30
  Scenario: Test Usuario 30 - ATLANTICO - SOLEDAD - HOGARES - CERRAJERO HO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch31
  Scenario: Test Usuario 31 - CUNDINAMARCA - ZIPAQUIRA - HOGARES - VIDRIERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch32
  Scenario: Test Usuario 32 - SANTANDER - FLORIDABLANCA - HOGARES - RETIRO DE ESCOMBROS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch33
  Scenario: Test Usuario 33 - NORTE DE SANTANDER - OCAÑA - HOGARES - DESAGUE POR INUNDACION
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch34
  Scenario: Test Usuario 34 - MAGDALENA - CIÉNAGA - HOGARES - ASESORIA JURIDICA PRESENCIAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch35
  Scenario: Test Usuario 35 - BOLIVAR - TURBACO - HOGARES - ORIENTACION DIGITAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch36
  Scenario: Test Usuario 36 - NARIÑO - IPIALES - HOGARES - FACILITADOR VIRTUAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch37
  Scenario: Test Usuario 37 - CAUCA - SANTANDER DE QUILICHAO - HOGARES - VIGILANTE
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch38
  Scenario: Test Usuario 38 - QUINDIO - CALARCA - HOGARES - VIGILANTE SP
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch39
  Scenario: Test Usuario 39 - RISARALDA - DOSQUEBRADAS - HOGARES - HOSPEDAJE VIAJERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch40
  Scenario: Test Usuario 40 - TOLIMA - MELGAR - HOGARES - TRASLADO DE BIENES
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch41
  Scenario: Test Usuario 41 - META - ACACIAS - HOGARES - SECADO DE ALFOMBRAS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch42
  Scenario: Test Usuario 42 - SUCRE - COLOSÓ - HOGARES - SERVICIOS EXEQUIAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch43
  Scenario: Test Usuario 43 - CORDOBA - LORICA - HOGARES - GASTOS DE MUDANZA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch44
  Scenario: Test Usuario 44 - CESAR - CODAZZI - HOGARES - SEGUIMIENTO A LA REPARACION
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch45
  Scenario: Test Usuario 45 - GUAJIRA - MAICAO - HOGARES - REVISION Y REDACCION DE CONTRATOS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch46
  Scenario: Test Usuario 46 - ARAUCA - FORTUL - HOGARES - ASESORIA PSICOLOGICA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch47
  Scenario: Test Usuario 47 - CASANARE - AGUAZUL - HOGARES - CONSEJERIA FAMILIAR VIRTUAL O TELEFONICO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch48
  Scenario: Test Usuario 48 - VICHADA - LA PRIMAVERA - HOGARES - ORIENTACION JURIDICA TELEFONICA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch49
  Scenario: Test Usuario 49 - GUAINIA - SAN FERNANDO DE ATABAPO - HOGARES - ORIENTACION MEDICA TELEFONICA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch50
  Scenario: Test Usuario 50 - VAUPÉS - CARURU - HOGARES - PLAN DE ACCION
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | AMAZONAS              | ARARA              | NO                   | NO                  | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent
