// Buscar los elementos interactivos
const botonTema = document.querySelector("#boton-tema");
const estadoTema = document.querySelector("#estado-tema");
const raizDocumento = document.documentElement;

// Consultar la preferencia de color del sistema
const consultaTemaOscuro = window.matchMedia("(prefers-color-scheme: dark)");

// Indicar si el usuario eligio manualmente durante esta visita
let seleccionManual = false;

// Aplicar el tema y sincronizar el boton
function aplicarTema(tema) {
    const esOscuro = tema === "oscuro";

    raizDocumento.dataset.tema = tema;
    botonTema.setAttribute("aria-pressed", String(esOscuro));
    botonTema.textContent = esOscuro
        ? "Activar modo claro"
        : "Activar modo oscuro";
    estadoTema.textContent = esOscuro
        ? "El modo oscuro se encuentra activo."
        : "El modo claro se encuentra activo.";
}

// Alternar entre claro y oscuro
function alternarTema() {
    const temaActual = raizDocumento.dataset.tema;
    const nuevoTema = temaActual === "oscuro" ? "claro" : "oscuro";

    seleccionManual = true;
    aplicarTema(nuevoTema);
}

// Elegir el tema inicial segun el sistema
const temaInicial = consultaTemaOscuro.matches ? "oscuro" : "claro";
aplicarTema(temaInicial);

// Cambiar el tema cuando se presiona el boton
botonTema.addEventListener("click", alternarTema);

// Seguir cambios del sistema mientras no exista seleccion manual
consultaTemaOscuro.addEventListener("change", function (evento) {
    if (!seleccionManual) {
        const temaDelSistema = evento.matches ? "oscuro" : "claro";
        aplicarTema(temaDelSistema);
    }
});
