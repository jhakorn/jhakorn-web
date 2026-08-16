// Clave utilizada dentro de localStorage
const CLAVE_TEMA = "jhakorn-tema";

// Buscar elementos HTML
const raizDocumento = document.documentElement;
const botonTema = document.querySelector("#boton-tema");
const botonClaro = document.querySelector("#guardar-claro");
const botonOscuro = document.querySelector("#guardar-oscuro");
const botonRestablecer = document.querySelector("#restablecer");
const temaActualElemento = document.querySelector("#tema-actual");
const preferenciaElemento = document.querySelector("#preferencia-guardada");
const mensajeElemento = document.querySelector("#mensaje");
const consultaTemaOscuro = window.matchMedia("(prefers-color-scheme: dark)");

// Comprobar que un tema sea permitido
function temaEsValido(tema) {
    return tema === "claro" || tema === "oscuro";
}

// Leer la preferencia guardada
function obtenerTemaGuardado() {
    const temaGuardado = localStorage.getItem(CLAVE_TEMA);
    return temaEsValido(temaGuardado) ? temaGuardado : null;
}

// Obtener el tema indicado por el sistema
function obtenerTemaDelSistema() {
    return consultaTemaOscuro.matches ? "oscuro" : "claro";
}

// Aplicar el tema y actualizar la interfaz
function aplicarTema(tema) {
    const esOscuro = tema === "oscuro";

    raizDocumento.dataset.tema = tema;
    botonTema.setAttribute("aria-pressed", String(esOscuro));
    botonTema.textContent = esOscuro
        ? "Activar modo claro"
        : "Activar modo oscuro";
    temaActualElemento.textContent = `Tema activo: ${tema}`;
}

// Mostrar el valor almacenado
function mostrarPreferenciaGuardada() {
    const temaGuardado = obtenerTemaGuardado();
    preferenciaElemento.textContent = temaGuardado
        ? `Guardado: ${temaGuardado}`
        : "No existe una preferencia guardada.";
}

// Guardar y aplicar una preferencia
function guardarTema(tema) {
    if (!temaEsValido(tema)) {
        return;
    }

    localStorage.setItem(CLAVE_TEMA, tema);
    aplicarTema(tema);
    mostrarPreferenciaGuardada();
    mensajeElemento.textContent = `Se guardo el tema ${tema}.`;
}

// Alternar entre los dos temas y guardar el resultado
function alternarTema() {
    const temaActual = raizDocumento.dataset.tema;
    const nuevoTema = temaActual === "oscuro" ? "claro" : "oscuro";
    guardarTema(nuevoTema);
}

// Eliminar la preferencia y volver al sistema
function restablecerTema() {
    localStorage.removeItem(CLAVE_TEMA);
    aplicarTema(obtenerTemaDelSistema());
    mostrarPreferenciaGuardada();
    mensajeElemento.textContent = "Se elimino la preferencia. Ahora se usa el tema del sistema.";
}

// Preparar la pagina al cargar
const temaInicial = obtenerTemaGuardado() || obtenerTemaDelSistema();
aplicarTema(temaInicial);
mostrarPreferenciaGuardada();

// Conectar los controles
botonTema.addEventListener("click", alternarTema);
botonClaro.addEventListener("click", function () {
    guardarTema("claro");
});
botonOscuro.addEventListener("click", function () {
    guardarTema("oscuro");
});
botonRestablecer.addEventListener("click", restablecerTema);

// Seguir el sistema solamente cuando no existe preferencia guardada
consultaTemaOscuro.addEventListener("change", function () {
    if (obtenerTemaGuardado() === null) {
        aplicarTema(obtenerTemaDelSistema());
    }
});
