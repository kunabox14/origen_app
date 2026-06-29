# PROJECT_CONTEXT_HANDOFF — ORIGEN

> Documento de transferencia de contexto. Sirve para que una nueva sesión continúe
> exactamente donde quedó. Última actualización: tras commit `58cbfa6` (SW `origen-v50`).
> Existe una **skill** `origen-app` (en `~/.claude/skills/origen-app/SKILL.md`) que resume la
> guía de desarrollo; úsala junto con `origen-brand` (colores/logo). Este handoff es el estado
> detallado y vigente.

---

## 1. Nombre del proyecto

**ORIGEN** — plataforma/ecommerce de **productos orgánicos** en La Paz, Bolivia. Responsable
legal en textos: **Kuna Box**. (Antes figuraba "Ankaya Origen S.R.L."; se eliminó por pedido del
dueño — no volver a usar esa razón social.)

- **Repo:** https://github.com/kunabox14/origen_app.git (rama `main`)
- **Producción (GitHub Pages):** https://kunabox14.github.io/origen_app/
- **Carpeta local:** `C:\Users\HP\Desktop\ORIGEN APP`
- **Supabase:** proyecto `fjlqwhcxwjasngbdgwia` → `https://fjlqwhcxwjasngbdgwia.supabase.co`
- **Admin:** se entra desde la app de cliente con `kunabox14@gmail.com` (rol real en `profiles.role`).

---

## 2. Arquitectura actual

**Tres aplicaciones web independientes (cada una un solo archivo HTML)** que comparten el mismo
backend Supabase y se comunican en **tiempo real** (Supabase Realtime):

1. **Cliente** (`index.html`, ~3825 líneas): catálogo por **Tiendas**, carrito, checkout
   simulado (QR/tarjeta), suscripción, seguimiento de pedido, cuenta, configuración, **y el
   PANEL ADMIN completo** embebido (visible solo si el usuario es admin).
2. **Proveedor** (`proveedor.html`, ~811 líneas): registro con Google, sucursales con mapa +
   stock, gestión de productos, banner de pedidos por preparar, "Mi tienda".
3. **Repartidor** (`repartidor.html`, ~698 líneas): registro con Google + documentos, pedidos
   en tiempo real, ruta, ganancias.

**Modelo de negocio (multi-tienda):** las **tiendas = proveedores aprobados**. Cada proveedor
tiene **sucursales** (`branches`) con coordenadas y **stock por sucursal** (`branch_inventory`).
Al comprar, el sistema elige **una sola tienda por pedido** y dentro de ella la **sucursal más
cercana con stock completo**. La logística es **tienda→cliente** (el origen del pedido es la
sucursal, no un almacén central). Los productos sin proveedor caen en una tienda virtual oficial
llamada **"Origen"** (usa `WAREHOUSE` como origen).

**Patrón de datos híbrido:** la app hidrata de Supabase con respaldo en `localStorage`, escribe
en la nube y sincroniza por Realtime. **Si no hay red o falta correr un SQL, la app NO se rompe**
(todo en `try/catch`, con fallback local). Este principio es sagrado: mantenerlo siempre.

**PWA:** `manifest.json` + `sw.js` (Service Worker). Instalable. El SW cachea el shell.

---

## 3. Stack tecnológico

- **Frontend:** HTML único por app + **Tailwind CSS vía Play CDN** (`cdn.tailwindcss.com`) con
  `tailwind.config` inline (tokens de marca "Organic Vitality"). **No hay build, no npm.**
  - ⚠️ **El CDN debe cargar PRIMERO y `tailwind.config` aplicarse DESPUÉS** (el Play CDN
    sobrescribe `window.tailwind` al iniciar; configurar antes borra la config → botones sin
    color). Esto se arregló en commit `bfbeea9`. NO volver al patrón "config antes del CDN".
- **Íconos:** Material Symbols Outlined (Google Fonts). **Tipografías:** EB Garamond (titulares),
  Hanken Grotesk (texto).
