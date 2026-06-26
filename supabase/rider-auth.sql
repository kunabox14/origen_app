-- ORIGEN · Login de repartidor con Google (corre una vez en Supabase → SQL Editor).
-- Vincula la cuenta de Google del repartidor (email) con su registro/estado de aprobación.
alter table riders add column if not exists email text;
create unique index if not exists riders_email_uniq on riders(email) where email is not null;
