# ORIGEN — Especificación de Producto (Master Spec)

> Documento maestro de producto: describe **cómo se comporta** la app ORIGEN (no el código).
> Complementa a `PROJECT_CONTEXT_HANDOFF.md` (estado técnico) y a la skill `origen-app`.
> Marca y estética: ver skill `origen-brand`. Responsable legal: **Kuna Box**.

**Qué es:** ecommerce de productos orgánicos en La Paz, Bolivia, con 3 apps conectadas
(Cliente, Proveedor, Repartidor) + Panel Admin. Modelo **multi-tienda**: las tiendas son
proveedores aprobados, cada uno con sucursales y stock propio. Logística **tienda→cliente**.

---

## 1. Flujos del cliente (panorama)

Pantallas principales: **Bienvenida → Registro/Login → Inicio → Tiendas → Tienda (catálogo) →
Carrito → Checkout → Confirmación → Seguimiento**. Transversales: Cuenta, Configuración,
Suscripción, Pedidos, Favoritos, Referidos, Yapas (recompensas), Soporte/Chat, Escáner QR.

**Onboarding:**
1. Bienvenida ("Comer mejor debería ser fácil") → **Empezar** o **Ya tengo cuenta**.
2. Login con **Google** (selector de cuenta forzado) o **correo + código OTP**.
3. Identidad verificada → Inicio.

**Navegación:** barra inferior (Inicio · Tiendas · Escáner · Cuenta) + **menú lateral** (☰) con
acceso a todas las secciones (y Panel Admin si el usuario es admin).

**Descubrimiento (Tiendas):**
- Las tiendas se muestran en **grilla de 2 columnas (scroll vertical)**, **agrupadas por zona de
  servicio** ("Tiendas en Miraflores", "Tiendas en Sopocachi", "Tiendas en Centro"…).
- **Filtro por zona** que prioriza la zona del cliente ("cerca de ti").
- **Tiendas favoritas** (estrella ❤) con acceso rápido arriba.
- Al **Visitar tienda** → catálogo de esa tienda, filtrable por 6 categorías: **Superfoods,
  Despensa, Snacks, Bebidas, Carnes vegetales, Granos**. Muestra el **horario de atención**.

**Regla global del carrito:** **un pedido = una sola tienda**. Si el cliente intenta agregar un
producto de otra tienda, se le ofrece vaciar la canasta y empezar con la nueva.

---

## 2. Compra suelta (entrega directa)

**Objetivo:** comprar productos de una tienda para entrega inmediata/programada simple.

**Flujo:**
1. En la tienda, el cliente usa el **stepper +/-** por producto (limitado por **stock
   disponible**). Productos agotados (stock 0) **no aparecen**; con 1 unidad muestran
   **"Última unidad"**, con 2–3 muestran **"Quedan N"**.
2. Va al **Carrito**. Tipo de pedido: **Directa**.
3. **Ubicación de entrega** (obligatoria, sin escribir a mano): **Mi ubicación (GPS)** o
   **Elegir en el mapa**. Se guardan coordenadas + dirección formateada.
4. **Referencias de entrega** (obligatorio): texto libre (ej. "portón verde, timbre 2").
5. **Fecha** y **horario** de entrega.
6. Resumen: subtotal, **descuento 12% solo si es suscriptor**, tarifa de servicio (Bs. 5),
   **delivery por distancia** (ver §6), total.
