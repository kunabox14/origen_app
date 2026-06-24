-- ORIGEN · Permisos para el DEMO (corre una vez en Supabase → SQL Editor).
-- Permite que el repartidor (login por nombre) y el panel admin escriban/lean
-- sin ser usuarios Supabase todavía. ⚠️ Endurecer con roles reales antes de producción.

-- Columnas que usa la app en los pedidos (nombre/correo del cliente y repartidor por nombre)
alter table orders add column if not exists customer_name text;
alter table orders add column if not exists customer_email text;
alter table orders add column if not exists assigned_rider text;

-- Políticas permisivas para el demo (RLS combina con OR: esto abre el acceso)
do $$ begin
  if not exists (select 1 from pg_policies where tablename='products' and policyname='demo products all') then
    create policy "demo products all" on products for all using (true) with check (true); end if;
  if not exists (select 1 from pg_policies where tablename='orders' and policyname='demo orders all') then
    create policy "demo orders all" on orders for all using (true) with check (true); end if;
  if not exists (select 1 from pg_policies where tablename='order_items' and policyname='demo items all') then
    create policy "demo items all" on order_items for all using (true) with check (true); end if;
  if not exists (select 1 from pg_policies where tablename='order_events' and policyname='demo events all') then
    create policy "demo events all" on order_events for all using (true) with check (true); end if;
  if not exists (select 1 from pg_policies where tablename='subscriptions' and policyname='demo subs all') then
    create policy "demo subs all" on subscriptions for all using (true) with check (true); end if;
  if not exists (select 1 from pg_policies where tablename='profiles' and policyname='demo profiles read') then
    create policy "demo profiles read" on profiles for select using (true); end if;
end $$;

-- Tiempo real para el catálogo (orders/order_events ya están en la publicación)
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and tablename='products') then
    alter publication supabase_realtime add table products; end if;
end $$;
