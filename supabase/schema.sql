-- ORIGEN · Esquema de base de datos (Supabase / Postgres)
-- Se ejecuta en: Supabase → SQL Editor → New query → pegar y Run.
-- Incluye seguridad por filas (RLS): cada quien ve solo lo que le corresponde.
-- (Borrador inicial; lo afino al conectar la app.)

-- ========== PERFILES (extiende auth.users) ==========
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text,
  email text,
  phone text,
  address text,
  zone text default 'Zona Sur',
  role text not null default 'customer' check (role in ('customer','rider','admin')),
  created_at timestamptz default now()
);

-- Crea el perfil automáticamente al registrarse
create or replace function handle_new_user() returns trigger as $$
begin
  insert into public.profiles (id, name, email)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email,'@',1)), new.email)
  on conflict (id) do nothing;
  return new;
end; $$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function handle_new_user();

-- Helper: ¿el usuario actual es admin?
create or replace function is_admin() returns boolean as $$
  select exists(select 1 from profiles where id = auth.uid() and role = 'admin');
$$ language sql security definer stable;

-- ========== PRODUCTOS ==========
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price numeric not null,
  unit text,
  origin text,
  category text,
  tag text,
  image_url text,
  active boolean default true,
  in_sub boolean default false,
  created_at timestamptz default now()
);

-- ========== SUSCRIPCIONES ==========
create table if not exists subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  plan text default 'mensual',
  frequency text default 'quincenal' check (frequency in ('semanal','quincenal','mensual','personalizada')),
  next_date date,
  status text default 'Activa' check (status in ('Activa','Pausada','Cancelada')),
  amount numeric default 99,
  created_at timestamptz default now()
);

-- ========== COBRO RECURRENTE (solo referencias/tokens, NUNCA el número de tarjeta) ==========
create table if not exists billing (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  provider text,                 -- 'stripe' | 'dlocal' | ...
  provider_customer_id text,
  provider_sub_id text,
  brand text,
  last4 text,
  amount numeric default 99,
  cycle text default 'mensual',
  next_charge date,
  status text default 'active',
  created_at timestamptz default now()
);

-- ========== PEDIDOS ==========
create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  code text unique,
  user_id uuid references profiles(id) on delete set null,
  status text default 'Nuevo' check (status in ('Nuevo','Asignado','Recogido','En camino','Entregado','Cancelado')),
  method text,                   -- 'qr' | 'card'
  subtotal numeric, discount numeric, service_fee numeric default 5,
  delivery_fee numeric, delivery_km numeric, total numeric,
  delivery_date date, "window" text,
  address text, zone text,
  assigned_to uuid references profiles(id) on delete set null,  -- repartidor
  created_at timestamptz default now()
);

create table if not exists order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id) on delete cascade,
  product_id uuid references products(id) on delete set null,
  name text, qty int, price numeric
);

create table if not exists order_events (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id) on delete cascade,
  status text, at timestamptz default now(), by_name text
);

-- ========== PUSH (Web Push / VAPID) ==========
create table if not exists push_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  endpoint text unique, p256dh text, auth text,
  created_at timestamptz default now()
);

-- ============================================================
-- SEGURIDAD (RLS)
-- ============================================================
alter table profiles            enable row level security;
alter table products            enable row level security;
alter table subscriptions       enable row level security;
alter table billing             enable row level security;
alter table orders              enable row level security;
alter table order_items         enable row level security;
alter table order_events        enable row level security;
alter table push_subscriptions  enable row level security;

-- Perfiles: cada quien el suyo; admin todos
create policy "perfil propio (lectura)"  on profiles for select using (id = auth.uid() or is_admin());
create policy "perfil propio (update)"   on profiles for update using (id = auth.uid() or is_admin());

-- Productos: cualquiera autenticado lee; admin escribe
create policy "productos lectura"        on products for select using (true);
create policy "productos admin escribe"  on products for all using (is_admin()) with check (is_admin());

-- Suscripciones y billing: dueño + admin
create policy "sub dueño"  on subscriptions for all using (user_id = auth.uid() or is_admin()) with check (user_id = auth.uid() or is_admin());
create policy "billing dueño" on billing for all using (user_id = auth.uid() or is_admin()) with check (user_id = auth.uid() or is_admin());

-- Pedidos:
--   cliente ve los suyos; repartidor ve los 'Nuevo' (sin asignar) y los suyos; admin ve todo
create policy "pedidos lectura" on orders for select using (
  user_id = auth.uid()
  or assigned_to = auth.uid()
  or (status = 'Nuevo' and exists(select 1 from profiles where id = auth.uid() and role in ('rider','admin')))
  or is_admin()
);
create policy "pedidos cliente crea" on orders for insert with check (user_id = auth.uid());
create policy "pedidos repartidor/admin actualizan" on orders for update using (
  assigned_to = auth.uid()
  or (status = 'Nuevo' and exists(select 1 from profiles where id = auth.uid() and role in ('rider','admin')))
  or is_admin()
);

-- Items y eventos: heredan del pedido
create policy "items por pedido" on order_items for select using (
  exists(select 1 from orders o where o.id = order_id and (o.user_id = auth.uid() or o.assigned_to = auth.uid() or o.status='Nuevo' or is_admin()))
);
create policy "items insert" on order_items for insert with check (true);
create policy "eventos por pedido" on order_events for select using (
  exists(select 1 from orders o where o.id = order_id and (o.user_id = auth.uid() or o.assigned_to = auth.uid() or is_admin()))
);
create policy "eventos insert" on order_events for insert with check (true);

-- Push: solo el dueño
create policy "push dueño" on push_subscriptions for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Realtime: emitir cambios de pedidos a quien corresponda
alter publication supabase_realtime add table orders;
alter publication supabase_realtime add table order_events;
