/* Controles de páginas secundarias: no depende del formulario de inicio. */
(()=>{'use strict';
 const root=document.documentElement;
 const themeBtn=document.querySelector('#boton-tema');
 const menuBtn=document.querySelector('#boton-menu');
 const nav=document.querySelector('#menu-principal');
 const storageKey='jhakorn-tema';
 let preference=null;try{preference=localStorage.getItem(storageKey)}catch(_){}
 function apply(theme){root.dataset.tema=theme;if(themeBtn){themeBtn.textContent=theme==='oscuro'?'Modo claro':'Modo oscuro';themeBtn.setAttribute('aria-pressed',String(theme==='oscuro'))}}
 apply(preference==='claro'||preference==='oscuro'?preference:(matchMedia('(prefers-color-scheme: dark)').matches?'oscuro':'claro'));
 themeBtn?.addEventListener('click',()=>{const theme=root.dataset.tema==='oscuro'?'claro':'oscuro';try{localStorage.setItem(storageKey,theme)}catch(_){}apply(theme)});
 function menu(open){if(!nav||!menuBtn)return;nav.classList.toggle('abierta',open);menuBtn.setAttribute('aria-expanded',String(open));menuBtn.textContent=open?'Cerrar':'Menú'}
 menuBtn?.addEventListener('click',()=>menu(!nav.classList.contains('abierta')));
 nav?.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>menu(false)));
 document.addEventListener('keydown',e=>{if(e.key==='Escape'&&nav?.classList.contains('abierta')){menu(false);menuBtn?.focus()}});
 document.querySelectorAll('[data-copy]').forEach(btn=>btn.addEventListener('click',async()=>{const value=btn.getAttribute('data-copy');try{await navigator.clipboard.writeText(value);btn.textContent='Copiado'}catch(_){btn.textContent='Selecciona y copia el comando'}}));
 const year=document.querySelector('#anio');if(year)year.textContent=new Date().getFullYear();
})();
