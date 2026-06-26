-- ORIGEN · Fase 4 (correr una vez en Supabase → SQL Editor).
-- Update 4: documentos de validación (carnet + fotocopia) y ubicación en el registro.

alter table providers add column if not exists id_doc_url text;
alter table providers add column if not exists copy_doc_url text;

alter table riders add column if not exists lat numeric;
alter table riders add column if not exists lng numeric;
alter table riders add column if not exists address text;
alter table riders add column if not exists id_doc_url text;
alter table riders add column if not exists copy_doc_url text;

-- Bucket público para los documentos subidos (carnet/fotocopia, imagen o PDF).
insert into storage.buckets (id, name, public) values ('docs', 'docs', true)
on conflict (id) do nothing;

-- Políticas demo: lectura pública y subida desde la app.
do $$ begin
  if not exists (select 1 from pg_policies where schemaname='storage' and tablename='objects' and policyname='docs public read') then
    create policy "docs public read" on storage.objects for select using (bucket_id = 'docs'); end if;
  if not exists (select 1 from pg_policies where schemaname='storage' and tablename='objects' and policyname='docs anon write') then
    create policy "docs anon write" on storage.objects for insert with check (bucket_id = 'docs'); end if;
end $$;
