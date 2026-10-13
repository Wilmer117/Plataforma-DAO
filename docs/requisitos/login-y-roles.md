# Requisitos: Login y roles

## Objetivo

Permitir que cada usuario ingrese a la plataforma con su cuenta y acceda únicamente a las funciones y datos correspondientes a su rol.

## Roles del MVP

- **Administrador:** gestiona usuarios, droguerías y metas; también tiene las funciones de Central.
- **Central:** consulta y administra los pedidos según `CONTEXTO.md`.
- **Droguería:** publica pedidos de la droguería activa de su jornada. El personal autorizado puede rotar entre cualquier droguería activa.
- **Call Center:** publica pedidos, elige la droguería de recogida y consulta todos los pedidos.
- **Domiciliario:** usa la aplicación Android nativa en Kotlin para gestionar sus entregas.

## Requisitos funcionales

1. Cada usuario debe iniciar sesión con una cuenta individual.
2. La sesión debe identificar el rol del usuario.
3. La plataforma web debe mostrar las funciones permitidas para ese rol.
4. Los permisos deben validarse también al acceder a los datos; ocultar opciones en pantalla no es suficiente.
5. El acceso del personal de Droguería corresponde a la droguería activa elegida para su jornada; la autorización no limita a una empresa ni a una única droguería.
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

- Flujo de invitación o solicitud para empleados de Droguería, Central y Call Center, y quién inicia cada alta.
- Duración de la sesión y comportamiento al expirar.
- Cómo invita la cuenta principal a otro usuario para que establezca su contraseña.

## Creación y aprobación de cuentas

- El Administrador crea las entidades operativas y sus cuentas principales.
- Cada persona tiene su cuenta y credenciales individuales; no se comparten contraseñas.
- Los empleados crean su propia cuenta y luego la cuenta principal de su entidad los autoriza. La autorización de Droguería se concede una vez y no restringe la rotación entre droguerías activas.
- Los domiciliarios pueden registrarse con correo verificado mientras su solicitud queda pendiente.
- Central o Administrador revisan y aprueban la solicitud del domiciliario. Hasta la aprobación, no puede operar.
- La verificación del correo y la aprobación de la solicitud son procesos distintos.
- El método para establecer la contraseña inicial sigue pendiente; consultar [`dudas-y-decisiones.md`](../decisiones/dudas-y-decisiones.md).

## Método de acceso

- Los usuarios inician sesión con correo electrónico y contraseña.
- Pueden solicitar la recuperación de contraseña mediante un correo electrónico.
- La cuenta de un domiciliario debe estar aprobada antes de permitirle usar la plataforma.
- Supabase Auth administra correo, contraseña, verificación y recuperación; no se almacena el correo duplicado ni contraseña en `PERFILES`.
- No está decidido si la cuenta principal recibirá invitación/enlace para definir contraseña u otro flujo de alta. No enviar ni almacenar contraseñas temporales.
