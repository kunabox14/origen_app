-- ORIGEN · Chat cliente ↔ repartidor (corre una vez en Supabase → SQL Editor).
create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  order_code text not null,
  sender text not null,        -- 'cliente' | 'repartidor'
  sender_name text,
  body text not null,
  created_at timestamptz default now()
);
alter table messages enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='messages' and policyname='demo messages all') then
    create policy "demo messages all" on messages for all using (true) with check (true); end if;
end $$;
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and tablename='messages') then
    alter publication supabase_realtime add table messages; end if;
end $$;
