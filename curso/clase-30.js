const CLAVE_TEMA = "jhakorn-tema";
const raiz = document.documentElement;

// Menu movil
const botonMenu = document.querySelector("#boton-menu");
const navegacion = document.querySelector("#menu-principal");
const enlaces = navegacion.querySelectorAll("a");

function establecerMenu(abierto) {
    navegacion.classList.toggle("abierta", abierto);
    botonMenu.setAttribute("aria-expanded", String(abierto));
    botonMenu.textContent = abierto ? "Cerrar menu" : "Abrir menu";
}

botonMenu.addEventListener("click", function () {
    establecerMenu(!navegacion.classList.contains("abierta"));
});
enlaces.forEach(function (enlace) {
    enlace.addEventListener("click", function () { establecerMenu(false); });
});
document.addEventListener("keydown", function (evento) {
    if (evento.key === "Escape" && navegacion.classList.contains("abierta")) {
        establecerMenu(false);
        botonMenu.focus();
    }
});

// Tema persistente
const botonTema = document.querySelector("#boton-tema");
const consultaOscura = window.matchMedia("(prefers-color-scheme: dark)");

function aplicarTema(tema) {
    const oscuro = tema === "oscuro";
    raiz.dataset.tema = tema;
    botonTema.setAttribute("aria-pressed", String(oscuro));
    botonTema.textContent = oscuro ? "Modo claro" : "Modo oscuro";
}

function temaInicial() {
    const guardado = localStorage.getItem(CLAVE_TEMA);
    if (guardado === "claro" || guardado === "oscuro") {
        return guardado;
    }
    return consultaOscura.matches ? "oscuro" : "claro";
}

aplicarTema(temaInicial());
botonTema.addEventListener("click", function () {
    const nuevo = raiz.dataset.tema === "oscuro" ? "claro" : "oscuro";
    localStorage.setItem(CLAVE_TEMA, nuevo);
    aplicarTema(nuevo);
});

// Filtro de servicios
const botonesFiltro = document.querySelectorAll(".filtro");
const tarjetas = document.querySelectorAll(".tarjeta[data-categoria]");
const resultadoFiltro = document.querySelector("#resultado-filtro");

function filtrarServicios(evento) {
    const boton = evento.currentTarget;
    const filtro = boton.dataset.filtro;
    let visibles = 0;

    botonesFiltro.forEach(function (elemento) {
        const activo = elemento === boton;
        elemento.classList.toggle("activo", activo);
        elemento.setAttribute("aria-pressed", String(activo));
    });

    tarjetas.forEach(function (tarjeta) {
        const mostrar = filtro === "todos" || tarjeta.dataset.categoria === filtro;
        tarjeta.hidden = !mostrar;
        if (mostrar) { visibles = visibles + 1; }
    });

    resultadoFiltro.textContent = `${visibles} servicios visibles.`;
}

botonesFiltro.forEach(function (boton) {
    boton.addEventListener("click", filtrarServicios);
});
resultadoFiltro.textContent = `${tarjetas.length} servicios visibles.`;

// Formulario y lista dinamica
const formulario = document.querySelector("#formulario");
const nombre = document.querySelector("#nombre");
const servicio = document.querySelector("#servicio");
const mensaje = document.querySelector("#mensaje");
const errorNombre = document.querySelector("#error-nombre");
const errorServicio = document.querySelector("#error-servicio");
const errorMensaje = document.querySelector("#error-mensaje");
const resultadoFormulario = document.querySelector("#resultado-formulario");
const lista = document.querySelector("#lista-solicitudes");
const cantidad = document.querySelector("#cantidad-solicitudes");
const listaVacia = document.querySelector("#lista-vacia");

function actualizarLista() {
    cantidad.textContent = lista.children.length;
    listaVacia.hidden = lista.children.length > 0;
}

function limpiarErrores() {
    [nombre, servicio, mensaje].forEach(function (campo) {
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

function eliminarSolicitud(evento) {
    evento.currentTarget.closest(".solicitud").remove();
    actualizarLista();
}

function crearSolicitud(nombreValor, servicioValor, mensajeValor) {
    const elemento = document.createElement("li");
    const contenido = document.createElement("div");
    const titulo = document.createElement("strong");
    const descripcion = document.createElement("p");
    const boton = document.createElement("button");

    elemento.classList.add("solicitud");
    titulo.textContent = `${nombreValor} - ${servicioValor}`;
    descripcion.textContent = mensajeValor;
    boton.type = "button";
    boton.classList.add("boton-eliminar");
    boton.textContent = "Eliminar";
    boton.addEventListener("click", eliminarSolicitud);
    contenido.append(titulo, descripcion);
    elemento.append(contenido, boton);
    return elemento;
}

formulario.addEventListener("submit", function (evento) {
    evento.preventDefault();
    limpiarErrores();

    const nombreValor = nombre.value.trim();
    const servicioValor = servicio.value;
    const mensajeValor = mensaje.value.trim();
    let valido = true;

    if (nombreValor.length < 3) {
        mostrarError(nombre, errorNombre, "Escribe al menos 3 caracteres.");
        valido = false;
    }
    if (servicioValor === "") {
        mostrarError(servicio, errorServicio, "Selecciona un servicio.");
        valido = false;
    }
    if (mensajeValor.length < 10) {
        mostrarError(mensaje, errorMensaje, "Escribe al menos 10 caracteres.");
        valido = false;
    }
    if (!valido) {
        formulario.querySelector(".entrada-error").focus();
        return;
    }

    lista.append(crearSolicitud(nombreValor, servicioValor, mensajeValor));
    formulario.reset();
    resultadoFormulario.textContent = "Solicitud agregada localmente.";
    actualizarLista();
});

actualizarLista();