- **Backend:** **Supabase** — Postgres + Auth (Google OAuth + OTP por correo) + Realtime
  (postgres_changes) + Storage (bucket `docs`). Cliente JS UMD pinneado por CDN jsdelivr.
- **Mapas:** Google Maps JS API (loader dinámico por callback) + Geocoder + haversine.
- **Escáner QR:** jsQR (carga perezosa al abrir el escáner).
- **Pagos:** SIMULADOS. Hay un **Stripe Payment Link de prueba** para la suscripción (regreso con
  `?sub=ok`). Las tarjetas se "tokenizan" de forma simulada (solo se guardan marca + últimos 4 +
  vencimiento, nunca PAN/CVV). **No hay pasarela real conectada todavía.**
- **Config:** `supabase-config.js` expone `window.ORIGEN_SB_CONFIG { url, anonKey, googleEnabled,
  stripeLink, mapsKey }` y crea `window.ORIGEN_SB`. La anon key y la Maps key son **públicas**
  (seguras en el navegador; la seguridad real la dan las políticas RLS).

---

## 4. Estructura de carpetas importante

```
ORIGEN APP/
├── index.html              Cliente + Panel admin (todo en uno)
├── proveedor.html          App proveedor
├── repartidor.html         App repartidor
├── sw.js                   Service Worker (const CACHE = "origen-vN")
├── supabase-config.js      Config Supabase (network-first en el SW)
├── manifest.json           PWA
├── privacy-policy.html     Legales (responsable: Kuna Box)
├── terms-of-service.html
├── contact.html            Formulario → crea ticket en support_tickets
├── assets/
│   ├── origen-logo.svg / origen-logo-light.svg   (LOGO OFICIAL — no alterar)
│   ├── favicon.svg, icon-192.png, icon-512.png, apple-touch-icon-180.png
│   └── products/*.svg      (imágenes de respaldo de productos)
├── supabase/               Migraciones SQL (correr una vez cada una en SQL Editor)
│   ├── schema.sql, policies-demo.sql, seed.sql
│   ├── support.sql, chat.sql, tracking-columns.sql, gift-columns.sql
│   ├── providers.sql, rider-auth.sql
│   └── fase1.sql … fase7.sql
├── README.md, MANUAL.md, BACKEND.md, DEPLOY.md, PRUEBAS.md   (documentación)
└── PROJECT_CONTEXT_HANDOFF.md   (este archivo)
```

---

## 5. Componentes / módulos creados o modificados (resumen funcional)

**Cliente (`index.html`):**
- Pantallas (`<section class="screen">`, activa con `.active`; `navigate(screen)` enruta):
  welcome, register, auth, otp, home, **stores** (Tiendas), **catalog** (vista de una tienda),
  basket, checkout, confirmed, tracking, schedule, orders, favorites, referrals, settings,
  yapas, chat, support, plans, admin.
- **Tiendas:** `storeList()` (proveedores aprobados + "Origen"), grilla 2 columnas, agrupadas por
  **zona de servicio**, filtro por zona (prioriza la del cliente), **tiendas favoritas**
  (`origen_fav_stores` en localStorage).
- **Vista de tienda:** catálogo filtrado por las 6 categorías (Superfoods, Despensa, Snacks,
  Bebidas, Carnes vegetales, Granos); muestra horario de atención de la tienda; productos con
  stepper +/- limitado por stock; etiqueta "Última unidad"/"Quedan N"; agotados invisibles.
- **Carrito:** una sola tienda por pedido (`addToCart` bloquea mezclar), botón "Vaciar canasta",
  selección de sucursal (`selectBranchForStore`/`selectPickup`), delivery por distancia real
  (tramos 5/10/15/18 Bs), descuento 12% solo para suscriptores, "Pedido activo".
- **Checkout:** dirección por GPS/mapa (sin escribir a mano), referencias obligatorias, regalo
  (receptor + ubicación mapa + referencias + mensaje), descuento de stock al pagar.
