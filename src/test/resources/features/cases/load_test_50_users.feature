Feature: Prueba de carga con multiples usuarios
  Como equipo de QA
  Quiero ejecutar pruebas con multiples usuarios en paralelo
  Para validar el comportamiento bajo carga

  # Este feature crea 50 escenarios independientes
  # Cada escenario usara un usuario diferente del pool (BOT01-BOT50)
  # Se ejecutan en paralelo segun la configuracion de maxParallelForks

  Scenario Outline: Test de caso express - Usuario <id>
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea   | servicio   |
      | ANTIOQUIA             | MEDELLIN           | NO                   | NO                  | <linea> | <servicio> |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio      |
      | PROVEEDOR PRUEBA     | TOMA SERVICIO |
    And transicionamos los estados del caso
    Then deberia ver la ruta agent

    Examples:
      | id  | linea             | servicio           |
      | 01  | AUTOS             | PASO DE GASOLINA   |
      | 02  | AUTOS             | PASO DE GASOLINA   |
      | 03  | AUTOS             | PASO DE GASOLINA   |
      | 04  | AUTOS             | PASO DE GASOLINA   |
      | 05  | AUTOS             | PASO DE GASOLINA   |
      | 06  | AUTOS             | PASO DE GASOLINA   |
      | 07  | AUTOS             | PASO DE GASOLINA   |
      | 08  | AUTOS             | PASO DE GASOLINA   |
      | 09  | AUTOS             | PASO DE GASOLINA   |
      | 10  | AUTOS             | PASO DE GASOLINA   |
      | 11  | AUTOS             | PASO DE GASOLINA   |
      | 12  | AUTOS             | PASO DE GASOLINA   |
      | 13  | AUTOS             | PASO DE GASOLINA   |
      | 14  | AUTOS             | PASO DE GASOLINA   |
      | 15  | AUTOS             | PASO DE GASOLINA   |
      | 16  | AUTOS             | PASO DE GASOLINA   |
      | 17  | AUTOS             | PASO DE GASOLINA   |
      | 18  | AUTOS             | PASO DE GASOLINA   |
      | 19  | AUTOS             | PASO DE GASOLINA   |
      | 20  | AUTOS             | PASO DE GASOLINA   |
      | 21  | AUTOS             | PASO DE GASOLINA   |
      | 22  | AUTOS             | PASO DE GASOLINA   |
      | 23  | AUTOS             | PASO DE GASOLINA   |
      | 24  | AUTOS             | PASO DE GASOLINA   |
      | 25  | AUTOS             | PASO DE GASOLINA   |
      | 26  | AUTOS             | PASO DE GASOLINA   |
      | 27  | AUTOS             | PASO DE GASOLINA   |
      | 28  | AUTOS             | PASO DE GASOLINA   |
      | 29  | AUTOS             | PASO DE GASOLINA   |
      | 30  | AUTOS             | PASO DE GASOLINA   |
      | 31  | AUTOS             | PASO DE GASOLINA   |
      | 32  | AUTOS             | PASO DE GASOLINA   |
      | 33  | AUTOS             | PASO DE GASOLINA   |
      | 34  | AUTOS             | PASO DE GASOLINA   |
      | 35  | AUTOS             | PASO DE GASOLINA   |
      | 36  | AUTOS             | PASO DE GASOLINA   |
      | 37  | AUTOS             | PASO DE GASOLINA   |
      | 38  | AUTOS             | PASO DE GASOLINA   |
      | 39  | AUTOS             | PASO DE GASOLINA   |
      | 40  | AUTOS             | PASO DE GASOLINA   |
      | 41  | AUTOS             | PASO DE GASOLINA   |
      | 42  | AUTOS             | PASO DE GASOLINA   |
      | 43  | AUTOS             | PASO DE GASOLINA   |
      | 44  | AUTOS             | PASO DE GASOLINA   |
      | 45  | AUTOS             | PASO DE GASOLINA   |
      | 46  | AUTOS             | PASO DE GASOLINA   |
      | 47  | AUTOS             | PASO DE GASOLINA   |
      | 48  | AUTOS             | PASO DE GASOLINA   |
      | 49  | AUTOS             | PASO DE GASOLINA   |
      | 50  | AUTOS             | PASO DE GASOLINA   |
