# Manual de implementación · ORIGEN

Guía para **instalar la app en tu celular** y **mostrarla a inversionistas y clientes**.

---

## 1. Qué incluye el paquete

| App | Archivo | Para quién |
|-----|---------|-----------|
| **App de cliente / suscriptor** | `index.html` | Usuarios que compran y se suscriben |
| **Panel de administrador** | dentro de `index.html` (Cuenta → Panel admin) | Tú / tu equipo |
| **App de repartidor** | `repartidor.html` | Los deliverys |

Las tres son **PWA instalables** (se instalan en el celular como una app, sin tienda) y
**comparten los pedidos**: cuando un cliente paga, el repartidor lo ve y, al actualizar el
estado, el cliente lo ve en vivo en su seguimiento.

### Accesos demo
- **Admin** → usuario `admin@origen.bo` · clave `origen2026`
- **Cuentas Google demo** → Sofía Castro / Diego Rojas (botón "Continuar con Google")
- **Código de verificación** → se muestra en pantalla (banner "Código demo") y con "Usar código"
- **Repartidores** → Luis Quispe · Ana Choque · Pedro Vargas

---

## 2. Probar en tu computadora (1 minuto)

1. Tener **Node.js** instalado (ya lo tienes).
2. En la carpeta del proyecto, ejecutar:
   ```
   node .claude/server.js
   ```
3. Abrir en el navegador: **http://localhost:8123** (cliente) y **http://localhost:8123/repartidor.html** (repartidor).

> Tip para el demo en vivo: abre el cliente y el repartidor en **dos ventanas**. Haz un pedido
> en el cliente → aparece en "Nuevos" del repartidor → acéptalo y avanza el estado → el cliente
> ve el cambio en su pantalla de seguimiento en tiempo real.

---

## 3. Instalarla en tu celular (recomendado para inversionistas)

Para que se instale como app en el celular hace falta una **URL segura (https)**. La forma más
rápida y gratis, sin cuentas técnicas:

### Opción A · Netlify Drop (la más fácil)
1. Entra desde tu PC a **https://app.netlify.com/drop**
2. **Arrastra la carpeta `ORIGEN APP`** completa a esa página.
3. Te dará una URL https tipo `https://origen-xxxx.netlify.app`.
4. Abre esa URL **en el celular**:
   - **Android (Chrome):** menú ⋮ → *Instalar aplicación* / *Agregar a pantalla principal*.
   - **iPhone (Safari):** botón Compartir → *Agregar a inicio*.
5. Listo: aparece el ícono de ORIGEN en la pantalla de inicio y abre a pantalla completa.

> La app del repartidor queda en `…netlify.app/repartidor.html` (instálala igual en el celular del delivery).

### Opción B · misma red WiFi (sin internet, uso rápido)
1. Corre `node .claude/server.js` en la PC.
2. Averigua la IP de tu PC (`ipconfig` → "Dirección IPv4", p. ej. `192.168.1.40`).
3. En el celular (misma WiFi) abre `http://192.168.1.40:8123`.
   - Funciona para mostrarla, pero la **instalación como app** requiere la opción A (https).

---

## 4. Crear el archivo APK (Android)

> No se puede generar un `.apk` firmado en este entorno (faltan herramientas de Android). Tienes
> dos caminos, ambos parten de la app ya publicada en una URL https (paso 3A):

### Camino rápido · PWABuilder (sin programar)
1. Publica la app (Netlify, paso 3A) y copia la URL https.
2. Entra a **https://www.pwabuilder.com**, pega la URL y pulsa *Start*.
3. En *Android* → *Generate Package* → descarga el paquete (APK/AAB firmado de prueba).
4. Pasa el `.apk` al celular e instálalo (activa "instalar apps desconocidas").

### Camino para desarrollador · Capacitor
```
npm init -y
npm install @capacitor/core @capacitor/cli @capacitor/android
npx cap init ORIGEN com.ankaya.origen --web-dir .
npx cap add android
npx cap copy
npx cap open android   # compila el APK en Android Studio
```

---

## 5. Guion sugerido para el demo (3 minutos)

1. **Cliente:** "Empezar" → *Continuar con Google* → código de verificación → entras a la app.
2. Muestra el **catálogo**, agrega productos, ve a la **canasta** (descuento de suscriptor 12%).
3. **Paga** con QR boliviano o tarjeta (simulado) → confirmación con número de pedido.
4. **Repartidor** (otra ventana): el pedido aparece en *Nuevos* → *Aceptar* → *Recogido en almacén*
   → *Iniciar entrega* → *Entregado*.
5. **Cliente:** abre *Seguimiento* → el estado se actualizó en vivo.
6. **Admin:** Cuenta → Panel → muestra **Productos** (sube uno con foto), **Suscriptores**,
   y **Entregas del día** (descarga el reporte CSV).

---

## 6. Importante (paso a producción real)

Esta versión es un **demo funcional que vive en el navegador** (datos en el dispositivo). Para
operar de verdad necesitarás:

- **Backend** (p. ej. **Supabase**): productos y pedidos en la nube, multiusuario, sincronización
  real entre el celular del cliente, el del repartidor y el admin (hoy se sincronizan solo en el
  mismo dispositivo/navegador).
- **Login real**: Google OAuth + envío real de códigos por correo (servicio de email).
- **Pagos reales**: pasarela local boliviana (QR Simple / BCB); Stripe solo en mercados compatibles.

La estructura del código ya está organizada para conectar todo esto.

---

## 7. Estructura de archivos
```
ORIGEN APP/
├─ index.html          App de cliente + panel admin
├─ repartidor.html     App de repartidor
├─ manifest.json       Configuración PWA (instalable)
├─ sw.js               Service worker (offline)
├─ assets/             Logo oficial + íconos de la app
├─ tools/make-icons.js Generador de íconos
└─ .claude/server.js   Servidor local para pruebas
```
