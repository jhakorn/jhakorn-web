# JHAKORN Web v2 — Entrega 01: prototipo multipágina
Fecha: 2026-10-10
Estado: prototipo en rama aislada, **no desplegado ni validado en navegador**.

## Implementado
- Secciones nuevas: /tech/, /servicios/, /proyectos/, /documentacion/ y /contacto/.
- Menú de la portada enlazado a páginas internas, sin eliminar sus secciones originales.
- CSS complementario `estilos-paginas.css` que reutiliza `jhakorn-proyecto.css` y sus variables.
- JS separado `scripts/paginas.js` para tema, menú y copia del comando.
- Favicon y marca reutilizan exactamente `logo-jhakorn.svg`; no se generaron imágenes artificiales.
- Sitemap de borrador ampliado a seis direcciones, **pendiente de despliegue**.

## Prohibiciones preservadas
- No se modificaron `_redirects`, `/scripts/wpi.ps1` ni otros scripts PowerShell.
- El enlace de lanzamiento se mantiene en `irm https://jhakorn.com/wpi | iex`.
- No se publicaron credenciales, imágenes privadas ni instaladores.
- No se ha modificado `main` ni el sitio público.

## Validación estática realizada
- Todos los HTML y sus activos nuevos existen en rama.
- Cada HTML nuevo usa `/logo-jhakorn.svg`, `/jhakorn-proyecto.css`, `/estilos-paginas.css` y `/scripts/paginas.js`.
- `_redirects` y `logo-jhakorn.svg` permanecen como ficheros existentes, sin edición.
- No se han ejecutado pruebas HTTP reales ni navegador. El lector externo no pudo cargar jhakorn.com durante esta sesión.

## Antes del merge
1. Activar revisión de Cloudflare Pages Preview (si hay integración) y comprobar /tech/ y demás páginas reales.
2. Comparar HTTP status, body hash y Content-Type de /wpi, /win, /ejem, /imp y /diag tanto en producción como preview. Algunos destinos no se encontraron en el repositorio; distinguir reglas activas de rutas faltantes.
3. Inspeccionar modo claro/oscuro, menú móvil, teclado y contraste en Chrome/Firefox y móviles.
4. Verificar el botón de copiar con contexto seguro HTTPS y degradación cuando clipboard no esté disponible.
5. Revisar texto público de productos: evitar proclamar versiones o disponibilidad no comprobadas.
6. Confirmar entrega/SMTP antes de activar contacto@jhakorn.com o soporte@jhakorn.com; sustituir ejemplo@gmail.com en portada entonces.
7. Confirmar sitemap y canonical una vez que las URLs existan en Cloudflare Pages.
8. Solo fusionar a main tras aprobar los resultados y revisar la vista previa.

## Próximas iteraciones
- Layout compartido sin duplicación de cabecera y pie.
- Páginas individuales /tech/centro-de-control/, /servicios/empaquetados/ y /servicios/scripts/.
- Contenido real: capturas autorizadas, manuales Markdown públicos y versiones validadas.
- Formularios y antispam si se decide envío real.
- Pruebas automáticas de rutas y disponibilidad de recursos.
