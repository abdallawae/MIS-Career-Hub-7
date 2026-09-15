const $=id=>document.getElementById(id);
const status=$('ownerStatus');
function setStatus(t,ok=false){if(status){status.textContent=t;status.className='pill'+(ok?' success':'');}}
function esc(v){return String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[c]));}
async function guard(){
  const user=await MIS.user();
  if(!user){setStatus('سجّل الدخول أولاً');location.href='auth.html?next=owner.html';return null;}
  const profile=await MIS.profile();
  if(profile?.role!=='admin'){
    setStatus('غير مصرح');
    document.querySelector('main').innerHTML='<div class="card" style="margin:40px auto;max-width:720px;text-align:center"><h1>⛔ الوصول للمالك فقط</h1><p class="muted">هذا القسم متاح للحساب الذي يحمل صلاحية Owner / Admin فقط.</p><a class="btn" href="index.html">العودة للموقع</a></div>';
    return null;
  }
  setStatus('Owner متصل ✓',true);return user;
}
async function count(table){const {count,error}=await sb.from(table).select('*',{count:'exact',head:true});if(error)throw error;return count||0;}
function rowsOrEmpty(el,html,colspan,msg){el.innerHTML=html||`<tr><td colspan="${colspan}">${msg}</td></tr>`;}
async function load(){
  try{
    const user=await guard();if(!user)return;
    const [courses,students,progress,quizzes,enrollments]=await Promise.all([count('courses'),count('profiles'),count('lesson_progress'),count('quiz_results'),count('course_enrollments')]);
    $('statCourses').textContent=courses;$('statStudents').textContent=students;$('statProgress').textContent=progress;$('statQuizzes').textContent=quizzes;
    const enrollmentStat=$('statEnrollments');if(enrollmentStat)enrollmentStat.textContent=enrollments;
    const {data:courseData,error:ce}=await sb.from('courses').select('name,slug,is_published,created_at').order('created_at',{ascending:false});if(ce)throw ce;
    rowsOrEmpty($('courseRows'),(courseData||[]).map(c=>`<tr><td>${esc(c.name)}</td><td><code>${esc(c.slug)}</code></td><td>${c.is_published?'منشور':'مسودة'}</td><td><a href="course.html?course=${encodeURIComponent(c.slug)}">فتح</a></td></tr>`).join(''),4,'لا توجد مسارات محفوظة بعد.');
    const {data:studentsData,error:se}=await sb.from('profiles').select('full_name,created_at').order('created_at',{ascending:false}).limit(20);if(se)throw se;
    rowsOrEmpty($('studentRows'),(studentsData||[]).map(s=>`<tr><td>${esc(s.full_name||'طالب')}</td><td>محمي في Auth</td><td>${s.created_at?new Date(s.created_at).toLocaleDateString('ar-EG'):'—'}</td></tr>`).join(''),3,'لا يوجد طلاب بعد.');
    const {data:activity,error:ae}=await sb.from('lesson_progress').select('course_slug,level_number,lesson_number,completed_at').order('completed_at',{ascending:false}).limit(15);if(ae)throw ae;
    const activityEl=$('activityRows');if(activityEl)rowsOrEmpty(activityEl,(activity||[]).map(a=>`<tr><td>${esc(a.course_slug)}</td><td>المستوى ${a.level_number} / الدرس ${a.lesson_number}</td><td>${a.completed_at?new Date(a.completed_at).toLocaleString('ar-EG'):'—'}</td></tr>`).join(''),3,'لا يوجد نشاط حتى الآن.');
    const {data:quizData,error:qe}=await sb.from('quiz_results').select('course_slug,level_number,lesson_number,score,created_at').order('created_at',{ascending:false}).limit(15);if(qe)throw qe;
    const quizEl=$('quizRows');if(quizEl)rowsOrEmpty(quizEl,(quizData||[]).map(q=>`<tr><td>${esc(q.course_slug)}</td><td>م${q.level_number} / د${q.lesson_number}</td><td>${Number(q.score)||0}%</td><td>${q.created_at?new Date(q.created_at).toLocaleString('ar-EG'):'—'}</td></tr>`).join(''),4,'لا توجد نتائج اختبارات حتى الآن.');
    const {data:popular,error:pe}=await sb.from('course_enrollments').select('course_slug');if(pe)throw pe;
    const counts={};(popular||[]).forEach(x=>counts[x.course_slug]=(counts[x.course_slug]||0)+1);
    const popularEl=$('popularRows');if(popularEl)rowsOrEmpty(popularEl,Object.entries(counts).sort((a,b)=>b[1]-a[1]).slice(0,10).map(([slug,n])=>`<tr><td>${esc(slug)}</td><td>${n}</td></tr>`).join(''),2,'لا توجد تسجيلات في المسارات حتى الآن.');
    setStatus('Owner متصل ✓ — البيانات محدثة',true);
  }catch(e){console.error(e);setStatus('تعذر تحميل البيانات: '+(e.message||'خطأ'));}
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