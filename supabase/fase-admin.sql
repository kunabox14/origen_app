-- ORIGEN · Admin único (correr una vez en Supabase → SQL Editor). Idempotente y re-ejecutable.
-- Deja a kunabox14@gmail.com como el ÚNICO administrador y revoca admin a cualquier otra cuenta.
-- (El cliente ya valida el admin por la cuenta autenticada; esto mantiene la BD consistente para RLS.)

-- 1) kunabox14@gmail.com = admin (crea su perfil si por alguna razón faltara).
insert into public.profiles (id, email, role)
select u.id, u.email, 'admin'
from auth.users u
where lower(u.email) = 'kunabox14@gmail.com'
on conflict (id) do update set role = 'admin';

-- 2) Revoca admin a cualquier otra cuenta (solo kunabox14@gmail.com queda como admin).
update public.profiles
set role = 'customer'
where role = 'admin'
  and id not in (select id from auth.users where lower(email) = 'kunabox14@gmail.com');

-- 3) Verificación: debe devolver únicamente kunabox14@gmail.com.
select p.email, p.role from public.profiles p where p.role = 'admin';
