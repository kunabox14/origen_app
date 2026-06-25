-- ORIGEN · Ubicación del repartidor en vivo (corre una vez en Supabase → SQL Editor).
alter table orders add column if not exists rider_lat double precision;
alter table orders add column if not exists rider_lng double precision;
