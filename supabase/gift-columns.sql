-- ORIGEN · Columnas para tipo de pedido y mensaje de regalo (opcional, recomendado).
-- Supabase → SQL Editor → New query → pegar → Run.
-- Sin esto, los pedidos igual funcionan; con esto el tipo y el mensaje de regalo
-- se guardan en la nube y se ven en todos los dispositivos.

alter table orders add column if not exists order_type text default 'directa';
alter table orders add column if not exists gift_message text;
