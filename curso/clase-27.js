// Buscar los elementos del menu
const botonMenu = document.querySelector("#boton-menu");
const menuPrincipal = document.querySelector("#menu-principal");
const enlacesMenu = menuPrincipal.querySelectorAll("a");

// Comprobar si el menu se encuentra abierto
function menuEstaAbierto() {
    return menuPrincipal.classList.contains("menu-abierto");
}

// Actualizar la apariencia y los atributos del menu
function establecerEstadoMenu(estaAbierto) {
    menuPrincipal.classList.toggle("menu-abierto", estaAbierto);
    botonMenu.setAttribute("aria-expanded", String(estaAbierto));
    botonMenu.textContent = estaAbierto ? "Cerrar menu" : "Abrir menu";
}

// Alternar el estado al presionar el boton
function alternarMenu() {
    establecerEstadoMenu(!menuEstaAbierto());
}

// Cerrar el menu despues de seleccionar un enlace
function cerrarMenu() {
    establecerEstadoMenu(false);
}

// Conectar el boton principal
botonMenu.addEventListener("click", alternarMenu);

// Conectar cada enlace del menu
enlacesMenu.forEach(function (enlace) {
    enlace.addEventListener("click", cerrarMenu);
});

// Cerrar con la tecla Escape y devolver el foco al boton
document.addEventListener("keydown", function (evento) {
    if (evento.key === "Escape" && menuEstaAbierto()) {
        cerrarMenu();
        botonMenu.focus();
    }
});
