# Diccionario de datos

Este diccionario describe el modelo conceptual y guía las migraciones PostgreSQL. Tipos indicados son PostgreSQL. `PK` = clave primaria, `FK` = clave foránea, `UQ` = valor único. Salvo `PERFILES`, los UUID primarios se generan con `gen_random_uuid()` y las fechas de creación con `now()`. Los campos sensibles a reglas aún no definidas se dejan sin una restricción inventada.

## Convenciones

- Los campos marcados **Sí** no aceptan `NULL`; los demás son opcionales o se completan en etapas posteriores.
- `PERFILES.id` usa el UUID de `auth.users.id`, que administra Supabase Auth.
- Los identificadores de estados y tipos se almacenan como `text` con restricciones `CHECK` para facilitar migraciones y mantener las etiquetas legibles.
- `EMPRESAS` es estructural. No se aplican restricciones de pertenencia ni se limita la rotación libre entre droguerías.

## Tablas y campos

### EMPRESAS

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| nombre | text | Sí | No vacío |
| estado | text | Sí | `ACTIVA` o `INACTIVA` |
| creado_en | timestamptz | Sí | `now()` |

Estructura futura; no es una regla de autorización ni restringe la rotación actual.

### PERFILES

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK y FK a `auth.users(id)`; mismo UUID de Auth |
| nombre_completo | text | Sí | No vacío |
| telefono | text | Sí | Texto para conservar prefijos internacionales |
| direccion | text | No | Puede ser desconocida |
| ciudad | text | Sí | No vacío |
| rol | text | Sí | `ADMINISTRADOR`, `CENTRAL`, `CALL_CENTER`, `DROGUERIA` o `DOMICILIARIO`; un rol por cuenta |
| estado_cuenta | text | Sí | `PENDIENTE` o `ACTIVA`; otros estados requieren decisión |
| creado_en | timestamptz | Sí | `now()` |

El correo, su verificación y la contraseña pertenecen a Supabase Auth, no se duplican aquí. `RECHAZADA` es resultado de una solicitud, no estado de perfil. No añadir `BLOQUEADA`, `SUSPENDIDA` o `INACTIVA` hasta definir sus usos.

### ENTIDADES_OPERATIVAS

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| empresa_id | uuid | No | FK a `EMPRESAS`; opcional por diseño futuro |
| tipo | text | Sí | `DROGUERIA`, `CENTRAL` o `CALL_CENTER` |
| nombre | text | Sí | No vacío |
| direccion | text | No | Dirección física |
| telefono | text | No | Teléfono de contacto |
| estado | text | Sí | `ACTIVA` o `INACTIVA` |
| creado_en | timestamptz | Sí | `now()` |

Una entidad Central puede tener `empresa_id` nulo. El vínculo con empresa no filtra ni restringe la selección de droguería en esta versión.

### AUTORIZACIONES

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| perfil_id | uuid | Sí | FK a `PERFILES` |
| entidad_id | uuid | Sí | FK a `ENTIDADES_OPERATIVAS` |
| autorizado_por | uuid | No | FK a `PERFILES`; nulo si el alta inicial la realiza el sistema |
| es_principal | boolean | Sí | `false` por defecto; máximo una autorización principal por entidad |
| estado | text | Sí | `PENDIENTE`, `ACTIVA`, `REVOCADA` |
| autorizado_en | timestamptz | No | Nulo mientras pendiente |

Una cuenta principal también trabaja con el rol operativo de la entidad. La autorización de un empleado de droguería es única, pero le permite trabajar en cualquier droguería activa; no se crea una autorización por cada droguería donde el empleado rote.

### SOLICITUDES_DOMICILIARIO

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| perfil_id | uuid | Sí | FK a `PERFILES` |
| revisado_por | uuid | No | FK a `PERFILES`; nulo mientras pendiente |
| estado | text | Sí | `PENDIENTE`, `APROBADA` o `RECHAZADA` |
| observacion | text | No | Nota de revisión |
| solicitada_en | timestamptz | Sí | `now()` |
| revisada_en | timestamptz | No | Nulo mientras pendiente |

