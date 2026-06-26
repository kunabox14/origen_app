-- ORIGEN · Fase 1 (correr una vez en Supabase → SQL Editor).

-- #2/#3: referencias de entrega, nombre del receptor del regalo y coordenadas del destino.
alter table orders add column if not exists delivery_refs text;
alter table orders add column if not exists gift_name text;
alter table orders add column if not exists dest_lat numeric;
alter table orders add column if not exists dest_lng numeric;

-- #5: configuración global de la app (métodos de pago, nombre del comercio) que define el
-- admin y respetan TODOS los clientes (antes vivía solo en el navegador del admin).
create table if not exists app_settings (
  key text primary key,
  value jsonb,
  updated_at timestamptz default now()
);
alter table app_settings enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='app_settings' and policyname='demo settings all') then
    create policy "demo settings all" on app_settings for all using (true) with check (true); end if;
end $$;

-- Tiempo real para que el cliente refleje los cambios del admin al instante.
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and tablename='app_settings') then
    alter publication supabase_realtime add table app_settings; end if;
end $$;
