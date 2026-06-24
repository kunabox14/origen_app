-- ORIGEN · Poblar el catálogo en la nube (corre una sola vez).
-- Supabase → SQL Editor → New query → pegar → Run.

insert into products (name, price, unit, origin, category, tag, image_url, active, in_sub) values
  ('Miel de Abeja de Monte',          45, '500g', 'Chiquitanía',   'Despensa',   'Orgánico', 'assets/products/honey.svg',  true, true),
  ('Quinoa Real Blanca',              32, '1kg',  'Altiplano Sur', 'Despensa',   'Local',    'assets/products/grain.svg',  true, true),
  ('Café de Altura',                  55, '250g', 'Yungas',        'Despensa',   'Orgánico', 'assets/products/coffee.svg', true, false),
  ('Aceite de Coco Prensado en Frío', 85, '400ml','Trópico',       'Superfoods', 'Orgánico', 'assets/products/bottle.svg', true, true),
  ('Harina de Almendras Integral',    62, '500g', 'Valle Central', 'Superfoods', 'Orgánico', 'assets/products/grain.svg',  true, false),
  ('Mantequilla de Coco Orgánica',    78, '300g', 'Trópico',       'Superfoods', 'Orgánico', 'assets/products/bottle.svg', true, false),
  ('Harina de Coco Fina',             45, '400g', 'Trópico',       'Snacks',     'Local',    'assets/products/grain.svg',  true, false);

-- ===== (Opcional) Convertir TU cuenta en administrador =====
-- Primero inicia sesión en la app con tu correo (así se crea tu perfil), luego corre esto
-- reemplazando el correo por el tuyo. Te permite que el panel admin escriba en la nube.
-- update profiles set role = 'admin' where email = 'TU-CORREO@ejemplo.com';
