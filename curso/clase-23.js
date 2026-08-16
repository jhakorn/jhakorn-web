// Funcion sin parametros y sin valor de retorno
function mostrarInicio() {
    console.log("Comienza la practica de funciones.");
}

// Funcion con parametros y valor de retorno
function calcularTotal(precio, cantidad) {
    const total = precio * cantidad;
    return total;
}

// Funcion que calcula un porcentaje
function calcularDescuento(subtotal, porcentaje) {
    return subtotal * (porcentaje / 100);
}

// Funcion que formatea un numero como precio
function formatearPrecio(valor) {
    return `${valor.toFixed(2)} Bs`;
}

// Funcion con una condicion
function obtenerMensajeDisponibilidad(estaDisponible) {
    if (estaDisponible) {
        return "El servicio se encuentra disponible.";
    }

    return "El servicio necesita programacion previa.";
}

// Datos de mantenimiento
const precioMantenimiento = 150;
const cantidadMantenimiento = 2;

// Datos de impresora
const precioImpresora = 100;
const cantidadImpresora = 1;

// Llamar varias veces a la misma funcion
const totalMantenimiento = calcularTotal(precioMantenimiento, cantidadMantenimiento);
const totalImpresora = calcularTotal(precioImpresora, cantidadImpresora);
const subtotal = totalMantenimiento + totalImpresora;
const porcentajeDescuento = 10;
const descuento = calcularDescuento(subtotal, porcentajeDescuento);
const totalFinal = subtotal - descuento;
const mensajeEstado = obtenerMensajeDisponibilidad(true);

// Mostrar informacion en la consola
mostrarInicio();
console.log("Total de mantenimiento:", totalMantenimiento);
console.log("Total de impresora:", totalImpresora);
console.log("Subtotal:", subtotal);
console.log("Descuento:", descuento);
console.log("Total final:", totalFinal);

// Buscar elementos HTML
const precioMantenimientoElemento = document.querySelector("#precio-mantenimiento");
const cantidadMantenimientoElemento = document.querySelector("#cantidad-mantenimiento");
const totalMantenimientoElemento = document.querySelector("#total-mantenimiento");
const precioImpresoraElemento = document.querySelector("#precio-impresora");
const cantidadImpresoraElemento = document.querySelector("#cantidad-impresora");
const totalImpresoraElemento = document.querySelector("#total-impresora");
const subtotalElemento = document.querySelector("#subtotal");
const descuentoElemento = document.querySelector("#descuento");
const totalFinalElemento = document.querySelector("#total-final");
const mensajeEstadoElemento = document.querySelector("#mensaje-estado");

// Mostrar resultados utilizando la funcion de formato
precioMantenimientoElemento.textContent = formatearPrecio(precioMantenimiento);
cantidadMantenimientoElemento.textContent = cantidadMantenimiento;
totalMantenimientoElemento.textContent = formatearPrecio(totalMantenimiento);
precioImpresoraElemento.textContent = formatearPrecio(precioImpresora);
cantidadImpresoraElemento.textContent = cantidadImpresora;
totalImpresoraElemento.textContent = formatearPrecio(totalImpresora);
subtotalElemento.textContent = formatearPrecio(subtotal);
descuentoElemento.textContent = `${porcentajeDescuento}% = ${formatearPrecio(descuento)}`;
totalFinalElemento.textContent = formatearPrecio(totalFinal);
mensajeEstadoElemento.textContent = mensajeEstado;
