(()=>{
  const showError=msg=>{
    const title=document.getElementById('title');
    const intro=document.getElementById('intro');
    const app=document.getElementById('lessonApp');
    if(title&&(!title.textContent||title.textContent.includes('جاري'))) title.textContent='تعذر تحميل الدرس مؤقتًا';
    if(intro) intro.innerHTML=(msg||'حدث خطأ أثناء تحميل بيانات الدرس. حدّث الصفحة وحاول مرة أخرى.')+'<br><br><button class="btn" onclick="location.reload()">🔄 إعادة المحاولة</button>';
    if(app) app.hidden=false;
  };
  window.addEventListener('error',e=>{ if(String(e?.message||'').includes('MIS_ENRICH')||String(e?.message||'').includes('sb')) showError('حدث خطأ في مكونات الدرس.'); });
  window.addEventListener('unhandledrejection',e=>{ const r=e?.reason; if(r) console.warn('MIS lesson bootstrap:',r); });
  const patch=()=>{
    if(!window.MIS||window.MIS.__safePatched)return;
    const originalUser=window.MIS.user.bind(window.MIS);
    window.MIS.user=async()=>{try{return await Promise.race([originalUser(),new Promise(resolve=>setTimeout(()=>resolve(null),8000))]);}catch(e){console.warn('auth check failed',e);return null;}};
    window.MIS.__safePatched=true;
  };
  patch();
  setTimeout(patch,100);
  setTimeout(patch,500);
})();