- **Configuración v2.0:** solo Perfil, Dirección favorita (mapa), Métodos de pago, Seguridad
  (nota tokenización), Ayuda y Chat. (Eliminados: Idioma, Notificaciones, Ofertas, Novedades.)
- **Panel admin (tabs):** Resumen, Productos, Suscripción, Suscriptores, Pedidos, **Por entregar**
  (pagados pendientes + programados prepagados con tienda responsable), Entregas, Proveedores,
  Repartidores, Pagos, Soporte. Aprobar/rechazar/eliminar proveedores y repartidores; ver
  documentos (carnet/factura/ubicación); "Ver tienda/catálogo"; "Publicar todos los productos";
  tickets de soporte con respuesta + cambio de estado/cierre; abrir apps proveedor/repartidor.
- **Menú lateral (drawer):** ícono ☰ abre acceso a secciones clave (+ Panel admin si es admin).

**Proveedor (`proveedor.html`):** login Google (+ correo de respaldo); registro pide encargado,
nombre de tienda, WhatsApp (obligatorio), **zona** y **ubicación en mapa** (carnet/fotocopia
fueron QUITADOS del proveedor); logo + descripción de tienda; categorías por producto;
sucursales con mapa + stock; alerta de stock bajo (<3); banner prioritario de pedidos por
preparar con ETA del repartidor y estados pendiente→preparando→listo; "Mi tienda" (preview);
eliminar productos con confirmación; editar su ubicación.

**Repartidor (`repartidor.html`):** login Google + **modo demo** (perfiles); registro de nuevos
pide **carnet + factura de luz/agua + ubicación**; estado pendiente→aprobado por admin; pedidos
en tiempo real (solo sin asignar; entregados desaparecen); "Recoger en: [sucursal]"; chat con el
cliente **solo tras aceptar** el pedido + notificaciones push; ganancias; comparte ubicación en
vivo.

---

## 6. Archivos modificados a lo largo de las sesiones recientes

Prácticamente todo el repo ha evolucionado. Los archivos que se tocan habitualmente:
`index.html`, `proveedor.html`, `repartidor.html`, `sw.js` (sube versión en cada cambio),
`supabase-config.js`, y se agregaron migraciones `supabase/fase1.sql … fase7.sql`. Documentación
nueva: `PRUEBAS.md` y este `PROJECT_CONTEXT_HANDOFF.md`.

**Ver historial real con:** `git log --oneline` (la rama `main` está al día con GitHub).
Commits recientes relevantes (de más nuevo a más viejo):
`58cbfa6` welcome spacing · `d06a908` quita etiqueta+Garantía · `99e7486` Config v2.0 ·
`7ef2565` Google select_account · `bfbeea9` fix Tailwind config order · `985b4eb` perf SW ·
`a52c4ea` sidebar repartidor/admin · `bee2839` repartidor solo no-asignados · `617f20b` chat
tras aceptar · `8314ddb` stepper stock · `74e133d` stock/alertas/por-entregar/tickets.

---

## 7. Cambios ya implementados (FUNCIONANDO)

- ✅ Las 3 apps con **login Google** (selector de cuenta forzado con `prompt=select_account`).
- ✅ **Tiendas** (2 columnas, por zona, filtro, favoritas) y vista de tienda con categorías.
- ✅ **Sucursales + stock por sucursal**; selección inteligente de sucursal; delivery por
  distancia; carrito de una sola tienda.
- ✅ **Reglas de stock**: alerta <3, agotado invisible, "Última unidad", tope por stock,
  descuento al pagar.
- ✅ **Aprobaciones** de proveedores/repartidores con documentos y ubicación; al aprobar
  proveedor se publican sus productos.
- ✅ **Panel admin** con todas las pestañas, incl. "Por entregar" y **Soporte accionable**
  (responder/cerrar; el cliente ve la respuesta en "Mis tickets").
- ✅ **Checkout** con dirección por mapa/GPS, referencias, regalo, suscripción (12% suscriptor).
- ✅ **Config cliente v2.0** simplificada.
- ✅ **Chat** cliente↔repartidor (tras aceptar) + chat/soporte; notificaciones push.
- ✅ **Tailwind/colores e íconos** arreglados (config order); **PWA** con SW network-first para
  HTML/config y cache-first para estáticos.
