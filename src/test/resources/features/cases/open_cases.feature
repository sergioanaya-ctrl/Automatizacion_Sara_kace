Feature: Apertura de la pagina de casos
  Como equipo de automatizacion
  Quiero abrir la pagina de casos
  Para validar que la URL es accesible

  @batch1
  Scenario: Test Usuario 01
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch2
  Scenario: Test Usuario 02
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch3
  Scenario: Test Usuario 03
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch4
  Scenario: Test Usuario 04
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch5
  Scenario: Test Usuario 05
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch6
  Scenario: Test Usuario 06
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch7
  Scenario: Test Usuario 07
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch8
  Scenario: Test Usuario 08
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch9
  Scenario: Test Usuario 09
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch10
  Scenario: Test Usuario 10
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch11
  Scenario: Test Usuario 11
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch12
  Scenario: Test Usuario 12
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch13
  Scenario: Test Usuario 13
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch14
  Scenario: Test Usuario 14
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch15
  Scenario: Test Usuario 15
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch16
  Scenario: Test Usuario 16
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch17
  Scenario: Test Usuario 17
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch18
  Scenario: Test Usuario 18
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch19
  Scenario: Test Usuario 19
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch20
  Scenario: Test Usuario 20
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch21
  Scenario: Test Usuario 21
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch22
  Scenario: Test Usuario 22
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch23
  Scenario: Test Usuario 23
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch24
  Scenario: Test Usuario 24
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch25
  Scenario: Test Usuario 25
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch26
  Scenario: Test Usuario 26
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch27
  Scenario: Test Usuario 27
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch28
  Scenario: Test Usuario 28
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch29
  Scenario: Test Usuario 29
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch30
  Scenario: Test Usuario 30
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch31
  Scenario: Test Usuario 31
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch32
  Scenario: Test Usuario 32
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch33
  Scenario: Test Usuario 33
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch34
  Scenario: Test Usuario 34
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch35
  Scenario: Test Usuario 35
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch36
  Scenario: Test Usuario 36
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch37
  Scenario: Test Usuario 37
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch38
  Scenario: Test Usuario 38
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch39
  Scenario: Test Usuario 39
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch40
  Scenario: Test Usuario 40
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch41
  Scenario: Test Usuario 41
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch42
  Scenario: Test Usuario 42
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch43
  Scenario: Test Usuario 43
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch44
  Scenario: Test Usuario 44
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch45
  Scenario: Test Usuario 45
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch46
  Scenario: Test Usuario 46
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch47
  Scenario: Test Usuario 47
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch48
  Scenario: Test Usuario 48
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch49
  Scenario: Test Usuario 49
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

  @batch50
  Scenario: Test Usuario 50
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio         |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | AUTOS | PASO DE GASOLINA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent
