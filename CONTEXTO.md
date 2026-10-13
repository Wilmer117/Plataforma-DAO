# Contexto del proyecto — Plataforma de Gestión de Domicilios

## Propósito

Conectar droguerías, Call Center, Central y domiciliarios para coordinar pedidos en tiempo real.

- Web: Administrador, Central, Call Center y Droguería.
- App del Domiciliario: Android nativa con Kotlin.
- Stack: Next.js App Router, TypeScript, Tailwind CSS, Supabase (PostgreSQL, Auth, Realtime y RLS), Android Kotlin y Vercel.

## Roles y cuentas

Los roles definidos para el modelo actual son Administrador, Central, Call Center, Droguería y Domiciliario. Cada perfil tiene un único rol. Supabase Auth administra correo, contraseña y verificación; `PERFILES.id` es el mismo UUID que `auth.users.id`. No se duplica correo ni contraseña en la tabla de perfiles.

La información del perfil propio incluye nombre completo, teléfono, dirección, ciudad, rol y estado de cuenta. El correo debe ser válido y verificado en Auth. Las personas tienen sus propias cuentas; no se comparten credenciales.

El Administrador crea entidades operativas y sus cuentas principales. Las cuentas principales también pueden realizar las funciones operativas de su rol y administrar las autorizaciones de su personal. Los perfiles `PENDIENTE` y `ACTIVA` están definidos para el flujo de alta; estados adicionales como bloqueado o suspendido requieren decisión. El rechazo se registra en la solicitud correspondiente, no como estado del perfil.

### Autorizaciones y jornada

- Un empleado de droguería recibe autorización una vez. Después puede trabajar en cualquier droguería activa registrada, sin limitarse a una empresa.
- Al iniciar jornada, el empleado elige la droguería activa donde trabajará. La elección se conserva en la jornada y sirve para atribuir sus acciones.
- `EMPRESAS` y `empresa_id` preparan una ampliación futura. No restringen ahora rotación, selección de droguería ni recogida.
- Domiciliarios pueden registrarse con correo verificado mientras su solicitud está pendiente. No pueden operar hasta que Central o Administrador la apruebe. La verificación del correo y la aprobación son procesos distintos.
- Se identifica una cuenta principal por entidad mediante `AUTORIZACIONES.es_principal`.

## Pedidos y operación

Call Center crea pedidos y elige la droguería de recogida. Droguería crea pedidos asociados a la entidad elegida para su jornada. Se conservan entidad de origen, droguería de recogida, barrio, dirección, estado, modalidad y marcas de tiempo.

Estados del pedido: `PENDIENTE`, `ACEPTADO`, `EN_ENTREGA`, `ENTREGADO` y `CANCELADO`. La demora es una condición calculada a partir de `disponible_desde`, no un estado. La modalidad es un dato aparte: `INTERNA` o `EXTERNA`. Un pedido externo es coordinado por Central con otra empresa, fuera de la aplicación o de sus domiciliarios; no es un estado.

El domiciliario acepta el pedido, recoge con un código que no se expone antes de la validación de la droguería y marca la entrega. Si libera antes de recoger, el pedido vuelve a estar disponible para otros domiciliarios y su reloj se reinicia. Si ya recogió el paquete, contacta a Central; no se libera automáticamente. El domiciliario puede solicitar cancelación, pero no cancelarla directamente. Droguería revisa solicitudes y Central puede cancelar directamente, dejando constancia.

Cada asignación queda conservada con aceptaciones, liberaciones, asignador o reasignador y tiempos. Puede haber varios intentos durante el ciclo de un pedido.

## Tiempo, historial y notificaciones

El reloj crítico parte de `disponible_desde`: comienza al crear el pedido y se reinicia cuando una liberación lo vuelve a ofrecer. A los diez minutos sin asignación se marca crítico y se avisa a Central. El historial debe permitir reconstruir cambios, asignaciones y eventos.

El historial es de solo inserción: guarda actor, entidad activa cuando corresponda, acción, estados anterior y nuevo, motivo y hora. Las notificaciones se pueden vincular a un pedido o a una solicitud de domiciliario; la relación con el pedido puede ser nula.

## Entregas externas, devoluciones y anexos

