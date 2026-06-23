# Publicar ORIGEN en HTTPS e instalarla en el celular

La app ya es 100% estática (no necesita el servidor Node, eso era solo para probar local).
Para instalarla como app en el celular necesita una **URL https**. Elige UNA opción.

---

## Opción A · Netlify Drop  ⭐ (la más rápida, sin cuenta técnica, ~1 min)

1. En tu **PC**, abre: **https://app.netlify.com/drop**
2. Abre el Explorador de archivos en `C:\Users\HP\Desktop\` y **arrastra la carpeta `ORIGEN APP`** completa a esa página web.
3. Espera unos segundos. Netlify te dará una URL https, por ejemplo:
   `https://origen-app-xxxx.netlify.app`
4. (Opcional) Crea una cuenta gratis para que la URL no expire y poder ponerle un nombre bonito
   (Site settings → Change site name → `origen-app`).
5. Abre esa URL **en el celular** e instálala (ver "Instalar en el celular" abajo).

> La app de repartidor queda en `…netlify.app/repartidor.html`.

**Para actualizar después:** vuelve a https://app.netlify.com/drop y arrastra la carpeta otra vez
(o, con cuenta, arrastra sobre el sitio existente).

---

## Opción B · GitHub Pages (URL permanente bajo tu cuenta `kunabox14`)  ✅ ya subido

El código **ya está subido** a tu repo: https://github.com/kunabox14/origen_app (rama `main`).
Solo falta activar Pages (1 clic):

1. Entra a **https://github.com/kunabox14/origen_app/settings/pages**
2. En **Build and deployment → Source** elige **Deploy from a branch**.
3. En **Branch** elige **main** y carpeta **/ (root)** → **Save**.
4. En 1–2 minutos tu app estará en:
   **https://kunabox14.github.io/origen_app/**
   (la app de repartidor en `…/origen_app/repartidor.html`)

**Para actualizar después** (desde la carpeta del proyecto): `git add -A && git commit -m "update" && git push`

---

## Instalar en el celular (Android / iPhone)

Abre la URL https en el navegador del celular y:

- **Android (Chrome):** menú ⋮ → **Instalar aplicación** (o "Agregar a pantalla principal").
- **iPhone (Safari):** botón **Compartir** → **Agregar a inicio**.

Aparecerá el ícono de ORIGEN (círculo negro + semilla verde) en la pantalla de inicio y abrirá a
pantalla completa, como una app nativa. Funciona offline una vez abierta.

---

## ¿Y la APK?
Con la app ya publicada en https (cualquiera de las opciones), puedes generar un `.apk` real entrando
a **https://www.pwabuilder.com**, pegando tu URL y descargando el paquete de Android. (Detalles en `MANUAL.md`.)
