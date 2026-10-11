# JHAKORN Web v2 — Entrega 02: portada y menú lateral
Fecha: 2026-10-10
Rama: auditoria-web-v2-20261010
Estado: prototipo, no fusionado a producción.

## Cambios
- Portada renovada con títulos y contenido orientados a automatización, WPI, servicios y documentación.
- Estética azul marino y cian del sitio original, mismo SVG original `logo-jhakorn.svg`.
- Panel de muestra **HTML/CSS ilustrativo** del programa WPI, inspirado por la captura aportada; no debe confundirse con una captura auténtica. Sustituir por imagen completa y aprobada del WPI cuando se disponga del archivo publicable.
- Menú lateral plegable con grupos JHAKORN Tech, Servicios, Proyectos, Documentación y Contacto, enlaces funcionales a rutas existentes.
- Botón copiar comando PowerShell; solo copia texto, **nunca ejecuta código desde la web**.
- Cambio de enlace mailto de ejemplo inválido a ruta /contacto/, hasta verificar buzones reales.
- Anclas /servicios/#empaquetados y /servicios/#scripts.

## Validación pendiente antes de fusionar
- Probar en Cloudflare Pages Preview el diseño desktop y móvil, contraste, scroll, navegación por teclado, focus y Escape para cerrar menú.
- Abrir todos los enlaces, confirmar que Cloudflare genera rutas /tech/, /servicios/, /documentacion/, /contacto/ y que no aparecen errores de consola.
- Validar copy/paste con navigator.clipboard por HTTPS y la alternativa cuando se deniegue permiso.
- Comparar /wpi, /win, /ejem, /imp, /diag entre producción y preview, sin ejecutar comandos remotos.
- Confirmar texto público: no prometer funciones no verificadas; el mockup generado por IA es referencia de diseño y no material de producto.
- Incorporar captura completa real del WPI cuando el usuario la facilite; cuidar resolución y privacidad.
- Confirmar correo soporte@jhakorn.com/contacto@jhakorn.com antes de publicarlos.
- Evaluar si el menú lateral se restringe a escritorio y solo ciertas rutas tras feedback real.
## Archivos protegidos
No modificar: logo-jhakorn.svg, _redirects, scripts/wpi.ps1, scripts/bienvenida.ps1 ni demás endpoints.
