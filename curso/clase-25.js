// Buscar los elementos principales
const campoServicio = document.querySelector("#nuevo-servicio");
const botonAgregar = document.querySelector("#agregar");
const listaServicios = document.querySelector("#lista-servicios");
const mensajeElemento = document.querySelector("#mensaje");
const cantidadElemento = document.querySelector("#cantidad");

// Actualizar la cantidad de elementos visibles
function actualizarCantidad() {
    const cantidad = listaServicios.children.length;
    const palabra = cantidad === 1 ? "elemento" : "elementos";
    cantidadElemento.textContent = `${cantidad} ${palabra}`;
}

// Eliminar el elemento que contiene el boton presionado
function eliminarServicio(evento) {
    const botonPresionado = evento.currentTarget;
    const elementoServicio = botonPresionado.closest(".servicio");
    const nombreServicio = elementoServicio.querySelector("span").textContent;

    elementoServicio.remove();
    mensajeElemento.textContent = `Se elimino: ${nombreServicio}`;
    actualizarCantidad();
}

// Conectar los botones de eliminar que ya existen en HTML
function conectarBotonesEliminar() {
    const botonesEliminar = document.querySelectorAll(".boton-eliminar");

    botonesEliminar.forEach(function (boton) {
        boton.addEventListener("click", eliminarServicio);
    });
}

// Crear un nuevo elemento de la lista
function crearServicio(nombreServicio) {
    const nuevoElemento = document.createElement("li");
    const nuevoTexto = document.createElement("span");
    const nuevoBoton = document.createElement("button");

    nuevoElemento.classList.add("servicio");
    nuevoTexto.textContent = nombreServicio;
    nuevoBoton.textContent = "Eliminar";
    nuevoBoton.type = "button";
    nuevoBoton.classList.add("boton-eliminar");
    nuevoBoton.addEventListener("click", eliminarServicio);

    nuevoElemento.append(nuevoTexto, nuevoBoton);
    return nuevoElemento;
}

// Leer el campo y agregar un servicio
function agregarServicio() {
    const nombreServicio = campoServicio.value.trim();

    if (nombreServicio === "") {
        mensajeElemento.textContent = "Escribe un nombre antes de agregar.";
        campoServicio.focus();
        return;
    }

    const nuevoServicio = crearServicio(nombreServicio);
    listaServicios.append(nuevoServicio);
    mensajeElemento.textContent = `Se agrego: ${nombreServicio}`;

    campoServicio.value = "";
    campoServicio.focus();
    actualizarCantidad();
}

// Conectar el boton principal
botonAgregar.addEventListener("click", agregarServicio);

// Permitir agregar con la tecla Enter desde el campo
campoServicio.addEventListener("keydown", function (evento) {
    if (evento.key === "Enter") {
        agregarServicio();
    }
});

// Preparar los elementos iniciales
conectarBotonesEliminar();
actualizarCantidad();
