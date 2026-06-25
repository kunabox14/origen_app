-- ORIGEN · Tickets de soporte (corre una vez en Supabase → SQL Editor).
create table if not exists support_tickets (
  id uuid primary key default gen_random_uuid(),
  ticket_no text,
  user_email text,
  name text,
  subject text,
  body text,
  status text default 'Abierto',
  created_at timestamptz default now()
);
alter table support_tickets enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='support_tickets' and policyname='demo tickets all') then
    create policy "demo tickets all" on support_tickets for all using (true) with check (true); end if;
end $$;