- ✅ **Bienvenida** limpia (sin "100% Orgánico" ni "Garantía Origen").

---

## 8. Cambios pendientes / 9. Errores conocidos

**Pendientes / incompletos (ver también sección "incompletas" al final):**
- **Pasarela de pago REAL**: hoy es simulada. Falta conectar Libélula/QR Simple con tokenización
  real vía **Supabase Edge Function** (el secreto NO puede ir en el cliente estático). Hay un
  prompt guardado en el Escritorio (`prompt-pasarela-pago.txt`) con el plan.
- **Tabla de direcciones múltiples** (`addresses` con city/country/is_default): hoy se guarda una
  sola dirección favorita (texto + coords) en `localStorage`/settings. Si se quieren varias,
  crear tabla dedicada.
- **Endurecer RLS y Storage** antes de producción (hoy políticas demo `using(true)`).
- **Rate limiting / anti-spam del chat**: requiere Edge Function.

**Errores conocidos / fricciones:**
- **Caché del Service Worker**: tras cada deploy el usuario debe refrescar con **Ctrl+Shift+R**
  (o incógnito) o reabrir la PWA; por eso **se sube `CACHE = "origen-vN"` en cada cambio**.
- **Imágenes/logo "rotos"**: casi siempre es caché vieja del SW, no el código (verificar en
  preview antes de tocar). El logo y los assets cargan bien en limpio.
- **Login Google desde `file://`**: NO funciona; probar siempre en la URL HTTPS.
- **OAuth redirect**: en Supabase → Authentication → URL Configuration deben estar las Redirect
  URLs con comodín `https://kunabox14.github.io/origen_app/**`, y en Google Cloud el callback
  `https://fjlqwhcxwjasngbdgwia.supabase.co/auth/v1/callback`.
- Algunas imágenes semilla apuntan a URLs `lh3.googleusercontent.com/aida-public/...` (pueden
  fallar; hay fallback `imgFail`/`assets/products/generic.svg`).

---

## 10. Decisiones de diseño tomadas

- **Una sola tienda por pedido** (no se mezclan productos de tiendas distintas).
- **Tiendas = proveedores aprobados**; productos sin proveedor → tienda virtual "Origen".
- **Logística tienda→cliente** (origen = sucursal más cercana con stock completo).
- **Delivery por tramos de distancia** (5/10/15/18 Bs), no tarifa plana.
- **Descuento 12% = beneficio exclusivo del suscriptor** (no aplica a no suscritos).
- **Pagos simulados** pero con modelo seguro (sin PAN/CVV) listo para conectar pasarela real.
- **Notificaciones automáticas y siempre activas** (se quitó el toggle de configuración).
- **Dirección por mapa/GPS** (nunca texto manual como método principal).
- **Estética premium "Organic Vitality"** — NO parecer app de delivery masivo.
- **Idioma del dispositivo** (se eliminó el selector de idioma).
- **Arquitectura sin build** (HTML+CDN) para simplicidad y deploy directo a GitHub Pages.

---

## 11. Reglas para cualquier nuevo desarrollador

1. **Sube `CACHE = "origen-vN"` en `sw.js`** en CADA cambio que toque archivos cacheados, y
   recuérdale al usuario hacer **Ctrl+Shift+R**.
2. **Tailwind:** CDN primero, `tailwind.config` después. Nunca al revés.
3. **Nunca romper el modo offline**: todo acceso a Supabase va en `try/catch` con fallback local.
4. **Inserts resilientes**: al guardar con columnas nuevas, intenta con ellas y haz fallback sin
   ellas (patrón de `cloudCreateOrder`), para que funcione aunque no se haya corrido el SQL.
5. **Backend nuevo** → crear `supabase/faseN.sql` con `add column/create table if not exists` +
   políticas demo + (si aplica) `alter publication supabase_realtime add table ...`, y **dar al
   usuario el SQL exacto para pegar** (no asumir snippets guardados).
