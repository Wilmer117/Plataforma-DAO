-- Migración 0001: perfiles, entidades operativas y autorizaciones.
-- Ejecutar después de crear el proyecto Supabase (requiere auth.users).
-- Incluye EMPRESAS como estructura futura, sin limitar la rotación entre droguerías.

begin;

create table public.perfiles (
    id uuid primary key references auth.users (id) on delete cascade,
    nombre_completo text not null check (length(trim(nombre_completo)) > 0),
    telefono text not null check (length(trim(telefono)) > 0),
    direccion text,
    ciudad text not null check (length(trim(ciudad)) > 0),
    rol text not null check (
        rol in ('ADMINISTRADOR', 'CENTRAL', 'CALL_CENTER', 'DROGUERIA', 'DOMICILIARIO')
    ),
    estado_cuenta text not null default 'ACTIVA' check (estado_cuenta in ('PENDIENTE', 'ACTIVA')),
    creado_en timestamptz not null default now()
);

comment on table public.perfiles is
    'Datos de perfil vinculados 1:1 a Supabase Auth. No almacena correo ni contraseña.';

-- Estructura para futuras ampliaciones; no se usa para limitar la rotación actual.
create table public.empresas (
    id uuid primary key default gen_random_uuid(),
    nombre text not null check (length(trim(nombre)) > 0),
    estado text not null default 'ACTIVA' check (estado in ('ACTIVA', 'INACTIVA')),
    creado_en timestamptz not null default now()
);

create table public.entidades_operativas (
    id uuid primary key default gen_random_uuid(),
    empresa_id uuid references public.empresas (id) on delete restrict,
    tipo text not null check (tipo in ('DROGUERIA', 'CENTRAL', 'CALL_CENTER')),
    nombre text not null check (length(trim(nombre)) > 0),
    direccion text,
    telefono text,
    estado text not null default 'ACTIVA' check (estado in ('ACTIVA', 'INACTIVA')),
    creado_en timestamptz not null default now()
);

comment on table public.entidades_operativas is
    'Droguerías, Central y Call Center. empresa_id no restringe selección ni rotación en esta versión.';

create table public.autorizaciones (
    id uuid primary key default gen_random_uuid(),
    perfil_id uuid not null references public.perfiles (id) on delete restrict,
    entidad_id uuid not null references public.entidades_operativas (id) on delete restrict,
    autorizado_por uuid references public.perfiles (id) on delete restrict,
    es_principal boolean not null default false,
    estado text not null default 'PENDIENTE' check (
        estado in ('PENDIENTE', 'ACTIVA', 'REVOCADA')
    ),
    autorizado_en timestamptz,
    creado_en timestamptz not null default now(),
    constraint autorizaciones_perfil_entidad_uq unique (perfil_id, entidad_id),
    constraint autorizacion_activa_tiene_fecha check (
        estado <> 'ACTIVA' or autorizado_en is not null
    )
);

create unique index autorizaciones_una_principal_activa_por_entidad
    on public.autorizaciones (entidad_id)
    where es_principal and estado = 'ACTIVA';

create index autorizaciones_por_perfil_idx on public.autorizaciones (perfil_id);
create index autorizaciones_por_entidad_estado_idx
    on public.autorizaciones (entidad_id, estado);

comment on table public.autorizaciones is
    'Permisos de trabajo por entidad. La autorización de Droguería no limita a qué droguería puede rotar el empleado.';

-- Bloquea el acceso directo por la API hasta que las políticas RLS se definan
-- junto con los flujos de administración y alta inicial.
alter table public.perfiles enable row level security;
alter table public.empresas enable row level security;
alter table public.entidades_operativas enable row level security;
alter table public.autorizaciones enable row level security;

commit;
