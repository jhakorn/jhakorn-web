const CLAVE_TEMA = "jhakorn-tema";
const TELEFONO_WHATSAPP = "59177908460";
const raiz = document.documentElement;

// Menú movil
const botonMenú = document.querySelector("#boton-menu");
const navegacion = document.querySelector("#menu-principal");
const enlacesMenú = navegacion.querySelectorAll("a");

function establecerMenú(abierto) {
    navegacion.classList.toggle("abierta", abierto);
    botonMenú.setAttribute("aria-expanded", String(abierto));
    botonMenú.textContent = abierto ? "Cerrar" : "Menú";
}

botonMenú.addEventListener("click", function () {
    establecerMenú(!navegacion.classList.contains("abierta"));
});

enlacesMenú.forEach(function (enlace) {
    enlace.addEventListener("click", function () {
        establecerMenú(false);
    });
});

document.addEventListener("keydown", function (evento) {
    if (evento.key === "Escape" && navegacion.classList.contains("abierta")) {
        establecerMenú(false);
        botonMenú.focus();
    }
});

// Tema claro y oscuro
const botonTema = document.querySelector("#boton-tema");
const consultaOscura = window.matchMedia("(prefers-color-scheme: dark)");

function obtenerTemaInicial() {
    const guardado = localStorage.getItem(CLAVE_TEMA);
    if (guardado === "claro" || guardado === "oscuro") {
        return guardado;
    }
    return consultaOscura.matches ? "oscuro" : "claro";
}

function aplicarTema(tema) {
    const oscuro = tema === "oscuro";
    raiz.dataset.tema = tema;
    botonTema.setAttribute("aria-pressed", String(oscuro));
    botonTema.textContent = oscuro ? "Modo claro" : "Modo oscuro";
}

aplicarTema(obtenerTemaInicial());

botonTema.addEventListener("click", function () {
    const nuevoTema = raiz.dataset.tema === "oscuro" ? "claro" : "oscuro";
    localStorage.setItem(CLAVE_TEMA, nuevoTema);
    aplicarTema(nuevoTema);
});

// Formulario de contacto
const formulario = document.querySelector("#formulario-contacto");
const campoNombre = document.querySelector("#nombre");
const campoServicio = document.querySelector("#servicio");
const campoMensaje = document.querySelector("#mensaje");
const errorNombre = document.querySelector("#error-nombre");
const errorServicio = document.querySelector("#error-servicio");
const errorMensaje = document.querySelector("#error-mensaje");
const resultadoFormulario = document.querySelector("#resultado-formulario");

function limpiarErrores() {
    [campoNombre, campoServicio, campoMensaje].forEach(function (campo) {
        campo.classList.remove("entrada-error");
    });
    errorNombre.textContent = "";
    errorServicio.textContent = "";
    errorMensaje.textContent = "";
    resultadoFormulario.textContent = "";
}

function mostrarError(campo, lugar, texto) {
    campo.classList.add("entrada-error");
    lugar.textContent = texto;
}

formulario.addEventListener("submit", function (evento) {
    evento.preventDefault();
    limpiarErrores();

    const nombre = campoNombre.value.trim();
    const servicio = campoServicio.value;
    const mensaje = campoMensaje.value.trim();
    let valido = true;

    if (nombre.length < 3) {
        mostrarError(campoNombre, errorNombre, "Escribe al menos 3 caracteres.");
        valido = false;
    }
    if (servicio === "") {
        mostrarError(campoServicio, errorServicio, "Selecciona un servicio.");
        valido = false;
    }
    if (mensaje.length < 10) {
        mostrarError(campoMensaje, errorMensaje, "Describe el problema con al menos 10 caracteres.");
        valido = false;
    }

    if (!valido) {
        formulario.querySelector(".entrada-error").focus();
        return;
    }

    const texto = [
        "Hola Jhakorn, necesito información.",
        `Nombre: ${nombre}`,
        `Servicio: ${servicio}`,
        `Problema: ${mensaje}`
    ].join("\n");
    const enlace = `https://wa.me/${TELEFONO_WHATSAPP}?text=${encodeURIComponent(texto)}`;

    resultadoFormulario.textContent = "Mensaje preparado. Se abrira WhatsApp para que confirmes el envio.";
    window.open(enlace, "_blank", "noopener,noreferrer");
});

// Anio automatico
document.querySelector("#anio").textContent = new Date().getFullYear();
