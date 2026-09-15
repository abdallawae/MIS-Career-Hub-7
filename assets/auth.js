const $ = (id) => document.getElementById(id);
const msg = $('authMsg');
const params = new URLSearchParams(location.search);
const next = params.get('next') || 'account.html';

function safeNext(value){
  if(!value) return 'account.html';
  if(value.startsWith('http://') || value.startsWith('https://') || value.startsWith('//')) return 'account.html';
  return value;
}
const destination = safeNext(next);
function notice(text, ok=false){ if(msg){ msg.textContent=text; msg.className='notice' + (ok?' success':''); } }

async function finishLogin(message='تم تسجيل الدخول بنجاح.'){
  try { await MIS.saveProfile(); } catch(e) { console.warn('profile sync', e); }
  notice(message, true);
  setTimeout(()=>{ location.href = destination; }, 500);
}

async function refreshAuth(){
  const user = await MIS.user();
  if(user){
    notice(`أنت مسجل الدخول: ${user.email || user.phone || 'حسابك'}`, true);
    if($('logout')) $('logout').hidden=false;
    if($('login')) $('login').disabled=true;
    if($('signup')) $('signup').disabled=true;
  } else {
    notice('سجّل دخولك أو أنشئ حسابًا جديدًا للبدء.');
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

async function social(provider){
  const {error}=await sb.auth.signInWithOAuth({provider,options:{redirectTo:`${window.location.origin}${window.location.pathname}?next=${encodeURIComponent(destination)}`}});
  if(error) notice(error.message);
}
$('google')?.addEventListener('click',()=>social('google'));
$('facebook')?.addEventListener('click',()=>social('facebook'));

$('sendOtp')?.addEventListener('click', async()=>{
  const phone=$('phone').value.trim();
  if(!/^\+\d{8,15}$/.test(phone)) return notice('اكتب رقم الهاتف بصيغة دولية، مثل +2010xxxxxxxx.');
  const {error}=await sb.auth.signInWithOtp({phone});
  if(error) return notice(error.message);
  $('otpBox').hidden=false; notice('تم إرسال كود التحقق إلى هاتفك.');
});
$('verifyOtp')?.addEventListener('click', async()=>{
  const phone=$('phone').value.trim(), token=$('otp').value.trim();
  if(!token) return notice('اكتب كود التحقق.');
  const {error}=await sb.auth.verifyOtp({phone,token,type:'sms'});
  if(error) return notice(error.message);
  await finishLogin('تم التحقق وتسجيل الدخول بنجاح ✓');
});
$('logout')?.addEventListener('click', async()=>{ await sb.auth.signOut(); location.href='auth.html'; });
sb.auth.onAuthStateChange(()=>setTimeout(refreshAuth,0));
refreshAuth();
