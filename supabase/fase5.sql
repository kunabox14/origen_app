-- ORIGEN · Fase 5 (correr una vez en Supabase → SQL Editor).
-- Soporte: respuesta del admin y fecha de respuesta (para dar seguimiento / cerrar el caso).
alter table support_tickets add column if not exists admin_reply text;
alter table support_tickets add column if not exists replied_at timestamptz;
