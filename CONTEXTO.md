# Contexto del proyecto — Plataforma de Gestión de Domicilios

## 1. Propósito y usuarios

La plataforma conecta droguerías, un Call Center, una Central de operación y domiciliarios para coordinar pedidos en tiempo real y reemplazar llamadas y mensajes manuales.

- **Web:** Administrador, Gerente, Central, Droguería y Call Center.
- **Celular:** el Domiciliario trabaja desde una PWA instalable.

## 2. Roles y permisos

| Rol | Dónde trabaja | Permisos y responsabilidades |
|---|---|---|
| Administrador | Web | Tiene las funciones de Central; crea metas diarias y gestiona usuarios y droguerías. |
| Gerente | Web | Tiene los permisos de Central y puede consultar el historial de Central. |
| Central (Central 1 y Central 2) | Web | Ve todos los pedidos; puede editar mensajero, precio, barrio y dirección; cancelar y reasignar pedidos retrasados; recibe alertas. |
| Droguería | Web | Publica pedidos de su propia droguería, ve solo sus pedidos y recibe notificación cuando se entregan. |
| Call Center | Web | Publica pedidos, elige a qué droguería asignarlos, ve todos los pedidos y recibe notificación cuando se entregan. Es el único rol que elige la droguería al publicar. |
| Domiciliario | PWA móvil | Ve pedidos pendientes disponibles, acepta pedidos, lleva varios a la vez, libera pedidos, marca entregas y consulta su meta y ganancias. |

## 3. Flujo de un pedido (MVP)

1. Droguería o Call Center publica un pedido con cliente, teléfono, dirección, barrio y valor. Si lo publica Call Center, el origen indica **“Call Center — recoger en [droguería]”** y el domiciliario recoge allí.
2. El pedido aparece en Central y en los celulares de domiciliarios disponibles como `pendiente`.
3. El primer domiciliario que lo acepta se lo queda; deja de aparecer para los demás. Puede ver nombre, teléfono, dirección y punto de recogida.
4. Central y quien publicó el pedido ven el estado `aceptado`.
5. Central puede editar el pedido en cualquier momento. Cada cambio queda en el historial.
6. El domiciliario marca `en_entrega` al iniciar y `entregado` al finalizar.
7. Al entregar, Central ve la fila en azul y no recibe notificación. La droguería de origen y Call Center sí reciben notificación.
8. Si el domiciliario libera el pedido, este no se ofrece a otros domiciliarios. Aparece únicamente para Central como `retrasado`, para reasignarlo o resolverlo por otro medio.
9. Solo Central y Administrador pueden cancelar pedidos.

Estados: `pendiente → aceptado → en_entrega → entregado`, además de `cancelado`, `retrasado` y `externo`.

## 4. Reglas del MVP

### Retrasos y alertas

El semáforo se calcula con `created_at`; no se almacena como dato independiente. Las bandas definidas son verde (0–3 minutos), verde claro (3–5), naranja (5–10) y rojo (desde 10 minutos). Se muestra en web y en la PWA. Cuando el pedido lleva cinco minutos en rojo (minuto 15), Central recibe una alerta para asignarlo con urgencia.

### Metas

Solo el Administrador define la meta diaria, general o individual por domiciliario (por ejemplo, 10, 20 o 30 domicilios). Es una meta de cantidad, no un pago. El domiciliario ve cuántos lleva, cuántos faltan y mensajes como “Meta cumplida” o “Meta superada”.

### Tiempo real e historial

Los cambios de estado se reflejan en pantalla con Supabase Realtime. Cada cambio del pedido se registra con hora y usuario.

## 5. Fuera del MVP

Se reserva para una fase posterior: GPS y mapas, asignación por zona, regla del 25 % de apoyo en pedidos rojos, deudas del domiciliario con plazo de 4 horas, reportes avanzados, 2FA, auditoría avanzada, notificaciones push con la aplicación cerrada, publicación en tiendas, optimización de rutas y calificaciones.

## 6. Pendientes por definir

- Si se paga al domiciliario cuando el cliente cancela estando ya en camino.
- El límite máximo de tiempo en rojo antes de una acción automática adicional.

No inventar una regla para estos puntos: documentar la decisión cuando el responsable del proyecto la defina.

## 7. Tecnologías decididas

- Next.js (App Router), TypeScript y Tailwind CSS.
- Supabase: PostgreSQL, Auth, Realtime y Row Level Security (RLS).
- Cliente Supabase con `@supabase/supabase-js` y `@supabase/ssr`.
- PWA para el domiciliario. Si más adelante hace falta GPS o push nativo, se evaluará Capacitor.
- Despliegue en Vercel y código en GitHub.

No cambiar el stack sin consultar. No agregar librerías o tecnologías nuevas sin explicar por qué y pedir autorización.

## 8. Base de datos y seguridad

El esquema funcional previsto está en `database/schema_mvp_domicilios.sql`. Incluye las tablas `drogerias`, `perfiles`, `pedidos`, `historial`, `notificaciones` y `metas`. Las acciones del domiciliario se implementan como funciones SQL atómicas: `aceptar_pedido`, `liberar_pedido`, `avanzar_pedido` y `progreso_hoy`.

La seguridad se aplica con RLS para que cada rol acceda solo a los datos permitidos. No omitir RLS ni usar una clave secreta en el navegador. El esquema y el código se incorporarán en etapas posteriores; esta estructura documental no los crea.

## 9. Módulos previstos

- Autenticación y perfiles por rol.
- Administración de usuarios, droguerías y metas.
- Panel de Central: pedidos, edición, cancelación, retrasos, reasignación, alertas e historial.
- Portal de Droguería: publicar pedidos propios y consultar su estado.
- Portal de Call Center: publicar pedidos, escoger droguería y consultar todos los pedidos.
- PWA de Domiciliario: disponibles, aceptación, entregas, liberación y progreso de meta.
- Capa de datos Supabase: persistencia, funciones atómicas, RLS y Realtime.

## 10. Estado actual

- **Etapa:** 1 — Preparación.
- **Hecho:** definición de roles y flujo, demo visual HTML, esquema SQL y guía de arranque; repositorio clonado localmente y documentación inicial preparada.
- **Pendiente de publicación:** los archivos iniciales aún no se han enviado a GitHub. No hacer `push` sin autorización explícita.
- **Siguiente etapa de producto:** Etapa 2 — Login y roles.
