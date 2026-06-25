-- ORIGEN · Fase C: Proveedores y Repartidores con aprobación (corre una vez en SQL Editor).

create table if not exists providers (
  id uuid primary key default gen_random_uuid(),
  name text, business text, email text unique, phone text,
  status text default 'pendiente' check (status in ('pendiente','aprobado','rechazado')),
  created_at timestamptz default now()
);
create table if not exists riders (
  id uuid primary key default gen_random_uuid(),
  name text, phone text, zone text default 'Zona Sur',
  status text default 'pendiente' check (status in ('pendiente','aprobado','rechazado')),
  created_at timestamptz default now()
);

-- Productos: de qué proveedor son (y aprobación vía columna active existente)
alter table products add column if not exists provider_id uuid;
alter table products add column if not exists provider_name text;

-- Seguridad demo (abierta; endurecer con roles antes de producción)
alter table providers enable row level security;
alter table riders enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='providers' and policyname='demo providers all') then
    create policy "demo providers all" on providers for all using (true) with check (true); end if;
  if not exists (select 1 from pg_policies where tablename='riders' and policyname='demo riders all') then
    create policy "demo riders all" on riders for all using (true) with check (true); end if;
end $$;

-- Repartidores demo (ya aprobados) si la tabla está vacía
insert into riders (name, phone, zone, status)
select v.name, v.phone, v.zone, v.status from (values
  ('Luis Quispe','70000001','Zona Sur','aprobado'),
  ('Ana Choque','70000002','Miraflores','aprobado'),
  ('Pedro Vargas','70000003','Centro','aprobado')
) as v(name,phone,zone,status)
where not exists (select 1 from riders);

-- Tiempo real
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and tablename='providers') then alter publication supabase_realtime add table providers; end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and tablename='riders') then alter publication supabase_realtime add table riders; end if;
end $$;
