const $ = (id) => document.getElementById(id);
const msg = $('authMsg');
const params = new URLSearchParams(location.search);
const next = params.get('next') || 'account.html';

// Production URL: OAuth must always return to the live GitHub Pages site,
// even if auth.html was opened from localhost during local testing.
const PRODUCTION_AUTH_URL = 'https://abdallawae.github.io/MIS-Career-Hub-7/auth.html';
const PRODUCTION_SITE_URL = 'https://abdallawae.github.io/MIS-Career-Hub-7/';

function safeNext(value){
  if(!value) return 'account.html';
  if(value.startsWith('http://') || value.startsWith('https://') || value.startsWith('//')) return 'account.html';
  return value;
}
const destination = safeNext(next);
function notice(text, ok=false){ if(msg){ msg.textContent=text; msg.className='notice' + (ok?' success':''); } }

function showRecoveryMode(){
  if($('recoveryBox')) $('recoveryBox').hidden=false;
  if($('loginArea')) $('loginArea').hidden=true;
  notice('أنت في وضع استعادة كلمة المرور. اكتب كلمة مرور جديدة.');
}

async function finishLogin(message='تم تسجيل الدخول بنجاح.'){
  try { await MIS.saveProfile(); } catch(e) { console.warn('profile sync', e); }
  notice(message, true);
  setTimeout(()=>{ location.href = destination; }, 500);
}

async function refreshAuth(){
  const user = await MIS.user();
  if(user){
    if(!$('recoveryBox') || $('recoveryBox').hidden){
      notice(`أنت مسجل الدخول: ${user.email || 'حسابك'}`, true);
    }
    if($('logout')) $('logout').hidden=false;
    if($('login')) $('login').disabled=true;
    if($('signup')) $('signup').disabled=true;
  } else {
    if(!$('recoveryBox') || $('recoveryBox').hidden) notice('سجّل دخولك أو أنشئ حسابًا جديدًا للبدء.');
    if($('logout')) $('logout').hidden=true;
  }
}

$('signup')?.addEventListener('click', async()=>{
  const email=$('email').value.trim(), password=$('password').value, name=$('fullName').value.trim();
  if(!email || !/^\S+@\S+\.\S+$/.test(email)) return notice('اكتب بريدًا إلكترونيًا صحيحًا.');
  if(password.length < 6) return notice('كلمة المرور يجب أن تكون 6 أحرف على الأقل.');
  const {data,error}=await sb.auth.signUp({email,password,options:{data:{full_name:name}}});
  if(error) return notice(error.message);
  if(data.user) await MIS.saveProfile(name);
  if(data.session) return finishLogin('تم إنشاء الحساب وتسجيل الدخول بنجاح ✓');
  notice('تم إنشاء الحساب. افتح بريدك الإلكتروني وأكّد الحساب، ثم سجّل الدخول.');
});

$('login')?.addEventListener('click', async()=>{
  const email=$('email').value.trim(), password=$('password').value;
  if(!email || !password) return notice('اكتب البريد الإلكتروني وكلمة المرور.');
  const {error}=await sb.auth.signInWithPassword({email,password});
  if(error) return notice(error.message);
  await finishLogin();
});

window.requestPasswordReset = async function(){
  const email=$('email')?.value.trim();
  if(!email || !/^\S+@\S+\.\S+$/.test(email)) return notice('اكتب بريدك الإلكتروني أولًا، ثم اضغط «نسيت كلمة المرور؟».');
  const button=$('forgotPassword');
  if(button){ button.disabled=true; button.textContent='⏳ جاري إرسال رابط الاستعادة...'; }
  try{
    const {error}=await sb.auth.resetPasswordForEmail(email,{redirectTo:PRODUCTION_AUTH_URL});
    if(error) return notice(error.message);
    notice('تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني. افتح الرابط ثم اكتب كلمة المرور الجديدة.', true);
  }catch(error){
    notice(error?.message || 'حدث خطأ أثناء طلب استعادة كلمة المرور.');
  }finally{
    if(button){ button.disabled=false; button.textContent='🔑 نسيت كلمة المرور؟'; }
  }
};
$('forgotPassword')?.addEventListener('click', window.requestPasswordReset);

$('updatePassword')?.addEventListener('click', async()=>{
  const password=$('newPassword').value, confirm=$('confirmPassword').value;
  if(password.length < 6) return notice('كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل.');
  if(password !== confirm) return notice('كلمتا المرور غير متطابقتين.');
  const {error}=await sb.auth.updateUser({password});
  if(error) return notice(error.message);
  await finishLogin('تم تغيير كلمة المرور بنجاح ✓');
});

async function social(provider){
  const redirectTo=`${PRODUCTION_AUTH_URL}?next=${encodeURIComponent(destination)}`;
  const {error}=await sb.auth.signInWithOAuth({provider,options:{redirectTo}});
  if(error) notice(error.message);
}
$('google')?.addEventListener('click',()=>social('google'));
$('facebook')?.addEventListener('click',()=>social('facebook'));

$('logout')?.addEventListener('click', async()=>{ await sb.auth.signOut(); location.href='auth.html'; });

sb.auth.onAuthStateChange((event)=>{
  if(event === 'PASSWORD_RECOVERY') showRecoveryMode();
  setTimeout(refreshAuth,0);
});

(async()=>{
  const {data:{session}}=await sb.auth.getSession();
  if(session && location.hash.includes('type=recovery')) showRecoveryMode();
  await refreshAuth();
})();
