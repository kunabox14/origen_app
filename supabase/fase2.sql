-- ORIGEN · Fase 2 (correr una vez en Supabase → SQL Editor).

-- #6: enriquecer las tiendas (proveedores) con descripción, logo, destacado y ubicación.
alter table providers add column if not exists featured boolean default false;
alter table providers add column if not exists description text;
alter table providers add column if not exists logo_url text;
alter table providers add column if not exists address text;
alter table providers add column if not exists lat numeric;
alter table providers add column if not exists lng numeric;

-- #8/#9: sucursales con coordenadas y stock por sucursal (se usan en los siguientes pasos
-- de la Fase 2: selección inteligente de sucursal y logística tienda→cliente).
create table if not exists branches (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid references providers(id) on delete cascade,
  name text,
  address text,
  lat numeric, lng numeric,
  zone text,
  active boolean default true,
  created_at timestamptz default now()
);
create table if not exists branch_inventory (
  id uuid primary key default gen_random_uuid(),
  branch_id uuid references branches(id) on delete cascade,
  product_id uuid references products(id) on delete cascade,
  stock int default 0,
  unique (branch_id, product_id)
);
alter table branches enable row level security;
alter table branch_inventory enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='branches' and policyname='demo branches all') then
    create policy "demo branches all" on branches for all using (true) with check (true); end if;
  if not exists (select 1 from pg_policies where tablename='branch_inventory' and policyname='demo inv all') then
    create policy "demo inv all" on branch_inventory for all using (true) with check (true); end if;
end $$;
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and tablename='branches') then alter publication supabase_realtime add table branches; end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and tablename='branch_inventory') then alter publication supabase_realtime add table branch_inventory; end if;
end $$;
