Feature: Creacion de Expedientes en el sistema de gestion de casos
  @batch1
  Scenario: Test Usuario 01 - ANTIOQUIA - MEDELLIN - AUTOS - PASO DE GASOLINA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio          |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch2
  Scenario: Test Usuario 02 - BOGOTA - BOGOTA - AUTOS - ABOGADO EN SITIO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | BOGOTA                | BOGOTA             | NO                   | NO                  | AUTOS | ABOGADO EN SITIO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch3
  Scenario: Test Usuario 03 - VALLE DEL CAUCA - CALI - AUTOS - MECANICA BASICA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | VALLE DEL CAUCA       | CALI               | NO                   | NO                  | AUTOS | MECANICA BASICA  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch4
  Scenario: Test Usuario 04 - ATLANTICO - BARRANQUILLA - AUTOS - FRENOS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ATLANTICO             | BARRANQUILLA       | NO                   | NO                  | AUTOS | FRENOS   |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch5
  Scenario: Test Usuario 05 - CUNDINAMARCA - SOACHA - AUTOS - AMBULANCIA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio     |
      | CUNDINAMARCA          | SOACHA             | NO                   | NO                  | AUTOS | AMBULANCIA   |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch6
  Scenario: Test Usuario 06 - SANTANDER - BUCARAMANGA - AUTOS - GRUA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | SANTANDER             | BUCARAMANGA        | NO                   | NO                  | AUTOS | GRUA     |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch7
  Scenario: Test Usuario 07 - NORTE DE SANTANDER - CUCUTA - AUTOS - CAMBIO LLANTAS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio        |
      | NORTE DE SANTANDER    | CUCUTA             | NO                   | NO                  | AUTOS | CAMBIO LLANTAS  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch8
  Scenario: Test Usuario 08 - MAGDALENA - SANTA MARTA - AUTOS - CERRAJERO AUTOS COMPLEJIDAD BAJA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio                            |
      | MAGDALENA             | SANTA MARTA        | NO                   | NO                  | AUTOS | CERRAJERO AUTOS COMPLEJIDAD BAJA    |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch9
  Scenario: Test Usuario 09 - BOLIVAR - CARTAGENA - AUTOS - DESPLAZAMIENTO POR HORAS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio                 |
      | BOLIVAR               | CARTAGENA          | NO                   | NO                  | AUTOS | DESPLAZAMIENTO POR HORAS |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch10
  Scenario: Test Usuario 10 - NARIÑO - PASTO - AUTOS - FACILITADOR VIRTUAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio              |
      | NARIÑO                | PASTO              | NO                   | NO                  | AUTOS | FACILITADOR VIRTUAL   |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch11
  Scenario: Test Usuario 11 - CAUCA - POPAYAN - AUTOS - ABOGADO VIRTUAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | CAUCA                 | POPAYAN            | NO                   | NO                  | AUTOS | ABOGADO VIRTUAL  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch12
  Scenario: Test Usuario 12 - QUINDIO - ARMENIA - AUTOS - ORIENTACION JURIDICA TELEFONICA AUTOS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio                              |
      | QUINDIO               | ARMENIA            | NO                   | NO                  | AUTOS | ORIENTACION JURIDICA TELEFONICA AUTOS |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch13
  Scenario: Test Usuario 13 - RISARALDA - PEREIRA - AUTOS - CONDUCTOR PROFESIONAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio               |
      | RISARALDA             | PEREIRA            | NO                   | NO                  | AUTOS | CONDUCTOR PROFESIONAL  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch14
  Scenario: Test Usuario 14 - TOLIMA - IBAGUE - AUTOS - CONDUCTOR FAMILIAR
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio            |
      | TOLIMA                | IBAGUE             | NO                   | NO                  | AUTOS | CONDUCTOR FAMILIAR  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch15
  Scenario: Test Usuario 15 - META - VILLAVICENCIO - AUTOS - ESTANCIA CONDUCTOR POR HURTO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio                        |
      | META                  | VILLAVICENCIO      | NO                   | NO                  | AUTOS | ESTANCIA CONDUCTOR POR HURTO    |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch16
  Scenario: Test Usuario 16 - SUCRE - SINCELEJO - AUTOS - DESPLAZAMIENTO VIAJERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio                |
      | SUCRE                 | SINCELEJO          | NO                   | NO                  | AUTOS | DESPLAZAMIENTO VIAJERO  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch17
  Scenario: Test Usuario 17 - CORDOBA - MONTERIA - AUTOS - HOSPEDAJE VIAJERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio            |
      | CORDOBA               | MONTERIA           | NO                   | NO                  | AUTOS | HOSPEDAJE VIAJERO   |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch18
  Scenario: Test Usuario 18 - CESAR - VALLEDUPAR - AUTOS - TRASLADO VEHICULO DE REEMPLAZO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio                        |
      | CESAR                 | VALLEDUPAR         | NO                   | NO                  | AUTOS | TRASLADO VEHICULO DE REEMPLAZO  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch19
  Scenario: Test Usuario 19 - GUAJIRA - RIOHACHA - AUTOS - RESCATE PARQUEADERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio              |
      | GUAJIRA               | RIOHACHA           | NO                   | NO                  | AUTOS | RESCATE PARQUEADERO   |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch20
  Scenario: Test Usuario 20 - ARAUCA - ARAUCA - AUTOS - PARQUEADERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio    |
      | ARAUCA                | ARAUCA             | NO                   | NO                  | AUTOS | PARQUEADERO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch21
  Scenario: Test Usuario 21 - CASANARE - YOPAL - AUTOS - DIAGNOSTICO VEHICULO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio              |
      | CASANARE              | YOPAL              | NO                   | NO                  | AUTOS | DIAGNOSTICO VEHICULO  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch22
  Scenario: Test Usuario 22 - VICHADA - PUERTO CARREÑO - AUTOS - CAMBIO DE BATERIA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio           |
      | VICHADA               | PUERTO CARREÑO     | NO                   | NO                  | AUTOS | CAMBIO DE BATERIA  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch23
  Scenario: Test Usuario 23 - GUAINIA - INIRIDA - AUTOS - CAMBIO DE DISPOSITIVO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio               |
      | GUAINIA               | INIRIDA            | NO                   | NO                  | AUTOS | CAMBIO DE DISPOSITIVO  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch24
  Scenario: Test Usuario 24 - VAUPÉS - MITÚ - AUTOS - INSTALACION
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio    |
      | VAUPÉS                | MITÚ               | NO                   | NO                  | AUTOS | INSTALACION |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch25
  Scenario: Test Usuario 25 - AMAZONAS - LETICIA - AUTOS - MANTENIMIENTO PREVENTIVO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio                   |
      | AMAZONAS              | LETICIA            | NO                   | NO                  | AUTOS | MANTENIMIENTO PREVENTIVO   |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch26
  Scenario: Test Usuario 26 - PUTUMAYO - MOCOA - HOGARES - ATENCION VIRTUAL HOGAR
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio                  |
      | PUTUMAYO              | MOCOA              | NO                   | NO                  | HOGARES | ATENCION VIRTUAL HOGAR    |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch27
  Scenario: Test Usuario 27 - ANTIOQUIA - ENVIGADO - HOGARES - ABOGADO EN SITIO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio         |
      | ANTIOQUIA             | ENVIGADO           | NO                   | NO                  | HOGARES | ABOGADO EN SITIO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch28
  Scenario: Test Usuario 28 - BOGOTA - SOACHA - HOGARES - ELECTRICISTA
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio    |
      | BOGOTA                | SOACHA             | NO                   | NO                  | HOGARES | ELECTRICISTA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch29
  Scenario: Test Usuario 29 - VALLE DEL CAUCA - PALMIRA - HOGARES - PLOMERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio |
      | VALLE DEL CAUCA       | PALMIRA            | NO                   | NO                  | HOGARES | PLOMERO  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch30
  Scenario: Test Usuario 30 - ATLANTICO - SOLEDAD - HOGARES - CERRAJERO HO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio    |
      | ATLANTICO             | SOLEDAD            | NO                   | NO                  | HOGARES | CERRAJERO HO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch31
  Scenario: Test Usuario 31 - CUNDINAMARCA - ZIPAQUIRA - HOGARES - VIDRIERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio |
      | CUNDINAMARCA          | ZIPAQUIRA          | NO                   | NO                  | HOGARES | VIDRIERO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch32
  Scenario: Test Usuario 32 - SANTANDER - FLORIDABLANCA - HOGARES - RETIRO DE ESCOMBROS
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio                |
      | SANTANDER             | FLORIDABLANCA      | NO                   | NO                  | HOGARES | RETIRO DE ESCOMBROS     |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch33
  Scenario: Test Usuario 33 - NORTE DE SANTANDER - OCAÑA - HOGARES - DESAGUE POR INUNDACION
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio                    |
      | NORTE DE SANTANDER    | OCAÑA              | NO                   | NO                  | HOGARES | DESAGUE POR INUNDACION      |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch34
  Scenario: Test Usuario 34 - MAGDALENA - CIÉNAGA - HOGARES - ASESORIA JURIDICA PRESENCIAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio                        |
      | MAGDALENA             | CIÉNAGA            | NO                   | NO                  | HOGARES | ASESORIA JURIDICA PRESENCIAL    |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch35
  Scenario: Test Usuario 35 - BOLIVAR - TURBACO - HOGARES - ORIENTACION DIGITAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio             |
      | BOLIVAR               | TURBACO            | NO                   | NO                  | HOGARES | ORIENTACION DIGITAL  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch36
  Scenario: Test Usuario 36 - NARIÑO - IPIALES - HOGARES - FACILITADOR VIRTUAL
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio              |
      | NARIÑO                | IPIALES            | NO                   | NO                  | HOGARES | FACILITADOR VIRTUAL   |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch37
  Scenario: Test Usuario 37 - CAUCA - SANTANDER DE QUILICHAO - HOGARES - VIGILANTE
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio   |
      | CAUCA                 | SANTANDER DE QUILICHAO | NO               | NO                  | HOGARES | VIGILANTE  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch38
  Scenario: Test Usuario 38 - QUINDIO - CALARCA - HOGARES - VIGILANTE SP
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio     |
      | QUINDIO               | CALARCA            | NO                   | NO                  | HOGARES | VIGILANTE SP |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch39
  Scenario: Test Usuario 39 - RISARALDA - DOSQUEBRADAS - HOGARES - HOSPEDAJE VIAJERO
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio            |
      | RISARALDA             | DOSQUEBRADAS       | NO                   | NO                  | HOGARES | HOSPEDAJE VIAJERO   |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

  @batch40
  Scenario: Test Usuario 40 - TOLIMA - MELGAR - HOGARES - TRASLADO DE BIENES
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea  | servicio            |
      | TOLIMA                | MELGAR             | NO                   | NO                  | HOGARES | TRASLADO DE BIENES  |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso

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

