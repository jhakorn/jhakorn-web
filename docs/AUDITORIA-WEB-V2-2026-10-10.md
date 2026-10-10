# JHAKORN Web v2 — Auditoría inicial y plan de modernización
Fecha: 2026-10-10
Estado: auditoría estática parcial; cambios funcionales no autorizados ni ejecutados.
Repositorio: https://github.com/jhakorn/jhakorn-web
Rama base: main (376067a359c42b1d1b39da55844bc878c2d86a3f)

## Objetivo
Evolucionar el sitio actual a un portal multipágina de JHAKORN, conservando **exactamente** el logo SVG y la identidad visual, con secciones Tech/Centro de Control, scripts, empaquetados, servicios, documentación, proyectos, laboratorio y contacto. No rediseñar la marca ni usar imágenes genéricas generadas por IA como sustituto de evidencias reales.

## Evidencia revisada (rama main)
- `index.html`: una página con enlaces ancla #servicios, #proceso, #perfil y #contacto, hero, tarjetas, proceso, perfil y formulario que prepara WhatsApp.
- `jhakorn-proyecto.css`: CSS propio, paleta principal #071b2b, secundaria #123b5d, acentos #0891b2 y #67e8f9; fuentes Segoe UI/Arial, barra sticky, orbita y animaciones, diseño responsive, tema oscuro y prefers-reduced-motion.
- `jhakorn-proyecto.js`: menú móvil, tema guardado en localStorage, formulario de WhatsApp con validación y año automático. Los selectores son globales y asumen que todos los controles existen en la página; al introducir otras páginas se debe modularizar o proteger las inicializaciones.
- `logo-jhakorn.svg`: J en hexágono con conexiones electrónicas; preservar bytes/diseño del logo.
- `_redirects`: /wpi -> /scripts/wpi.ps1, /win -> /scripts/bienvenida.ps1, /ejem -> /scripts/ejemplo.ps1, /imp -> /scripts/impresoras.ps1, /diag -> /scripts/diagnostico.ps1 (todos 200).
- `scripts/wpi.ps1`: fuente de desarrollo con aviso explícito de que no necesariamente está publicada; preservar y no reemplazar sin aprobación del flujo WPI.
- `scripts/bienvenida.ps1`: existe.
- `robots.txt`: referencia a sitemap.xml.
- `sitemap.xml`: solo contiene la portada (lastmod 2026-08-16).
- `.gitignore`: ignora .env y archivos temporales.
- No encontrados en rutas consultadas: README.md, package.json, 404.html, _headers, LICENSE, .github/workflows/deploy.yml; tampoco scripts/ejemplo.ps1, scripts/impresoras.ps1 ni scripts/diagnostico.ps1. **Esto NO prueba fallo en producción**: pueden existir reglas o activos externos.

## Hallazgos priorizados
1. P0 compatibilidad: preservar /wpi y demás rutas de scripts; comparar respuestas reales producción y preview, status, Content-Type, cuerpo, redirecciones, hash y comportamiento PowerShell. No usar fallback SPA que devuelva HTML en URLs de scripts. NO ejecutar el bootstrap en la auditoría.
2. P0 marca: conservar logo-jhakorn.svg, paleta, modo oscuro, fondo geométrico y componentes visuales. Preferir capturas auténticas e imágenes propias con autorización y sin datos privados.
3. P1 errores evidentes: index.html muestra mailto:ejemplo@gmail.com. Actualizar solamente después de confirmar el enrutamiento de contacto@jhakorn.com y soporte@jhakorn.com.
4. P1 arquitectura multipágina: menú actual solo usa anclas; crear rutas reales, enlaces absolutos/relativos correctos y navegación accesible en móvil.
5. P1 JavaScript: suponer controles presentes rompe una página nueva sin formulario o navegación; separar lógica común de la lógica exclusiva de la portada y comprobar null.
6. P1 SEO: sitemap ampliable para nuevas URLs, metadatos únicos, canonical, Open Graph, robots y página 404.
7. P1 formulario: el formulario NO envía correo, solo genera enlace de WhatsApp. Mantener esto explícito y ofrecer email/formulario solo con backend y antispam apropiados.
8. P2 calidad: tests básicos de enlaces, accesibilidad, dispositivos móviles, contraste, pesos de recursos, reducción de movimiento y errores de consola.

## Arquitectura sugerida (no implementada)
- / — portada integral, servicios y proyectos destacados
- /tech/ — portal JHAKORN Tech
- /tech/centro-de-control/ — PowerShell `irm https://jhakorn.com/wpi | iex`, requisitos, procedencia, advertencias y documentación; solo dirigir al endpoint existente
- /tech/scripts/ — fichas de scripts publicados y verificados
- /tech/herramientas/ — catálogo y descargas aprobadas
- /servicios/ — soporte PC/impresoras/electrónica/redes/remoto
- /servicios/empaquetados/ — empaquetados personalizados sujetos a licencias
- /servicios/scripts/ — automatizaciones PowerShell personalizadas
- /proyectos/ — WPI, laboratorio Linux/Docker, redes y electrónica (contenido público autorizado)
- /documentacion/ — guías Markdown públicas, distinguidas de documentación interna
- /acerca/ y /contacto/

## Reglas de implementación
- No cambiar archivos de /scripts, _redirects ni activos del bootstrap durante la fase visual.
- No subir instaladores de terceros ni claves, cuentas, rutas internas o documentación privada.
- Seguir con HTML/CSS/JS estático como opción base; evaluar Astro solo si la cantidad y mantenimiento de páginas/Markdown lo justifican.
- Dividir CSS en tokens globales/componentes/páginas sin alterar la apariencia; preservar diseño original del logo.
- Trabajo en rama y vista previa antes de fusionar. Comprobar flujos existentes contra main y producción.
- Mantener documentación sincronizada y un registro de decisiones; no confundir prototipos con herramientas distribuidas.

## Próximas tareas
1. Inventario completo de árbol del repositorio y verificación de despliegue Cloudflare Pages, dominios y rutas; determinar diferencia entre repo y producción.
2. Pruebas de red y navegador del sitio publicado, incluyendo móvil y auditoría de accesibilidad; el lector web no pudo acceder al dominio el 2026-10-10.
3. Matriz de regresión para los cinco endpoints PowerShell y recursos existentes.
4. Diseñar layout compartido y navegación multipágina usando identidad actual; construir preview sin afectar producción.
5. Preparar contenido público validado y habilitar contacto@jhakorn.com y soporte@jhakorn.com solo al verificar correo.

## Alcance de esta entrega
Solo documentación. No se modifican HTML, CSS, JS, SVG, redirects, PowerShell, dominios ni producción.
