# ORIGEN · Backend real (plan + qué necesito de tu lado)

Objetivo: pasar de "demo en el navegador" a un sistema real, multiusuario y entre dispositivos:
- Login real con Google + código al correo
- Productos, pedidos, suscriptores y entregas en la nube (no en el celular)
- El repartidor recibe pedidos en **su** celular (otro dispositivo) con **notificación push**
- Cobro recurrente real de Bs. 99/mes

La **interfaz no cambia**: reemplazo por dentro el almacenamiento local (localStorage) por la nube.

---

## Arquitectura recomendada (Supabase)

| Necesidad | Con qué se resuelve |
|---|---|
| Login Google + código al correo | **Supabase Auth** (Google OAuth + OTP por email, ya incluidos) |
| Base de datos (productos, pedidos, suscriptores, entregas) | **Supabase Postgres** |
| Conexión en vivo cliente ↔ repartidor ↔ admin entre dispositivos | **Supabase Realtime** |
| Fotos de productos subidas por el admin | **Supabase Storage** |
| Notificaciones push al repartidor | **Web Push (VAPID)** — lo genero yo, no necesitas cuenta |
| Cobro recurrente Bs. 99/mes | **Pasarela de pago** (ver punto 4 — depende de Bolivia) |
| Lógica segura (webhooks de pago, enviar push) | **Supabase Edge Functions** |

Supabase tiene **plan gratuito** suficiente para arrancar y validar con inversionistas.

---

# ✅ Lo que necesito de tu lado (paso a paso)

> Regla de seguridad: lo que diga **(PÚBLICO)** me lo puedes pegar aquí en el chat sin problema.
> Lo que diga **(SECRETO)** NO se pega en el chat: lo guardas tú en Supabase/variables de entorno
> siguiendo mis pasos. Yo te indico exactamente dónde.

### 1) Crear el proyecto Supabase  → me das 2 datos (PÚBLICO)
1. Entra a **https://supabase.com** → *Start your project* → inicia sesión (puedes con tu Google).
2. *New project*. Nombre: `origen`. Contraseña de base de datos: pon una y **guárdatela**.
   Región: **South America (São Paulo)** (la más cercana a Bolivia).
3. Cuando termine de crear (1–2 min), ve a **Project Settings → API** y cópiame:
   - **Project URL** (ej: `https://abcd1234.supabase.co`) — *(PÚBLICO)*
   - **anon public key** (una clave larga que empieza con `eyJ...`) — *(PÚBLICO)*
4. En esa misma pantalla hay una **service_role key** — *(SECRETO)*. **No me la pegues.**
   La usaremos solo del lado servidor; te diré cuándo y dónde ponerla.

➡️ **Pégame aquí: Project URL + anon key.** Con eso ya conecto la app a tu base.

---

### 2) Activar "Continuar con Google" real  → seguimos juntos
Supabase necesita una credencial de Google. Pasos (te guío en vivo cuando hagamos esto):
1. Entra a **https://console.cloud.google.com** con tu cuenta.
2. Crea un proyecto (ej: `Origen`).
3. *APIs y servicios → Pantalla de consentimiento OAuth* → tipo **Externo** → completa nombre/app/email.
4. *Credenciales → Crear credenciales → ID de cliente de OAuth → Aplicación web*.
5. En **URIs de redireccionamiento autorizados** pega la que te daré (sale de tu Supabase, formato
   `https://TU-PROYECTO.supabase.co/auth/v1/callback`).
6. Te dará **Client ID** *(PÚBLICO)* y **Client Secret** *(SECRETO)*.
7. En Supabase → *Authentication → Providers → Google* → pegas ahí Client ID y Secret y guardas.

➡️ Necesito: que completes esto (te acompaño). El **Client ID** me lo puedes pegar; el **Secret** va
   directo en Supabase, no en el chat.

---

### 3) Código por correo (OTP)  → 1 ajuste de plantilla
La app pide un **código de 6 dígitos**. Por defecto Supabase envía un *enlace mágico*, así que hay
que decirle que mande el código:
- Supabase → **Authentication → Email Templates → "Magic Link"** → en el cuerpo del correo usa
  `{{ .Token }}` (el código de 6 dígitos). Ejemplo: *"Tu código de Origen es: **{{ .Token }}**"*.
