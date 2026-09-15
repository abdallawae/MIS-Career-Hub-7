const $=id=>document.getElementById(id);
const status=$('ownerStatus');
const names={sql:'SQL وقواعد البيانات',excel:'Excel الاحترافي','power-bi':'Power BI','systems-analysis':'تحليل وتصميم النظم',erp:'ERP',python:'Python وتحليل البيانات',web:'تطوير الويب',cybersecurity:'الأمن السيبراني',cloud:'الحوسبة السحابية','project-management':'إدارة المشروعات',career:'المسار الوظيفي','digital-transformation':'التحول الرقمي'};
function setStatus(t,ok=false){if(status){status.textContent=t;status.className='pill'+(ok?' success':'');}}
function esc(v){return String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[c]));}
function certName(slug){return names[slug]||slug||'—';}
async function guard(){
 const user=await MIS.user();
 if(!user){setStatus('سجّل الدخول أولاً');location.href='auth.html?next=owner.html';return null;}
 const profile=await MIS.profile();
 if(profile?.role!=='admin'){setStatus('غير مصرح');document.querySelector('main').innerHTML='<div class="card" style="margin:40px auto;max-width:720px;text-align:center"><h1>⛔ الوصول للمالك فقط</h1><p class="muted">هذا القسم متاح لحساب Owner / Admin فقط.</p><a class="btn" href="index.html">العودة للموقع</a></div>';return null;}
 setStatus('Owner متصل ✓',true);return user;
}
async function count(table){const {count,error}=await sb.from(table).select('*',{count:'exact',head:true});if(error)throw error;return count||0;}
function rowsOrEmpty(el,html,colspan,msg){if(el)el.innerHTML=html||`<tr><td colspan="${colspan}">${msg}</td></tr>`;}
async function load(){
 try{
  const user=await guard();if(!user)return;
  const [courses,students,progress,quizzes,enrollments,certificates]=await Promise.all([count('courses'),count('profiles'),count('lesson_progress'),count('quiz_results'),count('course_enrollments'),count('certificates')]);
  ['statCourses','statStudents','statProgress','statQuizzes','statEnrollments','statCertificates'].forEach((id,i)=>{const e=$(id);if(e)e.textContent=[courses,students,progress,quizzes,enrollments,certificates][i]});
  const {data:courseData,error:ce}=await sb.from('courses').select('name,slug,is_published,created_at').order('created_at',{ascending:false});if(ce)throw ce;
  rowsOrEmpty($('courseRows'),(courseData||[]).map(c=>`<tr><td>${esc(c.name)}</td><td><code>${esc(c.slug)}</code></td><td>${c.is_published?'منشور':'مسودة'}</td><td><a href="course.html?course=${encodeURIComponent(c.slug)}">فتح</a></td></tr>`).join(''),4,'لا توجد مسارات محفوظة بعد.');
  const {data:studentsData,error:se}=await sb.from('profiles').select('full_name,created_at').order('created_at',{ascending:false}).limit(20);if(se)throw se;
  rowsOrEmpty($('studentRows'),(studentsData||[]).map(s=>`<tr><td>${esc(s.full_name||'طالب')}</td><td>محمي في Auth</td><td>${s.created_at?new Date(s.created_at).toLocaleDateString('ar-EG'):'—'}</td></tr>`).join(''),3,'لا يوجد طلاب بعد.');
  const {data:activity,error:ae}=await sb.from('lesson_progress').select('course_slug,level_number,lesson_number,completed_at').order('completed_at',{ascending:false}).limit(15);if(ae)throw ae;
  rowsOrEmpty($('activityRows'),(activity||[]).map(a=>`<tr><td>${esc(certName(a.course_slug))}</td><td>المستوى ${a.level_number} / الدرس ${a.lesson_number}</td><td>${a.completed_at?new Date(a.completed_at).toLocaleString('ar-EG'):'—'}</td></tr>`).join(''),3,'لا يوجد نشاط حتى الآن.');
  const {data:quizData,error:qe}=await sb.from('quiz_results').select('course_slug,level_number,lesson_number,score,created_at').order('created_at',{ascending:false}).limit(15);if(qe)throw qe;
  rowsOrEmpty($('quizRows'),(quizData||[]).map(q=>`<tr><td>${esc(certName(q.course_slug))}</td><td>م${q.level_number} / د${q.lesson_number}</td><td>${Number(q.score)||0}%</td><td>${q.created_at?new Date(q.created_at).toLocaleString('ar-EG'):'—'}</td></tr>`).join(''),4,'لا توجد نتائج اختبارات حتى الآن.');
  const {data:popular,error:pe}=await sb.from('course_enrollments').select('course_slug');if(pe)throw pe;
  const counts={};(popular||[]).forEach(x=>counts[x.course_slug]=(counts[x.course_slug]||0)+1);
  rowsOrEmpty($('popularRows'),Object.entries(counts).sort((a,b)=>b[1]-a[1]).slice(0,10).map(([slug,n])=>`<tr><td>${esc(certName(slug))}</td><td>${n}</td></tr>`).join(''),2,'لا توجد تسجيلات في المسارات حتى الآن.');
  const {data:certData,error:certErr}=await sb.from('certificates').select('id,certificate_id,student_name,course_slug,issued_at,status').order('issued_at',{ascending:false}).limit(50);if(certErr)throw certErr;
  rowsOrEmpty($('certificateRows'),(certData||[]).map(c=>`<tr><td><code>${esc(c.certificate_id)}</code></td><td>${esc(c.student_name)}</td><td>${esc(certName(c.course_slug))}</td><td>${c.issued_at?new Date(c.issued_at).toLocaleDateString('ar-EG'):'—'}</td><td><span class="pill ${c.status==='revoked'?'':'success'}">${c.status==='revoked'?'ملغاة':'سارية'}</span></td><td><button class="btn small cert-toggle" data-id="${esc(c.id)}" data-status="${esc(c.status)}">${c.status==='revoked'?'إعادة تفعيل':'إلغاء'}</button><a class="btn small secondary" href="certificate.html?id=${encodeURIComponent(c.certificate_id)}">عرض</a></td></tr>`).join(''),6,'لا توجد شهادات صادرة حتى الآن.');
  document.querySelectorAll('.cert-toggle').forEach(btn=>btn.addEventListener('click',()=>toggleCertificate(btn.dataset.id,btn.dataset.status)));
  setStatus('Owner متصل ✓ — البيانات محدثة',true);
 }catch(e){console.error(e);setStatus('تعذر تحميل البيانات: '+(e.message||'خطأ'));}
}
async function toggleCertificate(id,current){
 const next=current==='revoked'?'issued':'revoked';
 if(!confirm(next==='revoked'?'هل تريد إلغاء صلاحية هذه الشهادة؟':'هل تريد إعادة تفعيل هذه الشهادة؟'))return;
 const {error}=await sb.from('certificates').update({status:next}).eq('id',id);
 if(error)return alert('تعذر تحديث الشهادة: '+error.message);
 load();
}
$('addCourse')?.addEventListener('click',async()=>{
 const name=$('newCourseName').value.trim(),slug=$('newCourseSlug').value.trim().toLowerCase();
 if(!name||!slug)return alert('اكتب اسم المسار والـ Slug.');
 if(!/^[a-z0-9-]+$/.test(slug))return alert('الـ Slug يكون English letters/numbers وشرطة فقط.');
 const {error}=await sb.from('courses').insert({name,slug,is_published:true});
 if(error)return alert('تعذر إضافة المسار: '+error.message);
 $('newCourseName').value='';$('newCourseSlug').value='';load();
});
$('refreshOwner')?.addEventListener('click',load);
load();