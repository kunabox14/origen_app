// Configuración de Supabase para ORIGEN.
// La URL y la anon key son PÚBLICAS (seguras en el navegador): la seguridad real
// la dan las políticas RLS de la base de datos, no el secreto de esta clave.
window.ORIGEN_SB_CONFIG = {
  url: "https://fjlqwhcxwjasngbdgwia.supabase.co",
  anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqbHF3aGN4d2phc25nYmRnd2lhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyMzYwNjUsImV4cCI6MjA5NzgxMjA2NX0.kGEwCGCQdw65D59ZgEHUr6qMXxWWZYRDKVBlchFX0qs",
  // Pon en true SOLO cuando hayas activado el proveedor Google en Supabase
  // (Authentication → Providers → Google). Mientras esté en false, el botón
  // de Google guía a entrar por correo y no muestra el error de Supabase.
  googleEnabled: true,
  // Link de pago de Stripe (modo prueba) para la suscripción de Bs. 99/mes.
  // En el dashboard de Stripe, configura el redireccionamiento tras el pago a:
  //   https://kunabox14.github.io/origen_app/?sub=ok
  stripeLink: "https://buy.stripe.com/test_7sY9AU4tJ0QH9TWd999k400",
  // Google Maps JavaScript API (restringida al dominio kunabox14.github.io)
  mapsKey: "AIzaSyCqLzM4zQiGiynYwv6qmT4OVrShQ69I91Y"
};

// Inicializa el cliente si la librería cargó. Si no hay red/config, queda null
// y la app sigue funcionando en modo local (sin romper el demo).
window.ORIGEN_SB = (window.supabase && window.ORIGEN_SB_CONFIG.url.startsWith("https://"))
  ? window.supabase.createClient(window.ORIGEN_SB_CONFIG.url, window.ORIGEN_SB_CONFIG.anonKey, {
      auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true }
    })
  : null;