### JORNADAS

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| perfil_id | uuid | Sí | FK a `PERFILES` |
| entidad_activa_id | uuid | No | FK a `ENTIDADES_OPERATIVAS`; sede elegida si aplica |
| iniciada_en | timestamptz | Sí | `now()` |
| finalizada_en | timestamptz | No | Nulo mientras abierta; una jornada abierta por perfil |

### BARRIOS

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| nombre | text | Sí | No vacío |
| ciudad | text | Sí | No vacío |
| activo | boolean | Sí | `true` por defecto; unicidad propuesta `(ciudad, nombre)` |

### PEDIDOS

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| creado_por | uuid | Sí | FK a `PERFILES` |
| entidad_origen_id | uuid | Sí | FK a `ENTIDADES_OPERATIVAS` |
| drogueria_recogida_id | uuid | Sí | FK a `ENTIDADES_OPERATIVAS`; entidad de tipo droguería |
| barrio_id | uuid | Sí | FK a `BARRIOS` |
| direccion_entrega | text | Sí | Dirección del cliente |
| estado | text | Sí | `PENDIENTE`, `ACEPTADO`, `EN_ENTREGA`, `ENTREGADO` o `CANCELADO` |
| modalidad_entrega | text | Sí | `INTERNA` o `EXTERNA`; no es estado |
| creado_en | timestamptz | Sí | `now()` |
| disponible_desde | timestamptz | Sí | Se reinicia al volver a ofrecer un pedido liberado |

El retraso se calcula desde `disponible_desde`; no es un estado persistido. Valor, cliente y teléfono se detallan en el desarrollo del pedido y deben ser campos obligatorios antes de crear esa migración funcional.

### ASIGNACIONES_PEDIDO

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| pedido_id | uuid | Sí | FK a `PEDIDOS` |
| domiciliario_id | uuid | Sí | FK a `PERFILES`; rol domiciliario |
| asignado_por | uuid | No | FK a `PERFILES`; nulo para aceptación directa |
| estado | text | Sí | `ACTIVA`, `LIBERADA`, `COMPLETADA`, `REASIGNADA` |
| motivo_liberacion | text | No | Motivo de liberación |
| asignado_en | timestamptz | Sí | `now()` |
| aceptado_en | timestamptz | No | Hora de aceptación |
| liberado_en | timestamptz | No | Hora de liberación |

Se conserva una fila por intento. Debe existir como máximo una asignación interna activa por pedido.

### ENTREGAS_EXTERNAS

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| pedido_id | uuid | Sí | FK a `PEDIDOS` |
| coordinado_por | uuid | Sí | FK a `PERFILES`; Central o Administrador |
| empresa_externa | text | Sí | Empresa tercera |
| nombre_repartidor | text | No | Contacto del repartidor |
| telefono_repartidor | text | No | Teléfono de contacto |
| estado | text | Sí | Estado del encargo externo, valores por cerrar en diseño funcional |
| coordinado_en | timestamptz | Sí | `now()` |
| entregado_en | timestamptz | No | Hora confirmada de entrega al cliente |

### RECOGIDAS

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| pedido_id | uuid | Sí | FK a `PEDIDOS` |
| drogueria_id | uuid | Sí | FK a `ENTIDADES_OPERATIVAS` |
| validado_por | uuid | Sí | FK a `PERFILES` |
| validada_en | timestamptz | Sí | `now()` |

El código de recogida se valida sin exponerse al domiciliario antes de la recogida. Método de almacenamiento del código pendiente de diseño de seguridad.

### SOLICITUDES_CANCELACION

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| pedido_id | uuid | Sí | FK a `PEDIDOS` |
| solicitada_por | uuid | Sí | FK a `PERFILES` |
| revisada_por | uuid | No | FK a `PERFILES`; nulo mientras pendiente |
| motivo | text | Sí | Razón de solicitud |
| estado | text | Sí | `PENDIENTE`, `APROBADA` o `RECHAZADA` |
| solicitada_en | timestamptz | Sí | `now()` |
| revisada_en | timestamptz | No | Nulo mientras pendiente |

