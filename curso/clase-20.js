// Mensaje visible en la consola del navegador
console.log("JavaScript esta conectado correctamente.");

// Buscar elementos del documento HTML por su identificador
const estado = document.querySelector("#estado");
const resultado = document.querySelector("#resultado");

// Cambiar el contenido visible de los elementos
estado.textContent = "JavaScript se ejecuto correctamente.";
resultado.textContent = "Hola desde JavaScript";

// Cambiar las clases CSS del mensaje de estado
estado.classList.remove("estado-espera");
estado.classList.add("estado-correcto");
