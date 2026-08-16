$ErrorActionPreference = 'Stop'

$raizProyecto = Split-Path -Parent $PSScriptRoot
$carpetaCurso = Join-Path $raizProyecto 'curso'

$clases = @(
    @{ N=1; T='Fundamentos y estructura mínima'; O='Comprender qué es HTML y construir el esqueleto básico de una página.'; Temas=@('Declaración <!DOCTYPE html> y documento HTML5','Elemento raíz <html> y atributo lang','Metadatos dentro de <head>','Contenido visible dentro de <body>','Títulos con <h1> y párrafos con <p>'); Claves=@('HTML describe la estructura y el significado del contenido; no es un lenguaje de programación.','<!DOCTYPE html> informa al navegador que se usa HTML5.','lang="es" ayuda a lectores de pantalla, buscadores y traductores.','UTF-8 permite representar correctamente acentos, eñes y otros caracteres.','viewport adapta el ancho de la página a celulares.','Debe existir un título de pestaña claro mediante <title>.') },
    @{ N=2; T='Textos, jerarquía y comentarios'; O='Organizar contenido escrito con títulos, párrafos, énfasis y saltos de línea.'; Temas=@('Jerarquía de encabezados <h1>, <h2> y <h3>','Comentarios HTML <!-- ... -->','Énfasis semántico con <strong> y <em>','Salto de línea con <br>'); Claves=@('Use un solo <h1> que describa el tema principal y continúe la jerarquía sin elegir niveles solo por su tamaño.','Los comentarios sirven para documentar el código y no aparecen en la página.','<strong> indica importancia y <em> énfasis; ambos aportan significado además de su apariencia.','<br> es apropiado para una ruptura necesaria dentro de un texto, no para crear espacio visual.','La presentación visual se controlará después con CSS.') },
    @{ N=3; T='Enlaces y botones'; O='Conectar páginas, recursos externos y acciones de contacto.'; Temas=@('Enlace interno con ruta relativa','Enlace externo y nueva pestaña','Protocolos mailto: y tel:','Botón <button>'); Claves=@('<a> crea un hipervínculo y href indica el destino.','Una ruta como clase-02.html busca el archivo en la misma carpeta.','target="_blank" abre otra pestaña; rel="noopener noreferrer" protege la página de origen.','mailto: abre la aplicación de correo y tel: permite iniciar una llamada en dispositivos compatibles.','Un botón no navega por sí solo: necesita un formulario o JavaScript para ejecutar una acción.','El texto del enlace debe describir claramente su destino.') },
    @{ N=4; T='Imágenes accesibles'; O='Insertar imágenes locales con dimensiones, texto alternativo y pie descriptivo.'; Temas=@('Elemento <img> y atributo src','Texto alternativo alt','Dimensiones width y height','Agrupación con <figure> y <figcaption>'); Claves=@('<img> es un elemento vacío: no necesita etiqueta de cierre.','src contiene la ruta del archivo; aquí es una imagen SVG local.','alt comunica el contenido o función a quien no puede ver la imagen.','width y height reservan espacio y reducen saltos visuales mientras carga.','<figure> agrupa contenido autónomo y <figcaption> ofrece una descripción visible.','Una imagen decorativa debe usar alt=""; una imagen informativa necesita un texto útil.') },
    @{ N=5; T='Listas y tablas'; O='Representar colecciones, secuencias, definiciones y datos tabulares.'; Temas=@('Lista sin orden <ul>','Lista ordenada <ol>','Lista descriptiva <dl>','Tabla con caption, thead y tbody','Filas <tr>, encabezados <th> y celdas <td>'); Claves=@('<ul> sirve cuando el orden no cambia el significado; <ol>, cuando la secuencia importa.','<dl> relaciona términos <dt> con descripciones <dd>.','Las tablas son para datos relacionados, no para diseñar la distribución de la página.','<caption> explica el propósito de la tabla.','scope="col" vincula cada encabezado con su columna y mejora la accesibilidad.','<thead> y <tbody> hacen explícita la estructura de los datos.') },
    @{ N=6; T='Formularios'; O='Capturar datos mediante controles accesibles y validación básica del navegador.'; Temas=@('Formulario <form>, action y method','Etiquetas <label> e inputs','Tipos text, email, tel, radio y checkbox','Lista <select> y <option>','Área <textarea>','Agrupación <fieldset> y <legend>','Botones submit y reset','Validación required'); Claves=@('Cada control debe tener name para que su valor sea enviado.','El for de <label> debe coincidir con el id del control.','El tipo email activa validación básica y teclados apropiados en móviles.','Los radios con el mismo name forman un grupo de elección única.','required impide el envío vacío, pero un sistema real también valida en el servidor.','method="get" coloca los datos en la URL y no es adecuado para información sensible.','action vacío envía a la misma página; esta práctica no almacena los datos.') },
    @{ N=7; T='HTML semántico y accesibilidad'; O='Dividir una página en regiones con significado para usuarios, buscadores y tecnologías de asistencia.'; Temas=@('Regiones header, nav, main y footer','Secciones <section> y contenidos <article>','Contenido complementario <aside>','Navegación interna con identificadores','Descripción meta y atributos ARIA'); Claves=@('<header> presenta la página; <nav> agrupa la navegación principal.','<main> contiene el contenido principal y normalmente aparece una sola vez.','<section> agrupa un tema; suele incluir un encabezado.','<article> identifica una unidad reutilizable o independiente.','<aside> contiene información relacionada pero secundaria.','<footer> reúne cierre, autoría o enlaces finales.','href="#servicios" lleva al elemento id="servicios".','aria-label distingue una región cuando hace falta un nombre accesible.') },
    @{ N=8; T='Proyecto integrador: página completa'; O='Combinar en una sola página todos los componentes estudiados en las clases anteriores.'; Temas=@('Estructura semántica completa','Menú de navegación interno','Presentación con imagen accesible','Servicios mediante artículos y listas','Proceso con lista y tabla','Consejo complementario','Formulario de contacto','Pie y enlaces de retorno'); Claves=@('La página reúne contenido, navegación y captura de datos siguiendo una jerarquía coherente.','aria-labelledby conecta la sección con el título que la nombra.','Los id deben ser únicos y pueden servir como destinos de navegación y asociaciones accesibles.','La tabla resume modalidades; la lista explica el proceso paso a paso.','El formulario aún es demostrativo: para funcionar requiere un servidor o servicio que procese el envío.','El resultado es HTML puro; CSS puede añadirse después sin cambiar su estructura semántica.') }
)

