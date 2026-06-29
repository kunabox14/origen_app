-- ORIGEN · Fase 8 (correr una vez en Supabase → SQL Editor). Idempotente.
-- 1) Disponibilidad real de entrega por tienda (proveedor): días abiertos, franjas horarias
--    ofrecidas y fechas bloqueadas (feriados/vacaciones).
-- 2) Datos de venta en el pedido (tienda/proveedor de origen y dirección de recojo) para que
--    el panel del proveedor liste correctamente sus ventas y la logística lea bien el pickup.

-- --- Disponibilidad por tienda ---------------------------------------------------------------
-- open_days: enteros 0=Domingo … 6=Sábado. Por defecto Lun–Sáb (1..6).
alter table providers add column if not exists open_days int[] default '{1,2,3,4,5,6}';
-- delivery_slots: franjas horarias que la tienda ofrece (deben coincidir con las del cliente).
alter table providers add column if not exists delivery_slots text[]
  default array['09:00 – 11:00','11:00 – 13:00','13:00 – 15:00','15:00 – 17:00','17:00 – 19:00','19:00 – 21:00'];
-- blocked_dates: fechas puntuales cerradas (feriados, vacaciones).
alter table providers add column if not exists blocked_dates date[] default '{}';

-- --- Datos de venta en el pedido -------------------------------------------------------------
-- Tienda y proveedor de origen (1 pedido = 1 tienda) → el proveedor filtra sus ventas.
alter table orders add column if not exists store_name text;
alter table orders add column if not exists provider_id uuid;
-- Dirección de la sucursal de recojo (además de pickup_branch/lat/lng ya existentes).
alter table orders add column if not exists pickup_address text;

-- Índice para acelerar el reporte de ventas del proveedor.
create index if not exists orders_provider_id_idx on orders (provider_id);
