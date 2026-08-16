// Buscar elementos del contador
const contadorElemento = document.querySelector("#contador");
const botonRestar = document.querySelector("#restar");
const botonReiniciar = document.querySelector("#reiniciar");
const botonSumar = document.querySelector("#sumar");

// Buscar elementos del estado
const estadoElemento = document.querySelector("#estado");
const botonDisponible = document.querySelector("#marcar-disponible");
const botonPendiente = document.querySelector("#marcar-pendiente");
const ultimoEventoElemento = document.querySelector("#ultimo-evento");

// Estado actual del contador
let contador = 0;

// Funcion que actualiza el numero visible
function mostrarContador() {
    contadorElemento.textContent = contador;
}

// Funcion que informa el ultimo evento
function mostrarUltimoEvento(mensaje) {
    ultimoEventoElemento.textContent = mensaje;
    console.log(mensaje);
}

// Funciones utilizadas por los eventos del contador
function sumarEquipo() {
    contador = contador + 1;
    mostrarContador();
    mostrarUltimoEvento("Se sumo un equipo.");
}

function restarEquipo() {
    if (contador > 0) {
        contador = contador - 1;
        mostrarContador();
        mostrarUltimoEvento("Se resto un equipo.");
    } else {
        mostrarUltimoEvento("El contador no puede ser menor que cero.");
    }
}

function reiniciarContador() {
    contador = 0;
    mostrarContador();
    mostrarUltimoEvento("El contador fue reiniciado.");
}

// Funciones utilizadas por los eventos de estado
function marcarDisponible() {
    estadoElemento.textContent = "Servicio disponible.";
    estadoElemento.classList.remove("estado-advertencia");
    estadoElemento.classList.add("estado-correcto");
    mostrarUltimoEvento("El servicio fue marcado como disponible.");
}

function marcarPendiente() {
    estadoElemento.textContent = "Servicio pendiente de coordinacion.";
    estadoElemento.classList.remove("estado-correcto");
    estadoElemento.classList.add("estado-advertencia");
    mostrarUltimoEvento("El servicio fue marcado como pendiente.");
}

// Escuchar eventos de clic
botonSumar.addEventListener("click", sumarEquipo);
botonRestar.addEventListener("click", restarEquipo);
botonReiniciar.addEventListener("click", reiniciarContador);
botonDisponible.addEventListener("click", marcarDisponible);
botonPendiente.addEventListener("click", marcarPendiente);
