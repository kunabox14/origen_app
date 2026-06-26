-- ORIGEN · Fase 3 (correr una vez en Supabase → SQL Editor).
-- Update 2: estado de preparación del pedido en la tienda (pendiente → preparando → listo).
alter table orders add column if not exists prep_status text default 'pendiente';
