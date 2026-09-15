-- MIS Career Hub — seed a real per-lesson quiz bank from published lesson content.
-- Run after lesson_content and lesson_quizzes exist and the current account is role='admin'.
create or replace function public.seed_all_lesson_quizzes()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
  n integer := 0;
  qs jsonb;
  topic text;
  clean_goal text;
  clean_example text;
begin
  if not exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin') then
    raise exception 'NOT_ADMIN';
  end if;

  for r in
    select course_slug, level_number, lesson_number, title, goal, example, mistakes, challenge
    from public.lesson_content
    where published = true
    order by course_slug, level_number, lesson_number
  loop
    topic := coalesce(nullif(trim(r.title),''),'موضوع الدرس');
    clean_goal := coalesce(nullif(trim(r.goal),''),'فهم المفهوم وتطبيقه عمليًا.');
    clean_example := coalesce(nullif(trim(r.example),''),'تنفيذ مثال عملي مرتبط بموضوع الدرس.');

    qs := jsonb_build_array(
      jsonb_build_object(
        'question', 'ما الموضوع الرئيسي الذي يركز عليه هذا الدرس؟',
        'options', jsonb_build_array(topic, 'موضوع من درس مختلف', 'موضوع خارج المسار', 'معلومة لا ترتبط بالدرس'),
        'answer', 0,
        'explanation', 'عنوان الدرس يحدد المهارة أو المفهوم الأساسي الذي يجب إتقانه.'
      ),
      jsonb_build_object(
        'question', 'ما الهدف التعليمي الأساسي من الدرس؟',
        'options', jsonb_build_array(clean_goal, 'حفظ العنوان فقط', 'تخطي التطبيق العملي', 'إلغاء مرحلة التحقق'),
        'answer', 0,
        'explanation', 'الهدف التعليمي هو النتيجة التي يفترض أن يحققها الطالب بعد دراسة الدرس.'
      ),
      jsonb_build_object(
        'question', 'أي خيار يمثل التطبيق العملي المرتبط بهذا الدرس؟',
        'options', jsonb_build_array(clean_example, 'عدم تنفيذ أي تمرين', 'نسخ حل دون فهم', 'تجاهل النتيجة'),
        'answer', 0,
        'explanation', 'التطبيق العملي يحول المعرفة النظرية إلى مهارة يمكن استخدامها في مشروع حقيقي.'
      ),
      jsonb_build_object(
        'question', 'ما التصرف الصحيح عند مواجهة الخطأ أو النتيجة غير المتوقعة في هذا الدرس؟',
        'options', jsonb_build_array('فهم السبب ومراجعة المدخلات والخطوات ثم التصحيح', 'تجاهل الخطأ', 'حذف المشروع مباشرة', 'اعتماد النتيجة دون اختبار'),
        'answer', 0,
        'explanation', 'المراجعة والاختبار والتصحيح جزء أساسي من التعلم العملي.'
      ),
      jsonb_build_object(
        'question', 'ما أفضل طريقة لإثبات إتقان موضوع هذا الدرس؟',
        'options', jsonb_build_array('تنفيذ تحدي عملي وشرح النتيجة', 'حفظ اسم الدرس فقط', 'مشاهدة الشرح دون تطبيق', 'تخطي التمرين'),
        'answer', 0,
        'explanation', 'إتقان المهارة يظهر عندما يستطيع الطالب تطبيقها وشرح ما فعله والتحقق من النتيجة.'
      )
    );

    insert into public.lesson_quizzes(course_slug, level_number, lesson_number, questions, passing_score, published, updated_by)
    values(r.course_slug, r.level_number, r.lesson_number, qs, 60, true, auth.uid())
    on conflict(course_slug, level_number, lesson_number)
    do update set
      questions = excluded.questions,
      passing_score = 60,
      published = true,
      updated_by = auth.uid(),
      updated_at = now();

    n := n + 1;
  end loop;

  return n;
end;
$$;

revoke all on function public.seed_all_lesson_quizzes() from public;
grant execute on function public.seed_all_lesson_quizzes() to authenticated;
