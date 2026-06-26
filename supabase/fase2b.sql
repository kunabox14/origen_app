-- ORIGEN · Fase 2b (correr una vez en Supabase → SQL Editor).

-- #7/#9: sucursal de origen (pickup) elegida para cada pedido, para la logística tienda→cliente.
alter table orders add column if not exists pickup_branch text;
alter table orders add column if not exists pickup_lat numeric;
alter table orders add column if not exists pickup_lng numeric;

-- Siembra una sucursal "Casa matriz" para CADA proveedor aprobado que aún no tenga sucursales,
-- usando su ubicación (o una por defecto en La Paz si el proveedor no tiene coordenadas).
insert into branches (provider_id, name, zone, lat, lng, address)
select p.id, 'Casa matriz', 'Zona Sur',
       coalesce(p.lat, -16.5400), coalesce(p.lng, -68.0800), coalesce(p.address, '')
from providers p
where p.status = 'aprobado'
  and not exists (select 1 from branches b where b.provider_id = p.id);

-- Stock inicial (20 u.) de los productos de cada proveedor en su sucursal, para vender de inmediato.
insert into branch_inventory (branch_id, product_id, stock)
select b.id, pr.id, 20
from branches b
join products pr on pr.provider_id = b.provider_id
where not exists (
  select 1 from branch_inventory bi where bi.branch_id = b.id and bi.product_id = pr.id
);
