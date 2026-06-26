Feature: Creacion de Expedientes en el sistema de gestion de casos

  @batch1
  Scenario: CASO-01  Autos  Grua  Antioquia  Medellin
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | GRUA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS40 PRUEBAS40 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch2
  Scenario: CASO-02 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Bogota D.C. â€“ Bogota D.C.
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS41 PRUEBAS41 | TOMA SERVICIO |
       And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch3
  Scenario: CASO-03 Â· Conductor Elegido / Conductor Elegido Â· Antioquia â€“ Medellin
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS42 PRUEBAS42 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch4
  Scenario: CASO-04 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS43 PRUEBAS43 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch5
  Scenario: CASO-05 Â· Autos / Conductor Elegido Â· Bogota D.C. â€“ Bogota D.C.
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS44 PRUEBAS44 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch6
  Scenario: CASO-06 Â· Autos / Grua Â· Bogota D.C. â€“ Bogota D.C.
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | GRUA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS45 PRUEBAS45 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch7
  Scenario: CASO-07 Â· Autos / Conductor Elegido Â· Bogota D.C. â€“ Bogota D.C.
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS46 PRUEBAS46 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch8
  Scenario: CASO-08 Â· Conductor Elegido / Conductor Elegido Â· Antioquia â€“ Medellin
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS47 PRUEBAS47 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch9
  Scenario: CASO-09 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS48 PRUEBAS48 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch10
  Scenario: CASO-10 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS49 PRUEBAS49 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch11
  Scenario: CASO-11 Â· Autos / Grua Â· Antioquia â€“ Medellin (combo C01)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | GRUA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS50 PRUEBAS50 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch12
  Scenario: CASO-12 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Bogota D.C. â€“ Bogota D.C. (combo C02)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS40 PRUEBAS40 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch13
  Scenario: CASO-13 Â· Conductor Elegido / Conductor Elegido Â· Antioquia â€“ Medellin (combo C03)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS41 PRUEBAS41 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch14
  Scenario: CASO-14 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C04)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS42 PRUEBAS42 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch15
  Scenario: CASO-15 Â· Autos / Conductor Elegido Â· Bogota D.C. â€“ Bogota D.C. (combo C05)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS43 PRUEBAS43 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch16
  Scenario: CASO-16 Â· Autos / Grua Â· Bogota D.C. â€“ Bogota D.C. (combo C06)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | GRUA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS44 PRUEBAS44 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch17
  Scenario: CASO-17 Â· Autos / Conductor Elegido Â· Bogota D.C. â€“ Bogota D.C. (combo C07)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS45 PRUEBAS45 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch18
  Scenario: CASO-18 Â· Conductor Elegido / Conductor Elegido Â· Antioquia â€“ Medellin (combo C08)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS46 PRUEBAS46 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch19
  Scenario: CASO-19 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C09)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS47 PRUEBAS47 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch20
  Scenario: CASO-20 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C10)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS48 PRUEBAS48 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch21
  Scenario: CASO-21 Â· Autos / Grua Â· Antioquia â€“ Medellin (combo C01)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | GRUA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS49 PRUEBAS49 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch22
  Scenario: CASO-22 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Bogota D.C. â€“ Bogota D.C. (combo C02)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS50 PRUEBAS50 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch23
  Scenario: CASO-23 Â· Conductor Elegido / Conductor Elegido Â· Antioquia â€“ Medellin (combo C03)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS40 PRUEBAS40 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch24
  Scenario: CASO-24 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C04)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS41 PRUEBAS41 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch25
  Scenario: CASO-25 Â· Autos / Conductor Elegido Â· Bogota D.C. â€“ Bogota D.C. (combo C05)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS42 PRUEBAS42 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch26
  Scenario: CASO-26 Â· Autos / Grua Â· Bogota D.C. â€“ Bogota D.C. (combo C06)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | GRUA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS43 PRUEBAS43 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch27
  Scenario: CASO-27 Â· Autos / Conductor Elegido Â· Bogota D.C. â€“ Bogota D.C. (combo C07)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS44 PRUEBAS44 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch28
  Scenario: CASO-28 Â· Conductor Elegido / Conductor Elegido Â· Antioquia â€“ Medellin (combo C08)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS45 PRUEBAS45 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch29
  Scenario: CASO-29 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C09)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS46 PRUEBAS46 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch30
  Scenario: CASO-30 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C10)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS47 PRUEBAS47 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch31
  Scenario: CASO-31 Â· Autos / Grua Â· Antioquia â€“ Medellin (combo C01)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | GRUA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS48 PRUEBAS48 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch32
  Scenario: CASO-32 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Bogota D.C. â€“ Bogota D.C. (combo C02)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS49 PRUEBAS49 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch33
  Scenario: CASO-33 Â· Conductor Elegido / Conductor Elegido Â· Antioquia â€“ Medellin (combo C03)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS50 PRUEBAS50 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch34
  Scenario: CASO-34 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C04)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS40 PRUEBAS40 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch35
  Scenario: CASO-35 Â· Autos / Conductor Elegido Â· Bogota D.C. â€“ Bogota D.C. (combo C05)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS41 PRUEBAS41 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch36
  Scenario: CASO-36 Â· Autos / Grua Â· Bogota D.C. â€“ Bogota D.C. (combo C06)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | GRUA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS42 PRUEBAS42 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch37
  Scenario: CASO-37 Â· Autos / Conductor Elegido Â· Bogota D.C. â€“ Bogota D.C. (combo C07)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS43 PRUEBAS43 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch38
  Scenario: CASO-38 Â· Conductor Elegido / Conductor Elegido Â· Antioquia â€“ Medellin (combo C08)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS44 PRUEBAS44 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch39
  Scenario: CASO-39 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C09)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS45 PRUEBAS45 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch40
  Scenario: CASO-40 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C10)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS46 PRUEBAS46 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch41
  Scenario: CASO-41 Â· Autos / Grua Â· Antioquia â€“ Medellin (combo C01)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | GRUA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS47 PRUEBAS47 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch42
  Scenario: CASO-42 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Bogota D.C. â€“ Bogota D.C. (combo C02)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS48 PRUEBAS48 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch43
  Scenario: CASO-43 Â· Conductor Elegido / Conductor Elegido Â· Antioquia â€“ Medellin (combo C03)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS49 PRUEBAS49 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch44
  Scenario: CASO-44 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C04)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS50 PRUEBAS50 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch45
  Scenario: CASO-45 Â· Autos / Conductor Elegido Â· Bogota D.C. â€“ Bogota D.C. (combo C05)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS40 PRUEBAS40 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch46
  Scenario: CASO-46 Â· Autos / Grua Â· Bogota D.C. â€“ Bogota D.C. (combo C06)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | GRUA |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS41 PRUEBAS41 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch47
  Scenario: CASO-47 Â· Autos / Conductor Elegido Â· Bogota D.C. â€“ Bogota D.C. (combo C07)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | BOGOTA D.C. | BOGOTA D.C. | NO | NO | AUTOS | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS42 PRUEBAS42 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch48
  Scenario: CASO-48 Â· Conductor Elegido / Conductor Elegido Â· Antioquia â€“ Medellin (combo C08)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | CONDUCTOR ELEGIDO | CONDUCTOR ELEGIDO |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS43 PRUEBAS43 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch49
  Scenario: CASO-49 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C09)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS44 PRUEBAS44 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch50
  Scenario: CASO-50 Â· Autos / Desplazamiento Por Inmovilizacion Del VH Â· Antioquia â€“ Medellin (combo C10)
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And diligencia caso express completo desde feature
      | departamento_solicita | municipio_solicita | servicios_especiales | gestor_coordinacion | linea | servicio |
      | ANTIOQUIA | MEDELLIN | NO | NO | AUTOS | DESPLAZAMIENTO POR INMOVILIZACION DEL VH |
    And diligenciamos el proveedor
      | Nombre del proveedor | Servicio |
      | PRUEBAS45 PRUEBAS45 | TOMA SERVICIO |
    And creamos una novedad
    And diligenciamos la finalizacion
    And diligenciamos la documentacion cnm
    And transicionamos los estados del caso hasta concluido
    And cerramos sesion del usuario
    And reingresamos como el proveedor asignado
    And buscamos el expediente guardado y abrimos su edicion
    And gestionamos los conceptos del proveedor

  @batch51
  Scenario: Reclamaciones - Creacion de caso de reclamacion 51
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch52
  Scenario: Reclamaciones - Creacion de caso de reclamacion 52
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch53
  Scenario: Reclamaciones - Creacion de caso de reclamacion 53
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch54
  Scenario: Reclamaciones - Creacion de caso de reclamacion 54
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch55
  Scenario: Reclamaciones - Creacion de caso de reclamacion 55
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch56
  Scenario: Reclamaciones - Creacion de caso de reclamacion 56
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch57
  Scenario: Reclamaciones - Creacion de caso de reclamacion 57
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch58
  Scenario: Reclamaciones - Creacion de caso de reclamacion 58
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch59
  Scenario: Reclamaciones - Creacion de caso de reclamacion 59
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch60
  Scenario: Reclamaciones - Creacion de caso de reclamacion 60
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch61
  Scenario: Reclamaciones - Creacion de caso de reclamacion 61
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch62
  Scenario: Reclamaciones - Creacion de caso de reclamacion 62
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch63
  Scenario: Reclamaciones - Creacion de caso de reclamacion 63
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch64
  Scenario: Reclamaciones - Creacion de caso de reclamacion 64
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch65
  Scenario: Reclamaciones - Creacion de caso de reclamacion 65
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch66
  Scenario: Reclamaciones - Creacion de caso de reclamacion 66
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch67
  Scenario: Reclamaciones - Creacion de caso de reclamacion 67
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch68
  Scenario: Reclamaciones - Creacion de caso de reclamacion 68
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch69
  Scenario: Reclamaciones - Creacion de caso de reclamacion 69
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch70
  Scenario: Reclamaciones - Creacion de caso de reclamacion 70
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch71
  Scenario: Reclamaciones - Creacion de caso de reclamacion 71
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch72
  Scenario: Reclamaciones - Creacion de caso de reclamacion 72
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch73
  Scenario: Reclamaciones - Creacion de caso de reclamacion 73
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch74
  Scenario: Reclamaciones - Creacion de caso de reclamacion 74
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion

  @batch75
  Scenario: Reclamaciones - Creacion de caso de reclamacion 75
    Given el actor tiene un navegador disponible
    When abre la pagina de casos
    And realiza login con credenciales
    And navega a agent
    And creamos un caso de reclamaciones
    And gestionamos la reclamacion