6. **NUNCA** pegar secretos (service_role, Stripe secret) en el código ni en el chat.
7. **No alterar el logo oficial** ni hacer que parezca delivery masivo (ver skill `origen-brand`).
8. **Verificar en el preview** (no pedir al usuario que pruebe a mano): recargar, revisar
   `preview_console_logs` (solo debe salir el warning de Tailwind CDN), comprobar con
   `preview_eval`. **Limpiar datos de prueba** que se inserten en Supabase.
9. **Texto de UI y mensajes de commit en español.** Commits terminan con
   `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.
10. **Responsable legal = "Kuna Box"** (jamás "Ankaya Origen S.R.L.").

---

## 12. Próximas tareas pendientes (orden sugerido)

1. **Conectar pasarela de pago real** (Libélula o QR Simple) con tokenización vía Supabase Edge
   Function (usar el prompt en `prompt-pasarela-pago.txt`). Reemplazar checkout/suscripción
   simulados.
2. **Endurecer seguridad para producción**: políticas RLS por rol (no demo-abierta), políticas de
   Storage restringidas (documentos sensibles), rate limiting del chat.
3. **Direcciones múltiples** del cliente (tabla `addresses`) si se requiere más de una.
4. **Notificaciones push reales** (Web Push / FCM) en vez de Notification API local.
5. **Optimizar imágenes** del catálogo (reemplazar URLs `aida-public` por assets propios).
6. **Pruebas end-to-end** siguiendo `PRUEBAS.md`.

---

## QUÉ **NO** MODIFICAR

- El **logo oficial** (`assets/origen-logo.svg` / `-light.svg`) ni los tokens de color de marca.
- El **orden Tailwind** (CDN → config). No revertir.
- El principio **offline-safe** (try/catch + fallback local) ni los **inserts resilientes**.
- La **anon key / Maps key** en `supabase-config.js` (son públicas y deben quedarse; restringidas
  por dominio/RLS).
- La razón social: **no** reintroducir "Ankaya Origen S.R.L.".
- El sistema de pantallas (`.screen/.active`, `.scr/.on`, `navigate()`/`show()`) — base de toda
  la navegación.

## FUNCIONALIDADES QUE YA FUNCIONAN

Login Google (3 apps) · Tiendas/zonas/favoritas · vista de tienda + categorías · sucursales +
stock + selección de sucursal · carrito 1 tienda + stepper + vaciar · checkout (mapa, referencias,
regalo, suscripción 12%) · descuento de stock · aprobaciones con documentos · panel admin completo
(incl. Por entregar y Soporte accionable) · chat tras aceptar + push · config v2.0 · PWA · marca
y colores correctos.

## FUNCIONALIDADES INCOMPLETAS / SIMULADAS

- **Pagos reales** (hoy simulados; modelo seguro listo, falta Edge Function + pasarela).
- **Tokenización real** de tarjetas (simulada).
- **Direcciones múltiples** (hoy una sola favorita).
- **Notificaciones push reales** (hoy Notification API local del navegador).
- **Seguridad de producción**: RLS demo-abierta, Storage abierto, sin rate limiting.

---

## Estado de migraciones SQL

Orden a correr en Supabase → SQL Editor (idempotentes):
`schema.sql` → `policies-demo.sql` → `support.sql` → `chat.sql` → `tracking-columns.sql` →
`gift-columns.sql` → `providers.sql` → `rider-auth.sql` → `fase1.sql` → `fase2.sql` →
`fase2b.sql` → `fase3.sql` → `fase4.sql` → `fase5.sql` → `fase6.sql` (business_hours) →
`fase7.sql` (products.categories[]).

El usuario confirmó haber corrido hasta `fase5.sql`. **Verificar con el usuario si ya corrió
`fase6.sql` y `fase7.sql`** (horario de atención y categorías múltiples por producto); si no,
darle el SQL para pegarlos. Sin correrlos, esas dos funciones degradan sin romper la app.
