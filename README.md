# ORIGEN · App (prototipo funcional)

Prototipo móvil navegable de la plataforma **ORIGEN** — suscripción inteligente de productos
orgánicos. Fiel a los mockups y al sistema de diseño **Organic Vitality** (no es una app de
delivery: estética natural, premium, respirada).

> 📲 **Para instalarla en tu celular y mostrarla a inversionistas, lee [MANUAL.md](MANUAL.md).**

Incluye **3 apps conectadas**: cliente/suscriptor (`index.html`), panel de administrador
(dentro del cliente) y **app de repartidor** (`repartidor.html`). Las tres son **PWA instalables**.

### Novedades
- **Login con Google + verificación por código al correo** (simulado, listo para conectar real).
- **PWA instalable** en Android/iPhone (manifest + service worker + favicon e íconos oficiales).
- **Planes de suscripción** (Compra Suelta / Mensual Bs.99 / Para Regalar) y **entregas programadas**
  recurrentes: cada semana, cada 15 días, cada mes o **fecha personalizada**.
- **Cobro recurrente**: al activar la Suscripción Mensual se pide la **tarjeta** del cliente y se
  autoriza el cargo automático de **Bs. 99/mes** (simulado). La tarjeta queda enmascarada (•• últimos 4)
  y se detiene al cancelar.
- **Pausar** la suscripción (con mensaje de confirmación) y **cancelar** (sección discreta al final del inicio).
- **Tarifas separadas** en el pedido: tarifa de servicio (uso de app) **Bs. 5** + **delivery Bs. 7–18**
  según distancia (Bs. 18 si supera 4 km).
- **Admin**: gestión total de productos, **registro de suscriptores** y **reporte de entregas diarias** (CSV).
- **App de repartidor** conectada: recibe **notificación de cada pedido**, lo recoge en almacén y lo
  entrega (el cliente ve el estado **en vivo**); ve el **pago de delivery por entrega** y una sección de
  **Ganancias** para solicitar a fin de mes los cobros con tarjeta (con recordatorio de **facturar a Origen**).
- **Imágenes del catálogo** ahora son ilustraciones locales de marca (siempre cargan).

## Cómo abrirlo
- **Rápido:** abre `index.html` directamente en el navegador (doble clic).
- **Con servidor local** (recomendado, para que carguen rutas/recursos):
  ```
  node .claude/server.js
  ```
  Luego abre http://localhost:8123

> Requiere conexión a internet para Tailwind CDN, Google Fonts (EB Garamond + Hanken Grotesk)
> y los iconos Material Symbols.

## Pantallas
Bienvenida · Registro · Inicio · Catálogo · Canasta · **Checkout** · Confirmación ·
Seguimiento · Escáner · Cuenta · **Login admin** · **Panel admin**

## Funcionalidad (cliente)
- Navegación completa entre pantallas + barra inferior con estado activo.
- Carrito real: añadir, +/−, eliminar, subtotal, descuento suscriptor (12%), total.
- Persistencia del carrito en `localStorage`.
- **Checkout simulado**: QR Simple (Bolivia) y tarjeta. No realiza ningún cobro real;
  registra el pedido y muestra la confirmación con su número.
- Escáner de trazabilidad simulado y flujo de registro con confirmación.
- Si una foto de producto no carga, se muestra un placeholder de marca ("Producto Origen").

## Panel de administrador
Acceso: **Cuenta → Panel de administrador**.
- Usuario demo: `admin@origen.bo` · Clave: `origen2026`
- **Resumen**: productos activos, en suscripción, pedidos e ingresos (simulados).
- **Productos**: crear / editar / eliminar, con **subida de imagen** (se redimensiona a 600px
  y se guarda en `localStorage`). Los cambios se reflejan en vivo en el catálogo.
- **Suscripción**: marca qué productos entran en la canasta recurrente.
- **Pedidos**: lista de pedidos generados en el checkout.
- **Pagos**: activa/desactiva QR y tarjeta y define el nombre del comercio.

> Persistencia y credenciales son **solo de demo en el navegador**. Para producción real
> (multiusuario, productos en la nube, cobros reales) se requiere backend (p. ej. Supabase)
> y una pasarela de pago: en Bolivia, QR Simple / pasarela local; Stripe solo en mercados
> compatibles. La estructura de pagos ya queda preparada para conectarla.

## Estructura
- `index.html` — app completa (router + pantallas + carrito) en un solo archivo.
- `assets/` — logotipo oficial Origen (SVG + PNG, claro y oscuro).
- `.claude/server.js` — servidor estático mínimo para previsualización.

## Marca (no negociable)
Logo oficial sin modificar · Verde bosque `#0A130D` · Crema `#F5F2EB` · Verde hoja `#5EBC66` ·
Verde lima `#BBE85B` · Titulares EB Garamond · Cuerpo Hanken Grotesk.
