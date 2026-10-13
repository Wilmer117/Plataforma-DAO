# Instrucciones para colaboradores y asistentes

Lee `CONTEXTO.md` completo antes de proponer o realizar cambios. Revisa también `docs/decisiones/dudas-y-decisiones.md` cuando una decisión esté pendiente o haya contradicciones entre documentos. Los acuerdos vigentes del contexto y del registro de decisiones prevalecen sobre descripciones antiguas; las propuestas aún no aprobadas no son reglas.

## Forma de trabajar

1. Responde en español y explica los pasos con claridad: el responsable del proyecto está aprendiendo desarrollo.
2. Avanza en cambios pequeños y revisables. Indica qué archivos cambiaste y cómo comprobar el resultado.
3. Antes de implementar una decisión que contradiga `CONTEXTO.md`, pregunta al responsable del proyecto.
4. Respeta el alcance del MVP. No desarrolles funcionalidades de fases futuras sin que se soliciten.
5. No cambies el stack ni agregues dependencias o tecnologías sin explicar el motivo y obtener autorización.
6. No solicites, pegues ni registres claves secretas, contraseñas o contenido de `.env.local`. Nunca pongas una clave de servicio de Supabase en el navegador.
7. Respeta los permisos de cada rol y aplica RLS en los accesos a Supabase. No eludas la seguridad del servidor.
8. No hagas `push`, despliegues ni acciones externas sin autorización explícita del responsable.
9. Conserva el trabajo existente. Revisa el estado de Git antes de editar y no sobrescribas cambios ajenos.

## Reglas funcionales esenciales

- Solo Central y Administrador cancelan pedidos.
- Solo Call Center escoge la droguería al publicar un pedido.
- Aceptar un pedido debe ser una operación atómica: el primero se lo queda.
- Si un domiciliario libera un pedido antes de recogerlo, vuelve a estar disponible y se reinicia `disponible_desde`. Después de recogerlo, el domiciliario contacta a Central; no liberar automáticamente.
- El Domiciliario puede conectarse o desconectarse para controlar la recepción de nuevas ofertas. No asumir qué pasa con pedidos ya aceptados al desconectarse; revisar `CONTEXTO.md`.
- La app móvil del Domiciliario es Android nativa en Kotlin y se distribuirá en Google Play; no sustituirla por una PWA.
- Los cambios de pedido deben registrar hora y usuario.
- Las metas son de cantidad de entregas; solo Administrador las define.
- No decidir por cuenta propia los asuntos listados como pendientes en `CONTEXTO.md` o `docs/decisiones/dudas-y-decisiones.md`.
