// Configuración de Supabase para ORIGEN.
// La URL y la anon key son PÚBLICAS (seguras en el navegador): la seguridad real
// la dan las políticas RLS de la base de datos, no el secreto de esta clave.
window.ORIGEN_SB_CONFIG = {
  url: "https://fjlqwhcxwjasngbdgwia.supabase.co",
  anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqbHF3aGN4d2phc25nYmRnd2lhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyMzYwNjUsImV4cCI6MjA5NzgxMjA2NX0.kGEwCGCQdw65D59ZgEHUr6qMXxWWZYRDKVBlchFX0qs",
  // Pon en true SOLO cuando hayas activado el proveedor Google en Supabase
  // (Authentication → Providers → Google). Mientras esté en false, el botón
  // de Google guía a entrar por correo y no muestra el error de Supabase.
  googleEnabled: false
};

// Inicializa el cliente si la librería cargó. Si no hay red/config, queda null
// y la app sigue funcionando en modo local (sin romper el demo).
window.ORIGEN_SB = (window.supabase && window.ORIGEN_SB_CONFIG.url.startsWith("https://"))
  ? window.supabase.createClient(window.ORIGEN_SB_CONFIG.url, window.ORIGEN_SB_CONFIG.anonKey, {
      auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true }
    })
  : null;
