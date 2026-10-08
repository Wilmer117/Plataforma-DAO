# Requisitos: Login y roles

## Objetivo

Permitir que cada usuario ingrese a la plataforma con su cuenta y acceda únicamente a las funciones y datos correspondientes a su rol.

## Roles del MVP

- **Administrador:** gestiona usuarios, droguerías y metas; también tiene las funciones de Central.
- **Gerente:** tiene las funciones de Central y puede consultar su historial.
- **Central:** consulta y administra los pedidos según `CONTEXTO.md`.
- **Droguería:** publica pedidos de su propia droguería y consulta solo sus pedidos.
- **Call Center:** publica pedidos, elige la droguería de recogida y consulta todos los pedidos.
- **Domiciliario:** usa la aplicación Android nativa en Kotlin para gestionar sus entregas.

## Requisitos funcionales

1. Cada usuario debe iniciar sesión con una cuenta individual.
2. La sesión debe identificar el rol del usuario.
3. La plataforma web debe mostrar las funciones permitidas para ese rol.
4. Los permisos deben validarse también al acceder a los datos; ocultar opciones en pantalla no es suficiente.
5. Un usuario de Droguería solo puede consultar los pedidos de su propia droguería.
6. Call Center puede consultar todos los pedidos y elegir la droguería al publicar.
7. Central y Administrador pueden cancelar pedidos.
8. Las acciones y cambios relevantes deben registrar la hora y el usuario, según las reglas del proyecto.
9. El Domiciliario inicia sesión desde la aplicación Android nativa desarrollada en Kotlin.

## Criterios de aceptación

- Un usuario autenticado llega a las funciones correspondientes a su rol.
- Un usuario no puede acceder a funciones o datos que su rol no permite, aunque intente hacerlo directamente.
- Los usuarios de Droguería no pueden ver pedidos de otra droguería.
- La sesión termina al cerrar sesión.
- La app móvil del Domiciliario continúa siendo nativa para Android y está desarrollada en Kotlin.

## Pendiente de definir

- Método de inicio de sesión.
- Quién crea las cuentas y cómo se asignan los roles.
- Recuperación de contraseña.
- Duración de la sesión y comportamiento al expirar.

## Creación y aprobación de cuentas

- El Administrador o Central crea las cuentas de los usuarios de los demás roles y les asigna el rol correspondiente.
- Los domiciliarios pueden registrarse por su cuenta.
- La cuenta del domiciliario queda pendiente de aprobación.
- El Administrador o Central puede aceptar la solicitud del domiciliario.
- El domiciliario no puede usar las funciones de la plataforma hasta que su cuenta sea aceptada.

## Método de acceso

- Los usuarios inician sesión con correo electrónico y contraseña.
- Pueden solicitar la recuperación de contraseña mediante un correo electrónico.
- La cuenta de un domiciliario debe estar aprobada antes de permitirle usar la plataforma.