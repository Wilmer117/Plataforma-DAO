# Dudas y decisiones del proyecto

Este documento ordena las dudas encontradas al revisar el repositorio. Para resolver contradicciones, se toma como vigente el resumen de acuerdos que el responsable compartió en el chat el 12 de octubre de 2026. Las preguntas del documento de análisis son material para revisar, no instrucciones automáticas ni decisiones aprobadas. Las propuestas se identifican como propuestas y no deben convertirse en restricciones SQL hasta que el responsable las confirme.

## Decisiones vigentes frente a contradicciones del repositorio

| Tema | Acuerdo vigente | Consecuencia documental |
|---|---|---|
| Roles | Administrador, Central, Call Center, Droguería y Domiciliario. No existe el rol Gerente en el modelo actual. | Eliminar Gerente de README, login y modelo. |
| Central | La operación usa una Central compartida; “Central 1” y “Central 2” identifican cuentas/personas del equipo, no dos entidades independientes. | Representar una entidad Central y varias cuentas autorizadas. |
| Empresas | `EMPRESAS` y `empresa_id` preparan el futuro. Central puede tener `empresa_id` nulo. Ninguna regla de empresa restringe la operación actual. | Mantener rotación libre de personal autorizado entre todas las droguerías activas. |
| Estados del pedido | `PENDIENTE`, `ACEPTADO`, `EN_ENTREGA`, `ENTREGADO` y `CANCELADO`. Retraso es una condición calculada. Entrega externa es modalidad, no estado. | Quitar `RETRASADO` y `EXTERNO` de listas de estados. |
| Semáforo y alerta | El reloj parte de `disponible_desde`, se reinicia cuando el pedido liberado vuelve a estar disponible y se avisa a Central al cumplir 10 minutos sin asignación. | No usar `created_at` como reloj permanente ni esperar hasta el minuto 15. |
| Liberación | Antes de recoger, el pedido liberado vuelve al conjunto disponible y reinicia su reloj. Después de recoger, el domiciliario contacta a Central para coordinar; no se libera automáticamente. | No dejar todas las liberaciones como retrasadas ni ocultarlas de los demás antes de recoger. |
| Cancelación | Solo Central o Administrador cancelan directamente. El domiciliario puede solicitar cancelación; Droguería revisa la solicitud. | La solicitud de Droguería no equivale a permiso para cambiar el pedido a cancelado. |
| Metas | Una meta global compartida, versionada. No hay una meta distinta por domiciliario. | Mantener versiones en `METAS`; no añadir meta individual. |
| Modelo SQL | El modelo tiene 18 tablas propias previstas, además de Supabase Auth. No existía esquema ejecutado antes del trabajo en esta copia. | La migración 0001 actual está preparada, pero aún no ejecutada. |

## Preguntas del análisis que siguen pendientes

### Operación y cuentas

| Pregunta | Estado actual | Propuesta para decidir después |
|---|---|---|
| ¿A qué hora se cierra automáticamente una jornada? | Sin definir. Las jornadas de Droguería guardan inicio y cierre; no se especificó cierre automático. | Empezar con cierre manual y decidir una hora automática solo si la operación la necesita. |
| ¿Qué estados de cuenta hay además de pendiente y activa? | `PENDIENTE` y `ACTIVA` están claros para el alta/aprobación. El rechazo pertenece a la solicitud. Bloqueo, suspensión e inactivación de una cuenta no están definidos. | No añadir esos estados ni sus flujos a SQL hasta decidir si se necesitan y qué significan. |
| ¿Cómo se incorporan empleados de Central y Call Center? | El Administrador crea entidades y cuentas principales; las entidades pueden autorizar a su equipo. No está decidido si un empleado crea primero su cuenta, recibe invitación o solicita acceso. | Adoptar invitación con enlace de establecimiento de contraseña por seguridad; confirmar el flujo antes de implementarlo. |
| ¿El soporte agrupa mensajes en conversaciones? | `MENSAJES_SOPORTE` representa mensajes individuales con remitente, destinatario perfil o entidad y pedido opcional. No hay regla aprobada para conversaciones agrupadas. | Mantener mensajes individuales en MVP; añadir conversación solo si se necesita contexto de varios mensajes. |
| ¿Se reinicia el reloj al liberar? | Resuelto: sí, cuando la liberación ocurre antes de recoger y el pedido se vuelve a ofrecer. | Usar `disponible_desde` y guardar el evento de liberación en historial. |
| ¿El máximo de cinco integrantes de Central/Call Center incluye la cuenta principal? | Sigue pendiente de la revisión anterior. No hay límite en migración ni modelo lógico. | Aclarar si son cinco en total o cinco más la cuenta principal antes de crear una regla SQL. |
| ¿Las entregas externas cuentan para la meta de un domiciliario de la app? | Sigue pendiente. | La recomendación previa es que no cuenten si ningún domiciliario de la app completó la entrega; confirmar antes de implementar el cálculo. |
| ¿Hay pago cuando el cliente cancela con el domiciliario en camino? | Sigue pendiente; el modelo actual no guarda pagos ni deudas. | Mantener fuera de la base de datos hasta definir la regla comercial. |

### Dudas nuevas del análisis

