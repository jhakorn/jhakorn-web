// Datos de ejemplo
const temperaturaEquipo = 78;
const tecnicoDisponible = true;
const repuestoDisponible = false;
const precioServicio = 200;
const clienteFrecuente = true;

// Buscar elementos HTML
const temperaturaElemento = document.querySelector("#temperatura");
const resultadoTemperatura = document.querySelector("#resultado-temperatura");
const panelTemperatura = document.querySelector("#panel-temperatura");
const tecnicoElemento = document.querySelector("#tecnico");
const repuestoElemento = document.querySelector("#repuesto");
const resultadoDisponibilidad = document.querySelector("#resultado-disponibilidad");
const panelDisponibilidad = document.querySelector("#panel-disponibilidad");
const precioElemento = document.querySelector("#precio");
const clienteElemento = document.querySelector("#cliente");
const resultadoDescuento = document.querySelector("#resultado-descuento");

// Mostrar los datos iniciales
temperaturaElemento.textContent = `${temperaturaEquipo} grados`;
tecnicoElemento.textContent = tecnicoDisponible ? "Si" : "No";
repuestoElemento.textContent = repuestoDisponible ? "Si" : "No";
precioElemento.textContent = `${precioServicio} Bs`;
clienteElemento.textContent = clienteFrecuente ? "Si" : "No";

// Condicion con if, else if y else
if (temperaturaEquipo >= 85) {
    resultadoTemperatura.textContent = "Temperatura peligrosa. Apaga y revisa el equipo.";
    panelTemperatura.classList.add("panel-peligro");
} else if (temperaturaEquipo >= 70) {
    resultadoTemperatura.textContent = "Temperatura elevada. Revisa la ventilacion.";
    panelTemperatura.classList.add("panel-advertencia");
} else {
    resultadoTemperatura.textContent = "Temperatura dentro del rango de ejemplo.";
    panelTemperatura.classList.add("panel-correcto");
}

// Operador AND: ambas condiciones deben ser verdaderas
if (tecnicoDisponible && repuestoDisponible) {
    resultadoDisponibilidad.textContent = "El servicio puede realizarse hoy.";
    panelDisponibilidad.classList.add("panel-correcto");
} else {
    resultadoDisponibilidad.textContent = "El servicio necesita coordinacion adicional.";
    panelDisponibilidad.classList.add("panel-advertencia");
}

// Condicion para calcular un descuento
let precioFinal = precioServicio;

if (clienteFrecuente && precioServicio >= 200) {
    precioFinal = precioServicio * 0.9;
    resultadoDescuento.textContent = `Precio con descuento: ${precioFinal} Bs`;
} else {
    resultadoDescuento.textContent = `Precio sin descuento: ${precioFinal} Bs`;
}

// Comparaciones visibles en la consola
console.log("Temperatura mayor o igual a 70:", temperaturaEquipo >= 70);
console.log("Temperatura mayor o igual a 85:", temperaturaEquipo >= 85);
console.log("Tecnico y repuesto disponibles:", tecnicoDisponible && repuestoDisponible);
console.log("Precio igual a 200:", precioServicio === 200);
console.log("Precio diferente de 150:", precioServicio !== 150);
