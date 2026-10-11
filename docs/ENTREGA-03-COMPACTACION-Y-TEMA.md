# JHAKORN Web v2 — Entrega 03: compactación y tema compartido

Fecha: 2026-10-10. Rama de pruebas `auditoria-web-v2-20261010`.

## Objetivo
Reducir la saturación y altura de la portada, moderar tamaño/perspectiva del WPI y sustituir el fondo plano de páginas internas por el lenguaje visual azul marino/cian. Conservar logo SVG original y rutas PowerShell.

## Implementado
- Ajustes de dimensiones, tipografía y espaciado de la portada en `diseno-referencia.css`.
- Ventana WPI estilizada con efecto de perspectiva moderada. Sigue siendo una representación HTML, no captura auténtica: sustituir tras recibir y publicar el recurso real autorizado.
- Tarjetas inferiores más compactas.
- Hero de todas las páginas internas mucho más corto, con menos espacio vacío, fondos degradados, elementos geométricos tenues y tarjetas coherentes con inicio.
- Las cinco páginas internas incluyen ahora la hoja `diseno-referencia.css`.

## Comprobaciones antes de `main`
- Validar visualmente en Cloudflare Preview a tamaños de escritorio y móvil (no se han ejecutado pruebas de navegador en esta entrega).
- Comprobar scroll, legibilidad de WPI, menú, tema claro/oscuro, teclado y contraste.
- Comprobar destinos de vínculos y respuestas de `/wpi`, `/win`, `/ejem`, `/imp`, `/diag` frente a producción. No ejecutar scripts en auditoría.
- Revisar si al reducir el WPI su texto se hace ilegible: prioridad a captura ampliable con texto real, sin saturar el hero.
- Mantener la publicación de `main` pendiente de aprobación.
