/* Navegación lateral, apertura controlada y copiar comando - página principal */
(()=>{'use strict';
const side=document.querySelector('#sidebar-jhakorn'),toggle=document.querySelector('#sidebar-toggle'),close=document.querySelector('#sidebar-close'),shade=document.querySelector('#sidebar-shade');
if(!side||!toggle||!shade)return;
let previous=null;
function setOpen(open){side.classList.toggle('abierta',open);toggle.setAttribute('aria-expanded',String(open));shade.hidden=!open;if(open){previous=document.activeElement;close?.focus()}else{if(side.contains(document.activeElement))toggle.focus();}}
toggle.addEventListener('click',()=>setOpen(!side.classList.contains('abierta')));
close?.addEventListener('click',()=>setOpen(false));
shade.addEventListener('click',()=>setOpen(false));
side.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>setOpen(false)));
document.addEventListener('keydown',e=>{if(e.key==='Escape'&&side.classList.contains('abierta'))setOpen(false)});
document.querySelectorAll('[data-copy]').forEach(btn=>btn.addEventListener('click',async()=>{let old=btn.textContent;try{await navigator.clipboard.writeText(btn.dataset.copy);btn.textContent='Copiado';}catch(_){btn.textContent='Selecciona el comando';}btn.title=old;}));
})();