Central registra entregas de terceros con `modalidad_entrega = EXTERNA`, sus datos y quién la coordinó. Al confirmar la llegada al cliente, el pedido pasa a entregado. La entrega externa se vincula al pedido y a su historial.

Las devoluciones guardan por separado quién devuelve, quién recibe, entidad receptora, motivo y hora. Los anexos guardan descripción, cantidad y droguería de recogida. Para el cálculo de metas, cada domicilio completado cuenta una unidad y cada anexo dos unidades, conforme al acuerdo actual.

## Metas y reportes

La meta es global y compartida por los domiciliarios. Cada cambio crea una versión con cantidad objetivo, valor por día cumplido, fecha de inicio, fecha final opcional y Administrador que la definió. Se cierra la vigencia previa cuando inicia la siguiente. No se registran deudas ni pagos; el reporte se calcula contando días que alcanzaron la meta y multiplicándolos por el valor configurado.

Está pendiente decidir si pedidos completados por una empresa externa cuentan para la meta de un domiciliario de la aplicación. No aplicar esa regla en SQL hasta definirla.

## Entidades y empresas

`ENTIDADES_OPERATIVAS` representa Droguería, Central y Call Center. Una entidad puede tener `empresa_id` nulo; Central puede ser compartida por la plataforma. `EMPRESAS` permite registrar la estructura futura, pero no activa reglas de pertenencia.

No aplicar restricciones entre empresas en esta versión. La rotación de personal autorizado entre droguerías es libre. Si más adelante se acuerdan límites por empresa, se añadirán validaciones, permisos RLS y/o funciones correspondientes.

## Seguridad y modelo de datos

El modelo conceptual y el diccionario están en [`modelo-entidad-relacion.md`](modelo-entidad-relacion.md) y [`docs/base-datos/diccionario-datos.md`](docs/base-datos/diccionario-datos.md). `AUTH_USERS` representa Supabase Auth y no es una tabla propia. Aplicar RLS según rol y no exponer claves secretas en el navegador.

Las migraciones PostgreSQL se guardan en `database/migrations/` y se explican antes de ejecutarlas. La primera migración cubre perfiles, entidades operativas y autorizaciones.

El registro de decisiones y dudas está en [`docs/decisiones/dudas-y-decisiones.md`](docs/decisiones/dudas-y-decisiones.md). Si hay diferencia con archivos antiguos, prevalecen los acuerdos vigentes de ese registro y este contexto; las recomendaciones aún no son reglas aprobadas.

## Pendientes de producto

- Definir hora de cierre automático de jornadas y si Central/Call Center usan jornadas.
- Definir los estados adicionales de cuenta, si hacen falta, y cómo se incorporan empleados de Central/Call Center.
- Definir el máximo de integrantes de Central y Call Center y si incluye a la cuenta principal. No imponer límite SQL todavía.
- Definir si una entrega externa cuenta para la meta de un domiciliario de la aplicación.
- Definir atribución de meta si un domiciliario distinto termina un pedido después de la recogida.
- Definir conteo de anexos (por registro o por cantidad), además de validar el +2 acordado.
- Confirmar zona horaria y hora de corte para reportes diarios. Propuesta documentada: `America/Bogota`, medianoche local.
- Definir el flujo exacto de invitación/solicitud de empleados y de establecimiento de contraseña.
- Definir si soporte requiere conversaciones agrupadas, si se requiere folio legible de pedido y cómo manejar notificaciones de cancelación con la app cerrada.
- Definir pago o reconocimiento cuando el cliente cancela con el domiciliario en camino.
- Definir tiempo máximo en rojo antes de otra acción automática.
- Definir qué ocurre con pedidos ya aceptados cuando el domiciliario se desconecta; no liberarlos automáticamente hasta acordar el flujo.

## Estado actual

- **Etapa:** preparación del modelo de datos antes del desarrollo de login y roles.
- **Hecho:** acuerdos funcionales consolidados; README, contexto, diagrama, diccionario y registro de decisiones alineados; migración inicial preparada.
- **Por hacer:** cerrar decisiones que afecten al modelo, revisar la migración con el responsable, ejecutarla en un entorno de desarrollo y continuar con solicitudes, jornadas y pedidos.
- **GitHub:** no hacer `push` sin autorización explícita.