| Pregunta | Estado actual | Propuesta para decidir después |
|---|---|---|
| ¿Cómo entran los empleados de Droguería? | La cuenta principal autoriza al empleado una vez. La autorización no limita en qué droguería activa rota. No está detallado si la cuenta se crea antes de la autorización o mediante invitación. | El empleado usa cuenta individual y la principal autoriza esa cuenta; no crear solicitud separada salvo que se quiera un flujo de autoinscripción. |
| ¿Qué pasa al desconectarse un domiciliario? | Desconectarse deja de ofrecerle pedidos nuevos. No hay acuerdo de liberar o cancelar pedidos que ya aceptó. | No liberar automáticamente los pedidos existentes; conservar sus asignaciones y dejar su resolución a Central hasta definir otra regla. |
| ¿Central pertenece a una empresa? | Central es compartida y puede tener `empresa_id` nulo. | Ya representado así en el modelo; no aplicar límites de empresa. |
| ¿Puede Administrador editar/cancelar pedidos? | Sí. Administrador tiene todas las funciones de Central, incluida edición y cancelación. Cada acción debe quedar en historial. | Hacer que el historial registre explícitamente actor y cambios. |
| ¿Qué roles abren jornadas? | Está definido para personal de Droguería, que escoge una droguería activa al iniciar. No está definido para Central ni Call Center. | Por ahora no exigir jornadas a otros roles ni bloquear sus operaciones por esa razón. |
| ¿Puede haber varios anexos? | El modelo permite varios registros de anexo por pedido, pero el límite no se ha fijado expresamente. El acuerdo de meta es sumar dos unidades por anexo; falta precisar si se cuenta por registro o por cantidad. | Considerar el conteo al completar la entrega; confirmar si es +2 por registro o por unidad antes de cerrar la fórmula. |
| ¿Anexos tienen código de recogida propio? | No se definió un código separado. El flujo describe código de recogida del pedido. | Reutilizar la validación del pedido completo; no crear un segundo código sin necesidad confirmada. |
| ¿Devoluciones guardan pagos o deudas? | No. Pagos y deudas están fuera del modelo actual. Se guardan quién devuelve, quién recibe, dónde, motivo y hora. | Mantener la tabla de devoluciones sin campos monetarios. |
| ¿Quién recibe crédito de meta si otro domiciliario termina tras una recogida? | Se conservan todos los intentos de asignación; falta definir el crédito en esa reasignación. Las entregas externas no cuentan para un domiciliario de la app, pendiente de confirmar en contexto. | Atribuir el domicilio al perfil que confirma la entrega interna, pero confirmarlo antes de implementar el cálculo. |
| ¿Hay alerta sonora de cancelación con la app cerrada? | Las notificaciones push con la app cerrada están fuera del MVP; no se puede prometer una alerta sonora en ese escenario. | Notificación dentro de la app cuando esté activa; decidir si esa limitación es aceptable. No incorporar FCM sin aprobar alcance/tecnología. |
| ¿Cómo establece contraseña la cuenta principal? | Cada persona tiene credenciales propias; no se comparten ni se guardan contraseñas en `PERFILES`. El mecanismo inicial no está definido. | Usar enlace de invitación/establecimiento de contraseña de Auth en vez de enviar una contraseña temporal; confirmar en el diseño de Auth. |
| ¿Habrá número legible de pedido? | No está decidido. UUID sirve como clave interna; no existe requisito aprobado para un folio visible. | Empezar con UUID interno y añadir folio si operación o soporte lo requiere. |
| ¿Qué zona horaria y corte diario usan las metas? | No está aprobado en documentos de base de datos. | Propuesta: `America/Bogota` y cambio de día a medianoche local. Confirmar antes de escribir funciones/reportes diarios. |
| ¿Qué pasa tras permanecer demasiado tiempo en rojo? | El máximo antes de otra acción automática sigue pendiente. | Mantener alerta al minuto 10, sin una acción adicional automática hasta decidirla. |

## Observaciones de estructura del repositorio

- Kotlin nativo para Android es el stack acordado; referencias antiguas a Flutter o FCM en material anterior no cambian esa decisión.
- La plantilla Next.js permanece dentro de `next-scaffold/` por ahora. No moverla a la raíz en esta tarea; decidirlo al preparar la etapa de login.
- Los `.gitkeep` en arquitectura, flujos y requisitos son marcadores de carpetas aún sin documentos, no contenido faltante que deba inventarse ahora.
- El análisis se basó en la copia local del repositorio y los acuerdos compartidos en este chat. Los PDF externos que menciona el documento no están en esta copia; no se les atribuyen decisiones nuevas.
- La migración `0001_perfiles_entidades_autorizaciones.sql` está en el repositorio local y no ha sido ejecutada. Habilita RLS sin políticas, por lo que las tablas no quedan expuestas por la API mientras se diseñan los permisos.

## Próximo orden de trabajo

1. Confirmar los puntos pendientes que afecten al modelo (incorporación de personal, jornadas, anexos y atribución de metas).
2. Actualizar el diccionario y el diagrama si una respuesta cambia una cardinalidad, campo o regla.
3. Revisar y ejecutar la migración 0001 en Supabase de desarrollo.
4. Diseñar las políticas RLS y los flujos de Auth antes de conectar la aplicación.