- En **Authentication → Providers → Email**: deja activado *Enable Email provider* y
  *Allow new users to sign up*.

Supabase envía el correo **automáticamente** (sirve para empezar; con límite de unos pocos por hora).
- Para producción con muchos correos, conviene un SMTP propio (Resend o SendGrid, ambos con plan gratis).
- ➡️ Acción ahora: **ninguna**. Más adelante, si quieres, creas una cuenta en **https://resend.com**
  y me das su **API key** *(SECRETO → va en Supabase)*.

---

### 4) Cobro recurrente de Bs. 99/mes  → decisión importante (Bolivia)
Cobrar tarjetas de forma **automática cada mes** necesita una pasarela que "tokenice" la tarjeta.
Esto depende de Bolivia, así que necesito que elijas:

- **(a) Demo para inversionistas (sin dinero real):** uso **Stripe en modo prueba**.
  Me das claves de prueba `pk_test_...` *(PÚBLICO)* y `sk_test_...` *(SECRETO)*.
  Crear cuenta en https://stripe.com (modo test no requiere aprobación). Sirve para mostrar el flujo real
  de cobro recurrente, sin cobrar de verdad. ⚠️ Stripe **no liquida dinero en Bolivia**, por eso solo demo.

- **(b) Cobro real en Bolivia:** necesito el proveedor que tengas/consigas. Opciones que soportan
  tarjeta recurrente en la región: **dLocal** (cubre Bolivia), o el gateway de tu **banco/PSP local**.
  Para QR (pago único, no recurrente) está **QR Simple (BCB)**.
  ➡️ Dime **qué proveedor puedes usar** y te digo exactamente qué credenciales pedirles.

➡️ Necesito: que elijas **(a)** o **(b)**. Si dudas, empezamos con **(a) Stripe test** para el demo y
   dejamos **(b)** enchufable para cuando definas el proveedor boliviano. Lo construyo "pluggable" para
   no rehacer nada.

---

### 5) Notificaciones push al repartidor  → no necesitas nada
Lo resuelvo con **Web Push (VAPID)**: yo genero el par de llaves (pública/privada), no requiere cuenta
ni costo. (Si prefieres algo con panel visual, podemos usar **OneSignal** gratis y me das su App ID +
API key; pero no es necesario.)
- ➡️ Acción ahora: **ninguna.**

---

### 6) (Opcional) Dominio propio
La URL de Netlify/GitHub Pages funciona perfecto. Si quieres `app.origen.bo` o similar, me dices y
te guío para apuntarlo. No es necesario para empezar.

---

## Resumen de lo mínimo para arrancar
1. **Project URL + anon key** de Supabase  ← con esto solo, ya migro datos y empezamos.
2. Activar **Google** (punto 2) cuando quieras login real.
3. Elegir **(a) o (b)** para el cobro recurrente (punto 4).

Todo lo demás (esquema de base de datos, realtime, storage, push) lo armo yo.

---

## Cómo me lo entregas (seguro)
- **PÚBLICO** (Project URL, anon key, Client ID, pk_test): pégalo aquí en el chat.
- **SECRETO** (service_role, Client Secret, sk_test, API keys): **no lo pegues aquí.** Lo configuras
  tú en Supabase (Project Settings → *Edge Functions → Secrets*, o en *Authentication → Providers*),
  siguiendo mis pasos. Así nadie ve tus claves sensibles.

---

## Qué hago yo en cada fase (para que veas el plan)
1. **Conexión + datos:** creo el esquema (tablas + seguridad RLS) y migro productos/pedidos/suscriptores
   a Supabase. (Te dejo listo el archivo `supabase/schema.sql` para revisar.)
2. **Auth real:** reemplazo el login simulado por Supabase Auth (Google + OTP por correo de verdad).
3. **Realtime:** el pedido del cliente aparece en el celular del repartidor y del admin, en vivo.
4. **Storage:** las fotos que sube el admin se guardan en la nube (no en el dispositivo).
5. **Pagos:** conecto el proveedor elegido para el cobro recurrente de Bs. 99/mes + webhooks.
6. **Push:** el repartidor recibe la notificación aunque tenga la app cerrada.

Apenas me pases el **punto 1**, empiezo por las fases 1–3 (que ya dan el "wow" entre dispositivos).
