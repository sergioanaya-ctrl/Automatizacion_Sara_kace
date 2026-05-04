Feature: Apertura de la pagina de casos
  Como equipo de automatizacion
  Quiero abrir la pagina de casos
  Para validar que la URL es accesible

  Scenario: Abrir la URL, loguearse y navegar a agent
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea             | servicio           |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | LINEA EJEMPLO 1   | SERVICIO EJEMPLO 1 |
    Then deberia ver la ruta agent
