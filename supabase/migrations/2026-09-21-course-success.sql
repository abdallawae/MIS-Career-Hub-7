-- MIS Career Hub: final course success gate
-- A certificate is issued only after: 20/20 lessons + latest quiz average >= 60% + final project passed.

create table if not exists public.course_project_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_slug text not null,
  project_title text not null default '',
  project_description text not null default '',
  project_url text not null default '',
  status text not null default 'pending' check (status in ('pending','passed','rejected')),
  reviewer_note text not null default '',
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  unique(user_id, course_slug)
);

alter table public.course_project_submissions enable row level security;

create policy "students can view own project submissions"
on public.course_project_submissions for select
using (auth.uid() = user_id);

create policy "students can submit own project"
on public.course_project_submissions for insert
with check (auth.uid() = user_id);

create policy "admins can view all project submissions"
on public.course_project_submissions for select
using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create policy "admins can review projects"
on public.course_project_submissions for update
using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'))
with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create or replace function public.submit_final_project(
  p_course_slug text,
  p_project_title text,
  p_project_description text,
  p_project_url text default ''
)
returns public.course_project_submissions
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  result public.course_project_submissions;
begin
  if uid is null then raise exception 'LOGIN_REQUIRED'; end if;

  insert into public.course_project_submissions(
    user_id, course_slug, project_title, project_description, project_url, status, submitted_at
  ) values (
    uid,
    p_course_slug,
    coalesce(nullif(trim(p_project_title), ''), 'مشروع التخرج من المسار'),
    coalesce(nullif(trim(p_project_description), ''), ''),
    coalesce(nullif(trim(p_project_url), ''), ''),
    'pending',
    now()
  )
  on conflict (user_id, course_slug)
  do update set
    project_title = excluded.project_title,
    project_description = excluded.project_description,
    project_url = excluded.project_url,
    status = 'pending',
    reviewer_note = '',
    submitted_at = now(),
    reviewed_at = null
  returning * into result;

  return result;
end;
$$;

revoke all on function public.submit_final_project(text,text,text,text) from public;
grant execute on function public.submit_final_project(text,text,text,text) to authenticated;

create or replace function public.issue_mis_certificate(p_course_slug text)
returns public.certificates
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  completed_count integer;
  quiz_average numeric;
  project_passed boolean;
  student_name_value text;
  existing public.certificates;
  new_cert public.certificates;
  generated_id text;
begin
  if uid is null then raise exception 'LOGIN_REQUIRED'; end if;

  select count(distinct (level_number, lesson_number))::int
  into completed_count
  from public.lesson_progress
  where user_id = uid and course_slug = p_course_slug and completed = true;

  if completed_count < 20 then raise exception 'COURSE_NOT_COMPLETED'; end if;

  select coalesce(avg(latest.score), 0)
  into quiz_average
  from (
    select distinct on (level_number, lesson_number) score
    from public.quiz_results
    where user_id = uid and course_slug = p_course_slug
    order by level_number, lesson_number, created_at desc
  ) latest;

  if quiz_average < 60 then raise exception 'QUIZ_REQUIREMENT_NOT_MET'; end if;

  select exists (
    select 1 from public.course_project_submissions
    where user_id = uid and course_slug = p_course_slug and status = 'passed'
  ) into project_passed;

  if not project_passed then raise exception 'FINAL_PROJECT_NOT_PASSED'; end if;

  select * into existing
  from public.certificates
  where user_id = uid and course_slug = p_course_slug and status = 'issued'
  order by issued_at asc limit 1;

  if existing.id is not null then return existing; end if;

  select coalesce(nullif(trim(full_name), ''), 'طالب')
  into student_name_value
  from public.profiles where id = uid;

  if student_name_value is null then student_name_value := 'طالب'; end if;

  generated_id := 'MISH-' || to_char(now(), 'YYYY') || '-' ||
    upper(substr(replace(uid::text,'-',''),1,8)) || '-' ||
    upper(substr(md5(p_course_slug || uid::text),1,4));

  insert into public.certificates(certificate_id,user_id,student_name,course_slug,status)
  values(generated_id,uid,student_name_value,p_course_slug,'issued')
  returning * into new_cert;

  return new_cert;
exception
  when unique_violation then
    select * into existing from public.certificates
    where user_id=uid and course_slug=p_course_slug and status='issued'
    order by issued_at asc limit 1;
    return existing;
end;
$$;

revoke all on function public.issue_mis_certificate(text) from public;
grant execute on function public.issue_mis_certificate(text) to authenticated;