### DEVOLUCIONES

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| pedido_id | uuid | Sí | FK a `PEDIDOS` |
| devuelto_por | uuid | Sí | FK a `PERFILES` |
| recibido_por | uuid | Sí | FK a `PERFILES` |
| entidad_recepcion_id | uuid | Sí | FK a `ENTIDADES_OPERATIVAS` |
| motivo | text | Sí | Motivo de devolución |
| registrada_en | timestamptz | Sí | `now()` |

### ANEXOS

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| pedido_id | uuid | Sí | FK a `PEDIDOS` |
| drogueria_recogida_id | uuid | Sí | FK a `ENTIDADES_OPERATIVAS` |
| descripcion | text | Sí | No vacío |
| cantidad | integer | Sí | Mayor que cero |
| creado_en | timestamptz | Sí | `now()` |

En el cálculo de meta, cada anexo suma dos unidades según el acuerdo actual.

### HISTORIAL_PEDIDO

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| pedido_id | uuid | Sí | FK a `PEDIDOS` |
| perfil_id | uuid | Sí | FK a `PERFILES` |
| entidad_activa_id | uuid | No | FK a `ENTIDADES_OPERATIVAS` |
| accion | text | Sí | Acción realizada |
| estado_anterior | text | No | Estado previo, si aplica |
| estado_nuevo | text | No | Estado resultante, si aplica |
| motivo | text | No | Motivo o detalle |
| ocurrido_en | timestamptz | Sí | `now()`; historial append-only |

### NOTIFICACIONES

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| perfil_destinatario_id | uuid | Sí | FK a `PERFILES` |
| pedido_id | uuid | No | FK a `PEDIDOS` |
| solicitud_domiciliario_id | uuid | No | FK a `SOLICITUDES_DOMICILIARIO` |
| tipo | text | Sí | Tipo de aviso |
| mensaje | text | Sí | Contenido legible |
| creada_en | timestamptz | Sí | `now()` |
| leida_en | timestamptz | No | Nulo hasta lectura |

Debe referenciar al menos un pedido o solicitud; la aprobación de domiciliario no requiere pedido.

### METAS

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| definida_por | uuid | Sí | FK a `PERFILES`; Administrador |
| cantidad_objetivo | integer | Sí | Mayor que cero; meta global compartida |
| valor_por_dia_cumplido | numeric(12,2) | Sí | Mayor o igual a cero |
| vigente_desde | date | Sí | Inicio de versión |
| vigente_hasta | date | No | Fin; nulo para versión vigente |
| creada_en | timestamptz | Sí | `now()` |

Las vigencias no se solapan y se cierra la anterior al crear la siguiente versión.

### MENSAJES_SOPORTE

| Campo | Tipo | Obligatorio | Clave/regla |
|---|---|---:|---|
| id | uuid | Sí | PK |
| remitente_id | uuid | Sí | FK a `PERFILES` |
| destinatario_perfil_id | uuid | No | FK a `PERFILES` |
| destinataria_entidad_id | uuid | No | FK a `ENTIDADES_OPERATIVAS` |
| pedido_id | uuid | No | FK a `PEDIDOS` |
| mensaje | text | Sí | No vacío |
| enviado_en | timestamptz | Sí | `now()` |
| leido_en | timestamptz | No | Nulo hasta lectura |

Exactamente uno de `destinatario_perfil_id` y `destinataria_entidad_id` debe tener valor (`CHECK`).

## Reglas de integridad generales

1. Una sola jornada abierta por perfil.
2. Una cuenta principal activa por entidad.
3. Una asignación interna activa por pedido.
4. Un mensaje de soporte tiene exactamente un destinatario: perfil o entidad.
5. La compatibilidad de roles, aprobación, permisos de edición/cancelación y visibilidad se garantiza mediante funciones y RLS, no solo con tipos de columna.
6. El historial no se actualiza ni elimina desde flujos de aplicación.
7. No imponer máximo de integrantes de Central/Call Center hasta aclarar si incluye la cuenta principal.
8. No restringir rotación por empresa ni contar entregas externas para metas hasta que se acuerde expresamente.
