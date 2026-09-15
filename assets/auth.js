const $ = (id) => document.getElementById(id);
const msg = $('authMsg');
function notice(text, ok=false){ if(msg){ msg.textContent=text; msg.className='notice' + (ok?' success':''); } }

async function refreshAuth(){
  const user = await MIS.user();
  if(user){
    notice(`أنت مسجل الدخول: ${user.email || user.phone || ''}`, true);
    $('logout').hidden=false;
  } else {
    notice('سجّل دخولك أو أنشئ حسابًا جديدًا للبدء.');
    $('logout').hidden=true;
  }
}

$('signup')?.addEventListener('click', async()=>{
  const email=$('email').value.trim(), password=$('password').value, name=$('fullName').value.trim();
  if(!email || password.length < 6) return notice('اكتب بريدًا صحيحًا وكلمة مرور 6 أحرف على الأقل.');
  const {data,error}=await sb.auth.signUp({email,password,options:{data:{full_name:name}}});
  if(error) return notice(error.message);
  if(data.user) await MIS.saveProfile(name);
  notice(data.session ? 'تم إنشاء الحساب وتسجيل الدخول.' : 'تم إنشاء الحساب. لو ظهر طلب تأكيد البريد، أكّد بريدك ثم سجّل الدخول.', true);
  await refreshAuth();
});

$('login')?.addEventListener('click', async()=>{
  const email=$('email').value.trim(), password=$('password').value;
  const {error}=await sb.auth.signInWithPassword({email,password});
  if(error) return notice(error.message);
  notice('تم تسجيل الدخول بنجاح.', true);
  await refreshAuth();
});

async function social(provider){
  const {error}=await sb.auth.signInWithOAuth({provider,options:{redirectTo:window.location.href}});
  if(error) notice(error.message);
}
$('google')?.addEventListener('click',()=>social('google'));
$('facebook')?.addEventListener('click',()=>social('facebook'));

$('sendOtp')?.addEventListener('click', async()=>{
  const phone=$('phone').value.trim();
  if(!phone) return notice('اكتب رقم الهاتف بصيغة دولية مثل +2010xxxxxxxx.');
  const {error}=await sb.auth.signInWithOtp({phone});
  if(error) return notice(error.message);
  $('otpBox').hidden=false; notice('تم إرسال كود التحقق.');
});
$('verifyOtp')?.addEventListener('click', async()=>{
  const phone=$('phone').value.trim(), token=$('otp').value.trim();
  const {error}=await sb.auth.verifyOtp({phone,token,type:'sms'});
  if(error) return notice(error.message);
  notice('تم التحقق وتسجيل الدخول.', true); await refreshAuth();
});
$('logout')?.addEventListener('click', async()=>{ await sb.auth.signOut(); await refreshAuth(); });
sb.auth.onAuthStateChange(()=>setTimeout(refreshAuth,0));
refreshAuth();
