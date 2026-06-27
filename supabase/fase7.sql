-- ORIGEN · Fase 7 (correr una vez en Supabase → SQL Editor).
-- Categorías múltiples por producto (fresco, artesanal, semiindustrial, industrial).
alter table products add column if not exists categories text[] default '{}';
