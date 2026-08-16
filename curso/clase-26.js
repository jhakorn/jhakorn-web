// Buscar el formulario y sus campos
const formulario = document.querySelector("#formulario");
const campoNombre = document.querySelector("#nombre");
const campoCorreo = document.querySelector("#correo");
const campoServicio = document.querySelector("#servicio");
const campoMensaje = document.querySelector("#mensaje");
const campoAcepta = document.querySelector("#acepta");
const resumenElemento = document.querySelector("#resumen");

// Buscar los elementos destinados a errores
const errorNombre = document.querySelector("#error-nombre");
const errorCorreo = document.querySelector("#error-correo");
const errorServicio = document.querySelector("#error-servicio");
const errorMensaje = document.querySelector("#error-mensaje");
const errorAcepta = document.querySelector("#error-acepta");

// Mostrar un error relacionado con un campo
function mostrarError(campo, elementoError, mensaje) {
    elementoError.textContent = mensaje;
    campo.classList.add("entrada-error");
    campo.setAttribute("aria-invalid", "true");
}

// Limpiar el error relacionado con un campo
function limpiarError(campo, elementoError) {
    elementoError.textContent = "";
    campo.classList.remove("entrada-error");
    campo.removeAttribute("aria-invalid");
}

// Comprobar una estructura sencilla de correo
function correoEsValido(correo) {
    const patronCorreo = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return patronCorreo.test(correo);
}

// Limpiar todos los mensajes antes de validar nuevamente
function limpiarFormularioVisual() {
    limpiarError(campoNombre, errorNombre);
    limpiarError(campoCorreo, errorCorreo);
    limpiarError(campoServicio, errorServicio);
    limpiarError(campoMensaje, errorMensaje);
    limpiarError(campoAcepta, errorAcepta);

    resumenElemento.textContent = "";
    resumenElemento.classList.remove("resumen-error", "resumen-correcto");
}

// Validar el formulario cuando se intenta enviar
function validarFormulario(evento) {
    evento.preventDefault();
    limpiarFormularioVisual();

    const nombre = campoNombre.value.trim();
    const correo = campoCorreo.value.trim();
    const servicio = campoServicio.value;
    const mensaje = campoMensaje.value.trim();
    const acepta = campoAcepta.checked;
    const camposIncorrectos = [];

    if (nombre.length < 3) {
        mostrarError(campoNombre, errorNombre, "Escribe al menos 3 caracteres.");
        camposIncorrectos.push(campoNombre);
    }

    if (!correoEsValido(correo)) {
        mostrarError(campoCorreo, errorCorreo, "Escribe un correo con formato valido.");
        camposIncorrectos.push(campoCorreo);
    }

    if (servicio === "") {
        mostrarError(campoServicio, errorServicio, "Selecciona un servicio.");
        camposIncorrectos.push(campoServicio);
    }

    if (mensaje.length < 10) {
        mostrarError(campoMensaje, errorMensaje, "Escribe al menos 10 caracteres.");
        camposIncorrectos.push(campoMensaje);
    }

    if (!acepta) {
        mostrarError(campoAcepta, errorAcepta, "Debes aceptar la demostracion local.");
        camposIncorrectos.push(campoAcepta);
    }

    if (camposIncorrectos.length > 0) {
        resumenElemento.textContent = `Existen ${camposIncorrectos.length} campos por corregir.`;
        resumenElemento.classList.add("resumen-error");
        camposIncorrectos[0].focus();
        return;
    }

    resumenElemento.textContent = `Solicitud de practica valida para ${nombre}.`;
    resumenElemento.classList.add("resumen-correcto");
    console.log("Datos validados:", { nombre, correo, servicio, mensaje, acepta });
}

// Escuchar el envio del formulario
formulario.addEventListener("submit", validarFormulario);
