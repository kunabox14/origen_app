// Service Worker ORIGEN — cache del shell para que la app funcione offline (PWA instalable).
const CACHE = "origen-v29";
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
self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  const isHTML = req.mode === "navigate" || url.pathname.endsWith(".html");
  // La config (claves, googleEnabled, links) NUNCA debe quedar vieja en caché.
  const isConfig = url.pathname.endsWith("supabase-config.js");
  // HTML y config: network-first (siempre la última versión; cache solo como respaldo offline).
  if (isHTML || isConfig) {
    e.respondWith(
      fetch(req).then(res => { const c = res.clone(); caches.open(CACHE).then(ca => ca.put(req, c)).catch(() => {}); return res; })
        .catch(() => caches.match(req).then(r => r || caches.match("./index.html")))
    );
    return;
  }
  // Estáticos (íconos, logo, fuentes, CDN): cache-first.
  e.respondWith(
    caches.match(req).then(hit => hit || fetch(req).then(res => {
      const c = res.clone();
      if (res.ok && (url.origin === self.location.origin || /fonts|tailwind/.test(req.url))) {
        caches.open(CACHE).then(ca => ca.put(req, c)).catch(() => {});
      }
      return res;
    }).catch(() => caches.match("./index.html")))
  );
});