function Encode([string]$text) { [System.Net.WebUtility]::HtmlEncode($text) }
function Items($values) { '<ul>' + (($values | ForEach-Object { '<li>' + (Encode $_) + '</li>' }) -join '') + '</ul>' }

$secciones = foreach ($c in $clases) {
    $archivo = ('clase-{0:d2}.html' -f $c.N)
    $rutaClase = Join-Path $carpetaCurso $archivo
    $codigo = Get-Content -LiteralPath $rutaClase -Raw -Encoding UTF8
    @"
<section class="clase">
  <div class="kicker">CLASE $($c.N) · HTML DESDE CERO</div>
  <h1>$($c.T)</h1>
  <p class="objetivo"><strong>Objetivo:</strong> $($c.O)</p>
  <h2>Contenido de la clase</h2>
  $(Items $c.Temas)
  <h2>Explicación y buenas prácticas</h2>
  $(Items $c.Claves)
  <h2>Código completo</h2>
  <pre><code>$(Encode $codigo)</code></pre>
  <div class="practica"><strong>Práctica sugerida:</strong> abre <code>$archivo</code> en el navegador, modifica textos y valores, guarda el archivo y recarga la página. Revisa que la estructura y la accesibilidad se conserven.</div>
</section>
"@
}

$fecha = Get-Date -Format 'dd/MM/yyyy'
$html = @"
<!doctype html>
<html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Curso de HTML desde cero · Clases 1 a 8</title>
<style>
@page { size:A4; margin:15mm 14mm 16mm; }
* { box-sizing:border-box; }
body { margin:0; color:#172033; font-family:Arial,Helvetica,sans-serif; line-height:1.46; font-size:10.5pt; }
.portada { min-height:255mm; display:flex; flex-direction:column; justify-content:center; padding:18mm; background:linear-gradient(145deg,#071a33,#0b4d63); color:white; page-break-after:always; }
.portada .tag { color:#66e3c4; letter-spacing:.18em; font-weight:700; font-size:10pt; }
.portada h1 { font-size:34pt; line-height:1.08; margin:12mm 0 5mm; }
.portada p { font-size:15pt; max-width:145mm; color:#d8edf1; }
.portada .meta { margin-top:24mm; font-size:10pt; color:#9bc4ce; }
.indice { page-break-after:always; padding:7mm 5mm; }
.indice h1 { color:#0b4d63; font-size:25pt; }
.indice ol { font-size:13pt; line-height:2; }
.intro { background:#edf8f6; border-left:4px solid #16a085; padding:4mm 5mm; }
.clase { page-break-before:always; }
.kicker { color:#0b7a75; letter-spacing:.12em; font-size:8.5pt; font-weight:700; border-bottom:1px solid #bddad8; padding-bottom:2mm; }
h1 { color:#082b46; font-size:23pt; margin:5mm 0 3mm; line-height:1.15; }
h2 { color:#0b5961; font-size:14pt; margin:6mm 0 2mm; break-after:avoid; }
.objetivo { font-size:11.5pt; background:#edf8f6; padding:3mm 4mm; border-radius:2mm; }
li { margin:1.4mm 0; }
pre { background:#101827; color:#e8eef8; padding:4mm; border-radius:2mm; overflow-wrap:anywhere; white-space:pre-wrap; word-break:break-word; font:7.4pt/1.38 Consolas,'Courier New',monospace; break-inside:auto; }
code { font-family:Consolas,'Courier New',monospace; }
.practica { background:#fff7dc; border:1px solid #ead381; padding:3mm 4mm; margin-top:4mm; break-inside:avoid; }
.cierre { page-break-before:always; padding:25mm 10mm; }
.cierre h1 { font-size:28pt; }
.ruta { display:flex; gap:3mm; flex-wrap:wrap; margin:8mm 0; }
.ruta span { background:#0b5961; color:white; padding:3mm; border-radius:2mm; }
</style></head><body>
<section class="portada"><div class="tag">JHAKORN · MATERIAL DE CLASE</div><h1>Curso de HTML<br>desde cero</h1><p>Manual completo de las clases 1 a 8, con explicaciones, buenas prácticas y todo el código desarrollado.</p><div class="meta">Proyecto: Página Web · Generado el $fecha</div></section>
<section class="indice"><h1>Contenido</h1><div class="intro"><strong>Cómo usar este manual.</strong> Lee cada clase en orden, escribe el código por tu cuenta y luego compáralo con el ejemplo completo. HTML define la estructura; las clases posteriores del proyecto podrán añadir CSS para la presentación.</div><ol>$(( $clases | ForEach-Object { '<li>Clase ' + $_.N + ': ' + $_.T + '</li>' }) -join '')</ol><h2>Progresión</h2><p>Estructura básica → contenido y texto → enlaces → imágenes → listas y tablas → formularios → semántica → proyecto integrador.</p></section>
$($secciones -join "`n")
<section class="cierre"><div class="kicker">RESUMEN FINAL</div><h1>Lo aprendido</h1><p>Al completar estas ocho clases puedes estructurar una página HTML5 clara, navegar entre contenidos, presentar imágenes y datos, recopilar información con formularios y organizar una página con etiquetas semánticas y criterios básicos de accesibilidad.</p><div class="ruta"><span>Contenido</span><span>Navegación</span><span>Multimedia</span><span>Datos</span><span>Formularios</span><span>Semántica</span></div><h2>Siguiente paso recomendado</h2><p>Agregar CSS en un archivo separado para trabajar colores, tipografía, espaciado, diseño adaptable y componentes visuales, conservando el HTML semántico construido aquí.</p></section>
</body></html>
"@

# Evita problemas de codificacion en visores que no representan bien los
# caracteres en espanol. Primero corrige texto que ya venga mal decodificado
# y despues convierte todo el documento a caracteres ASCII legibles.
$html = $html.Replace('acompaÃ±ada', 'acompanada')
$normalizado = $html.Normalize([Text.NormalizationForm]::FormD)
$sinAcentos = New-Object Text.StringBuilder
foreach ($caracter in $normalizado.ToCharArray()) {
    $categoria = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($caracter)
    if ($categoria -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
        [void]$sinAcentos.Append($caracter)
    }
}
$html = $sinAcentos.ToString().Normalize([Text.NormalizationForm]::FormC)
$html = $html.Replace([string][char]0x00F1, 'n').Replace([string][char]0x00D1, 'N')

$rutaManual = Join-Path $carpetaCurso 'manual-html-clases-1-a-8.html'
Set-Content -LiteralPath $rutaManual -Value $html -Encoding UTF8
Write-Output "Manual generado correctamente en: $rutaManual"
