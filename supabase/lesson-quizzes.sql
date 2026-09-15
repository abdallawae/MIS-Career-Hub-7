-- MIS Career Hub — per-lesson quiz bank
-- Run once in Supabase SQL Editor.
create table if not exists public.lesson_quizzes (
  id uuid primary key default gen_random_uuid(),
  course_slug text not null,
  level_number integer not null check (level_number between 1 and 10),
  lesson_number integer not null check (lesson_number between 1 and 6),
  questions jsonb not null default '[]'::jsonb,
  passing_score integer not null default 60 check (passing_score between 1 and 100),
  published boolean not null default true,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(course_slug, level_number, lesson_number)
);
create index if not exists lesson_quizzes_course_idx on public.lesson_quizzes(course_slug, level_number, lesson_number);
create index if not exists lesson_quizzes_published_idx on public.lesson_quizzes(published);
alter table public.lesson_quizzes enable row level security;
drop policy if exists "public read published lesson quizzes" on public.lesson_quizzes;
create policy "public read published lesson quizzes" on public.lesson_quizzes for select to anon, authenticated using (published = true);
drop policy if exists "admin read all lesson quizzes" on public.lesson_quizzes;
create policy "admin read all lesson quizzes" on public.lesson_quizzes for select to authenticated using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));
drop policy if exists "admin insert lesson quizzes" on public.lesson_quizzes;
create policy "admin insert lesson quizzes" on public.lesson_quizzes for insert to authenticated with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));
drop policy if exists "admin update lesson quizzes" on public.lesson_quizzes;
create policy "admin update lesson quizzes" on public.lesson_quizzes for update to authenticated using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')) with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));
drop policy if exists "admin delete lesson quizzes" on public.lesson_quizzes;
create policy "admin delete lesson quizzes" on public.lesson_quizzes for delete to authenticated using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));
create or replace function public.set_lesson_quizzes_updated_at() returns trigger language plpgsql as $$ begin new.updated_at = now(); return new; end; $$;
drop trigger if exists lesson_quizzes_updated_at on public.lesson_quizzes;
create trigger lesson_quizzes_updated_at before update on public.lesson_quizzes for each row execute function public.set_lesson_quizzes_updated_at();

-- SQL track first-pass automatic question bank.
-- Requires the SQL lesson_content rows to exist first.
create or replace function public.seed_sql_quizzes()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
  n integer := 0;
  other1 text;
  other2 text;
  qs jsonb;
begin
  if not exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin') then
    raise exception 'NOT_ADMIN';
  end if;
  for r in select course_slug,level_number,lesson_number,title,goal,example,mistakes,challenge from public.lesson_content where course_slug='sql' and published=true order by level_number,lesson_number loop
    select title into other1 from public.lesson_content where course_slug='sql' and published=true and not (level_number=r.level_number and lesson_number=r.lesson_number) order by abs(level_number-r.level_number)+abs(lesson_number-r.lesson_number),level_number,lesson_number limit 1;
    select title into other2 from public.lesson_content where course_slug='sql' and published=true and title<>coalesce(other1,'') and not (level_number=r.level_number and lesson_number=r.lesson_number) order by random() limit 1;
    qs:=jsonb_build_array(
      jsonb_build_object('question','أي عنوان يعبّر عن موضوع هذا الدرس؟','options',jsonb_build_array(r.title,coalesce(other1,'موضوع مختلف'),coalesce(other2,'مفهوم آخر'),'موضوع خارج المسار'),'answer',0,'explanation','هذا هو العنوان المرتبط مباشرة بمحتوى الدرس الحالي.'),
      jsonb_build_object('question','ما الهدف الأساسي الذي يركز عليه هذا الدرس؟','options',jsonb_build_array(r.goal,'حفظ المصطلحات دون تطبيق','تخطي المثال العملي','الانتقال لموضوع آخر'),'answer',0,'explanation','هدف الدرس هو النتيجة التعليمية التي يجب أن يحققها الطالب بعد دراسته.'),
      jsonb_build_object('question','أي عبارة تمثل التطبيق العملي المقترح لهذا الدرس؟','options',jsonb_build_array(r.example,'حذف كل بيانات المشروع','عدم تنفيذ أي تمرين','الاعتماد على الحفظ فقط'),'answer',0,'explanation','التطبيق العملي يحول المفهوم إلى مهارة قابلة للتنفيذ.'),
      jsonb_build_object('question','ما الخطأ الذي يجب على الطالب تجنبه في هذا الدرس؟','options',jsonb_build_array(r.mistakes,'اختبار الحل بعد تنفيذه','فهم المطلوب أولًا','مراجعة النتيجة'),'answer',0,'explanation','هذه النقطة مأخوذة من قسم الأخطاء الشائعة في الدرس.'),
      jsonb_build_object('question','ما التحدي العملي المرتبط بهذا الدرس؟','options',jsonb_build_array(r.challenge,'تخطي الدرس دون تطبيق','حفظ العنوان فقط','عدم مراجعة النتيجة'),'answer',0,'explanation','التحدي يقيس قدرة الطالب على تحويل شرح الدرس إلى تطبيق عملي.')
    );
    insert into public.lesson_quizzes(course_slug,level_number,lesson_number,questions,passing_score,published,updated_by)
    values(r.course_slug,r.level_number,r.lesson_number,qs,60,true,auth.uid())
    on conflict(course_slug,level_number,lesson_number) do update set questions=excluded.questions,passing_score=60,published=true,updated_by=auth.uid(),updated_at=now();
    n:=n+1;
  end loop;
  return n;
end;
$$;
revoke all on function public.seed_sql_quizzes() from public;
grant execute on function public.seed_sql_quizzes() to authenticated;
