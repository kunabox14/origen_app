# Guía rápida de pruebas — ORIGEN

Recorridos para verificar que todo funciona de punta a punta (cliente → proveedor → repartidor → admin).

> **Antes de probar:** abre las apps en HTTPS, no desde `file://`. Si ves algo viejo, refresca con **Ctrl+Shift+R** (o usa una ventana de incógnito) — el Service Worker cachea.

## URLs

| App | URL |
|-----|-----|
| Cliente | https://kunabox14.github.io/origen_app/ |
| Proveedor | https://kunabox14.github.io/origen_app/proveedor.html |
| Repartidor | https://kunabox14.github.io/origen_app/repartidor.html |
| Admin | dentro del cliente, con la cuenta `kunabox14@gmail.com` → Panel admin |

## Migraciones SQL (correr una vez en Supabase → SQL Editor)

Estado: **todas corridas**. Si reinstalas la base, corre en orden:
`schema.sql` → `policies-demo.sql` → `support.sql` → `tracking-columns.sql` → `gift-columns.sql` → `providers.sql` → `rider-auth.sql` → `fase1.sql` → `fase2.sql` → `fase2b.sql` → `fase3.sql` → `fase4.sql`.

Son idempotentes (`add column if not exists`, etc.): se pueden re-correr sin romper nada.

---

## 1) Cliente: comprar de una tienda

1. Entra al **cliente** y inicia sesión (Google o correo).
2. Pestaña **Tiendas** → elige una tienda → **Visitar tienda** → filtra por categoría.
3. Añade productos a la canasta → **canasta**.
4. En *Detalles de entrega*:
   - Tipo **Directa** → fija ubicación con **Mi ubicación (GPS)** o **Elegir en mapa**.
   - Escribe **Referencias de entrega** (obligatorio).
5. Revisa que el **descuento 12%** solo aparezca si estás suscrito; si no, dice *"Si estuvieras suscrito, ahorrarías…"*.
6. Verifica que el **delivery** cambie según la distancia (tramos 5/10/15/18 Bs).
7. **Confirmar pedido** → pagar (QR o tarjeta, según lo que tenga activo el admin).

**Regalo:** repite con tipo **Regalo** → pide nombre del receptor + ubicación en mapa + referencias + mensaje opcional.

## 2) Proveedor: sucursales, stock y productos

1. Entra al **proveedor** con Google. Si es nuevo: completa negocio + **carnet + fotocopia + ubicación**.
2. En el panel: **Mis sucursales** → ya viene "Casa matriz" sembrada → **Stock** (ajusta cantidades) y **Ubicación** (mapa).
3. **Mis productos** → **Nuevo** para agregar; usa la papelera para **eliminar** (pide confirmación).
4. Toggle **Gestión / Mi tienda** → "Mi tienda" muestra el catálogo como lo ve el cliente (Visible/Inactivo).
5. **Dirección de mi negocio → Actualizar** cambia tu ubicación cuando quieras.

## 3) Pedido entrante en el proveedor (banner)

1. Haz un pedido (paso 1) de una tienda de ese proveedor.
2. En el proveedor aparece, **sin refrescar**, el banner **"Tienes un pedido por preparar"** con:
   - Productos y cantidad.
   - **ETA del repartidor** (cuando esté asignado y compartiendo ubicación).
   - Botones **Empezar preparación** → **Marcar como listo**.

## 4) Repartidor: tiempo real y recojo

1. Entra al **repartidor** con Google. Si es nuevo: completa **carnet + fotocopia + ubicación** (solo en el registro).
2. Espera aprobación del admin (paso 5) y toca **"Ya estoy aprobado · Actualizar"**.
3. Un pedido nuevo aparece **solo, sin refrescar**, con **"Recoger en: [sucursal]"**.
4. Avanza el pedido: **Asignado → Recogido → En camino → Entregado**. El cliente lo ve en su seguimiento en vivo.

> Para depurar el tiempo real: abre la consola del navegador (F12) y busca logs `[Origen·Repartidor]`.

## 5) Admin: aprobaciones, pedidos, soporte, pagos

1. En el **cliente** con `kunabox14@gmail.com` → **Panel admin**.
2. **Repartidores / Proveedores**: solicitudes pendientes con chips **Carnet / Fotocopia / Ubicación** → **Aprobar** o **Rechazar**.
3. **Pedidos / Entregas**: pedidos en vivo y reporte diario.
4. **Soporte**: tickets del formulario de [contacto](contact.html) y del botón *Ayuda* de la app.
5. **Pagos**: activa/desactiva QR/Tarjeta y el nombre del comercio → el cliente lo respeta (se sincroniza por Supabase).

---

## Si algo falla

| Síntoma | Causa probable |
|---|---|
| Veo una versión vieja | Caché del SW → Ctrl+Shift+R o incógnito |
| Login Google no abre / vuelve raro | Redirect URLs en Supabase + dominio en Google Cloud |
| No sube el documento en el registro | Falta correr `fase4.sql` (bucket `docs`) |
| El banner del proveedor no cambia de estado | Falta correr `fase3.sql` (`prep_status`) |
| El pedido no llega al repartidor | Revisa logs `[Origen·Repartidor]` en consola |

Reporta el paso exacto y, si hay error en consola, su texto, para afinarlo.
