-- ORIGEN · Fase 6 (correr una vez en Supabase → SQL Editor).
-- Horario de atención del proveedor, visible en la cabecera del catálogo del cliente.
alter table providers add column if not exists business_hours text;