7. **Confirmar pedido → Checkout** (ver §7). Al pagar: se crea el pedido (#ORG-NNNNN), se
   **descuenta el stock** de la sucursal elegida y el pedido entra al flujo de entrega.

**Selección de sucursal:** el sistema elige automáticamente, dentro de la tienda, la sucursal
**con el pedido completo en stock** y **más cercana** al cliente. Esa sucursal es el **origen**
del pedido (el repartidor "Recoge en: [sucursal]").

---

## 3. Compra regalo

**Objetivo:** enviar productos de una tienda a otra persona (el receptor), no a uno mismo.

**Flujo:**
1. Mismos productos/stepper que la compra suelta.
2. En el Carrito, tipo de pedido: **Regalo**.
3. Campos del regalo:
   - **Nombre del receptor** (obligatorio).
   - **Ubicación del receptor**: **obligatoria, seleccionada en el mapa** (no GPS del comprador,
     porque el destino es de otra persona).
   - **Referencias** (obligatorio).
   - **Mensaje especial** (opcional; puede prellenarse con el mensaje de regalo predeterminado
     de la configuración).
4. Fecha/horario, resumen y checkout igual que la compra suelta.
5. El repartidor ve el pedido como **"🎁 para [receptor]"** con la dirección y referencias del
   receptor; la sucursal de origen se elige igual (más cercana **al destino del regalo**).

---

## 4. Suscripción (Bs. 99/mes)

**Objetivo:** canasta orgánica recurrente con beneficios; cobro recurrente mensual.

**Propuesta de valor (lo que ve el no suscrito):**
- **12% de descuento permanente** en cada compra.
- Entregas **semanales, quincenales o mensuales**.
- Editar la caja hasta 2 h antes.

**Beneficio diferencial (regla clave):** el **descuento del 12% aplica SOLO a suscriptores**.
- No suscrito en el carrito: *"Si estuvieras suscrito, ahorrarías Bs. X en esta compra"*.
- Suscriptor: *"Gracias a tu suscripción, estás ahorrando Bs. X"* (descuento aplicado al total).

**Activación:**
- **"Suscribirme"** lleva al **Stripe Payment Link** (modo prueba) o usa la tarjeta ya
  registrada. Al volver del pago (`?sub=ok`) se activa la suscripción.
- Estados de suscripción: **Ninguna** (por defecto), **Activa**, **Pausada**, **Cancelada**.
  Nunca se activa sola; siempre requiere acción del usuario.

**Pedidos programados/recurrentes:**
- El cliente arma su canasta de suscripción y elige frecuencia.
- "Pagar ahora" carga la canasta y aplica el descuento correspondiente.
- Las **entregas programadas pagadas por adelantado** aparecen en el Panel Admin → **Por
  entregar** (etiqueta "Programado · prepagado").
- Cobro recurrente: **Bs. 99/mes** a la tarjeta registrada (tokenizada; ver §7). Se puede
  pausar/cancelar cuando se quiera.

---

## 5. Google Maps (ubicación)

**Principio:** el usuario **nunca escribe la dirección a mano**; siempre selecciona en mapa o
usa GPS. Toda dirección guarda **coordenadas (lat/lng)** + dirección formateada (Geocoder).

**Dónde se usa:**
- **Checkout (entrega directa):** botones "Mi ubicación (GPS)" / "Elegir en el mapa".
- **Regalo:** ubicación del receptor obligatoria **por mapa**.
- **Dirección favorita** (Configuración del cliente): se fija por GPS/mapa y se **autocompleta
  en el checkout** y los próximos pedidos.
- **Proveedor:** ubicación del negocio y de cada **sucursal** se fija en mapa (con GPS de
  respaldo); incluye **zona** para catalogar la tienda.
- **Repartidor:** registra su ubicación al inscribirse; comparte ubicación **en vivo** durante
  la entrega (para el mapa de seguimiento del cliente).

**Detalles técnicos de producto:**
- Carga dinámica de Google Maps JS API; si el mapa no carga, **GPS funciona como respaldo**.
- Distancias y ETA se calculan con **haversine** entre coordenadas.

---

## 6. Delivery (logística y tarifas)

**Modelo:** **tienda→cliente**. El origen de cada pedido es la **sucursal seleccionada**
(la más cercana con stock completo), no un almacén central. Los productos de la tienda virtual
oficial **"Origen"** (sin proveedor) usan el almacén central.

**Tarifa por distancia (sucursal → cliente):**

| Distancia | Costo |
|---|---|
| 0 – 800 m | Bs. 5 |
| 800 m – 1.5 km | Bs. 10 |
| 1.5 – 2.5 km | Bs. 15 |
| 2.5 km en adelante | Bs. 18 |

- La tarifa se **recalcula** al fijar/cambiar la ubicación del cliente.
- Tarifa de servicio fija adicional: **Bs. 5** (uso de la app).

**Estados del pedido (entrega):** Nuevo → **Asignado** → **Recogido** → **En camino** →
**Entregado** (o Cancelado). El cliente ve el **seguimiento en vivo** con la ubicación del
repartidor y ETA.

**Estado de preparación (lado tienda):** **Pendiente → En preparación → Listo** (lo marca el
proveedor desde su banner de pedido).

**Repartidor:**
- Ve solo pedidos **sin asignar**; al aceptar uno, se le asigna; los entregados desaparecen.
- Ve **"Recoger en: [sucursal]"** + datos del cliente/receptor + referencias.
- Avanza estados; comparte ubicación en vivo; ve sus **ganancias** (suma de delivery).
- El chat con el cliente se habilita **solo tras aceptar** el pedido.

---

## 7. Pagos

**Estado actual: SIMULADO** (listo para conectar pasarela real). Modelo de seguridad ya aplicado.

**Métodos (configurables por el admin):** **QR Simple** y/o **Tarjeta**. El admin define qué
métodos ve el cliente y el **nombre del comercio**; esta config se sincroniza por Supabase (todos
los clientes la respetan).

**Checkout:**
- QR: muestra un QR decorativo con el comercio y el monto.
- Tarjeta: el cliente ingresa la tarjeta y **autoriza** el cobro.

**Tarjetas guardadas (tokenización):**
- Se guarda **solo**: token, marca (Visa/Mastercard/Amex), **últimos 4 dígitos**, vencimiento.
- **Nunca** se almacena el número completo (PAN) ni el CVV.
- Cada cobro requiere **autorización explícita** del usuario y sesión autenticada.
- Cobro recurrente de la suscripción (Bs. 99/mes) usa la tarjeta tokenizada.

**Seguridad (mostrada al usuario en Configuración):** "tokenización; no guardamos número
completo ni CVV; cada cobro requiere tu autorización; viaja cifrado por HTTPS".

**Pendiente para producción:** conectar **pasarela real** (Libélula / QR Simple) con tokenización
real vía **Supabase Edge Function** (el secreto NO va en el cliente estático). Hay un prompt
preparado para esa tarea.

---

## 8. Chat

**Canales:**
1. **Chat de pedido** (cliente ↔ repartidor): se habilita **solo después de que el repartidor
   acepta** el pedido. Mensajes en tiempo real (tabla `messages`, Supabase Realtime) +
   **notificación push** de mensajes nuevos.
2. **Soporte** (cliente ↔ equipo Origen): formulario que crea un **ticket** (#TK-NNNNN). El
   cliente ve sus tickets y la respuesta del equipo en **"Mis tickets"**. El admin abre cada
   ticket, **responde** y cambia el **estado** (Abierto → En proceso → Resuelto → Cerrado).

**Seguridad / reglas:** usuario autenticado, HTTPS, control de permisos. **Pendiente para
producción:** rate limiting / anti-spam (requiere Edge Function).

---

## 9. Notificaciones

**Política (v2.0):** las notificaciones son **automáticas y siempre activas** — se eliminó el
toggle de configuración. `notifications_enabled = true` por defecto.

**Siempre activas:**
- **Confirmaciones de pedido** y cambios de estado de entrega.
- **Seguridad** (login, pagos).
- **Estados del servicio**.
- Avisos operativos: nuevo pedido (repartidor), pago/pedido nuevo (admin), pedido por preparar
  (proveedor), mensajes de chat.

**Implementación actual:** API de Notificaciones del navegador (se pide permiso al usar la app).
**Pendiente para producción:** push real (Web Push / FCM) para llegar con la app cerrada.

---

## 10. UX

- **Sin escribir direcciones a mano** (mapa/GPS). Reduce fricción y errores.
- **Una tienda por pedido** (claridad de origen y logística).
- **Stepper con límite de stock** y etiquetas de escasez ("Última unidad").
- **Estados visuales claros**: banner "Pedido por preparar" (proveedor, alto contraste con punto
  pulsante), barra de progreso preparación, seguimiento en vivo (cliente).
- **Estados vacíos amables** (ej. sin tiendas favoritas).
- **Validaciones visibles** con toast + scroll al error.
- **Tiempo real** en las 3 apps (pedidos, stock, aprobaciones, chat) sin recargar.
- **PWA instalable**, funciona offline-degradado (nunca se rompe si falla la red).
- **Navegación**: barra inferior + menú lateral; cada vista es una "pantalla" con transición
  suave.
- **Confirmaciones** antes de acciones destructivas (vaciar canasta, eliminar producto/tienda).

---

## 11. Branding

> Detalle completo en la skill **origen-brand**. Resumen operativo:

- **Identidad:** premium, natural, "Organic Vitality". **NO** debe parecer app de delivery
  masivo. Empresa/marca: **Kuna Box / ORIGEN**.
- **Logo oficial:** `assets/origen-logo.svg` (oscuro) y `origen-logo-light.svg` (claro). Ícono =
  círculo con hoja verde; wordmark "Origen." con punto. **Nunca** distorsionar, recolorear ni
  reemplazar.
- **Color clave:** verde de marca (`#5EBC66` hoja / `#006e24` secundario) para CTAs y acentos;
  fondos crema (`#F5F2EB`) / superficies claras; verde oscuro (`#0A130D`) para texto/énfasis.
- **Tipografía:** **EB Garamond** (titulares, serif elegante) + **Hanken Grotesk** (texto/UI).
- **Tono:** cercano pero profesional, consciente y transparente. Palabras clave: orgánico,
  trazabilidad, origen, frescura, sin intermediarios, comunidad.
- **Tagline de bienvenida:** "Comer mejor debería ser **fácil**." / "Llevamos la frescura desde
  el Origen a tu mesa, con la transparencia que tu salud merece."
- **Consistencia:** misma paleta, tipografías e íconos (Material Symbols) en cliente, proveedor,
  repartidor, panel admin y páginas legales.

---

## Apéndice — Reglas de negocio resumidas

- 1 pedido = 1 tienda.
- Descuento 12% = beneficio exclusivo del suscriptor.
- Stock 0 → producto invisible; cantidad en carrito ≤ stock; stock se descuenta al pagar.
- Delivery por tramos de distancia (5/10/15/18 Bs) + Bs. 5 de servicio.
- Tienda = proveedor aprobado; al aprobarlo se publican sus productos.
- Sucursal de origen = la más cercana con el pedido completo.
- Direcciones siempre con coordenadas (mapa/GPS).
- Pagos sin guardar PAN/CVV; cada cobro requiere autorización.
- Notificaciones automáticas, siempre activas.
- Responsable legal: Kuna Box. Estética premium, logo intocable.
