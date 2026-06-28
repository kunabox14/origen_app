// Service Worker ORIGEN — cache del shell para que la app funcione offline (PWA instalable).
const CACHE = "origen-v46";
const CORE = [
  "./",
  "./index.html",
  "./repartidor.html",
  "./proveedor.html",
  "./privacy-policy.html",
  "./terms-of-service.html",
  "./contact.html",
  "./manifest.json",
  "./supabase-config.js",
  // Supabase JS pre-cacheado en install → no hay petición de red en visitas de retorno
  "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js",
  "./assets/favicon.svg",
  "./assets/origen-logo.svg",
  "./assets/origen-logo-light.svg",
  "./assets/icon-192.png",
  "./assets/icon-512.png",
  "./assets/apple-touch-icon-180.png",
  "./assets/products/honey.svg",
  "./assets/products/grain.svg",
  "./assets/products/bottle.svg",
  "./assets/products/coffee.svg",
  "./assets/products/generic.svg"
];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(CORE)).then(() => self.skipWaiting()));
});
self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});
self.addEventListener("notificationclick", e => {
  e.notification.close();
  e.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then(list => {
      const open = list.find(c => c.url.includes(self.location.origin));
      if (open) return open.focus();
      return clients.openWindow("./");
    })
  );
});
self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  const isHTML = req.mode === "navigate" || url.pathname.endsWith(".html");
  // La config (claves, googleEnabled, links) NUNCA debe quedar vieja en caché.
  const isConfig = url.pathname.endsWith("supabase-config.js");
  // HTML y config: stale-while-revalidate — sirve desde caché al instante (visitas de retorno
  // son inmediatas) y actualiza en segundo plano. Seguro porque cada deploy sube CACHE version.
  if (isHTML || isConfig) {
    e.respondWith(
      caches.open(CACHE).then(cache =>
        cache.match(req).then(cached => {
          const fresh = fetch(req)
            .then(res => { if (res.ok) cache.put(req, res.clone()).catch(() => {}); return res; })
            .catch(() => null);
          return cached || fresh; // si hay caché → devuelve inmediato; red actualiza en fondo
        })
      )
    );
    return;
  }
  // Estáticos (íconos, logo, fuentes, CDN): cache-first.
  e.respondWith(
    caches.match(req).then(hit => hit || fetch(req).then(res => {
      const c = res.clone();
      if (res.ok && (url.origin === self.location.origin || /fonts|tailwind|jsdelivr/.test(req.url))) {
        caches.open(CACHE).then(ca => ca.put(req, c)).catch(() => {});
      }
      return res;
    }).catch(() => undefined)) // si un estático falla, deja que el navegador lo maneje (no devolver HTML)
  );
});
