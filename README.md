# Plataforma de Gestión de Domicilios

Plataforma para coordinar droguerías, Call Center, Central de operación y domiciliarios en un flujo de pedidos en tiempo real. El proyecto busca reemplazar la coordinación manual por llamadas y mensajes.

## Aplicaciones y módulos previstos

- **Administrador:** gestiona usuarios, droguerías y metas diarias; también tiene las funciones de Central.
- **Gerente:** tiene los permisos de Central y consulta su historial.
- **Central:** consulta y edita todos los pedidos, cancela, reasigna pedidos retrasados y recibe alertas.
- **Droguería:** publica pedidos de su propio establecimiento y consulta únicamente sus pedidos.
- **Call Center:** publica pedidos, elige la droguería de recogida y consulta todos los pedidos.
- **App móvil Android del Domiciliario:** aplicación nativa desarrollada en Kotlin para conectarse, recibir nuevos pedidos y gestionar las entregas. Se distribuirá en Google Play.

El MVP incluye el flujo de pedidos, estados en tiempo real, historial de cambios, semáforo de retraso, metas por cantidad y control de acceso por rol. GPS, mapas, optimización de rutas, notificaciones push con la aplicación cerrada y otras funciones avanzadas quedan para una fase posterior.

## Tecnologías acordadas

- Next.js (App Router), TypeScript y Tailwind CSS.
- Supabase: PostgreSQL, Auth, Realtime y Row Level Security (RLS), con `@supabase/supabase-js` y `@supabase/ssr`.
- Aplicación Android nativa para el Domiciliario, desarrollada en Kotlin y con distribución prevista en Google Play.
- Despliegue previsto en Vercel y código en GitHub.

No se deben cambiar estas tecnologías ni agregar dependencias sin explicar la razón y pedir autorización.

## Estructura inicial

```text
.
├── README.md
├── CONTEXTO.md
├── AGENTS.md
└── docs/
    ├── requisitos/
    ├── arquitectura/
    ├── flujos/
    └── decisiones/
```

## Documentación

- [Contexto funcional y reglas del MVP](CONTEXTO.md)
- [Instrucciones para colaboradores y asistentes](AGENTS.md)
- `docs/requisitos/`: requisitos funcionales y criterios de aceptación.
- `docs/arquitectura/`: arquitectura y componentes técnicos.
- `docs/flujos/`: recorridos de usuario y estados de pedidos.
- `docs/decisiones/`: decisiones técnicas y funcionales.

## Estado del proyecto

Etapa 1 — Preparación. El repositorio local contiene la estructura documental inicial. Aún no se han implementado funcionalidades. El siguiente hito de producto es la Etapa 2 — Login y roles. Consulta la sección **Estado actual** de `CONTEXTO.md` para el estado vigente.
