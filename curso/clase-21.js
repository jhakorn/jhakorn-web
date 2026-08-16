// Valores que no cambiaran durante esta practica
const nombreServicio = "Mantenimiento de computadora";
const precioServicio = 150;
const estaDisponible = true;
const tecnicoAsignado = null;

// Variable cuyo valor puede cambiar
let contador = 1;
contador = contador + 1;

// Operacion con numeros
const cantidad = 2;
const total = precioServicio * cantidad;

// Mostrar valores y tipos en la consola
console.log("Nombre:", nombreServicio, typeof nombreServicio);
console.log("Precio:", precioServicio, typeof precioServicio);
console.log("Disponible:", estaDisponible, typeof estaDisponible);
console.log("Tecnico:", tecnicoAsignado, typeof tecnicoAsignado);
console.log("Contador:", contador, typeof contador);
console.log("Total:", total, typeof total);

// Buscar los elementos HTML
const nombreElemento = document.querySelector("#nombre-servicio");
const precioElemento = document.querySelector("#precio-servicio");
const estadoElemento = document.querySelector("#estado-servicio");
const tecnicoElemento = document.querySelector("#tecnico-servicio");
const precioInicialElemento = document.querySelector("#precio-inicial");
const cantidadElemento = document.querySelector("#cantidad");
const totalElemento = document.querySelector("#total");
const contadorElemento = document.querySelector("#contador-texto");

// Mostrar los datos en la pagina
nombreElemento.textContent = nombreServicio;
precioElemento.textContent = `${precioServicio} Bs`;
estadoElemento.textContent = estaDisponible;
tecnicoElemento.textContent = tecnicoAsignado;
precioInicialElemento.textContent = `${precioServicio} Bs`;
cantidadElemento.textContent = cantidad;
totalElemento.textContent = `${total} Bs`;
contadorElemento.textContent = `El contador cambio de 1 a ${contador}`;
