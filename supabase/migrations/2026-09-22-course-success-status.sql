-- MIS Career Hub: course success status helper
create or replace function public.course_success_status(p_course_slug text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  completed_count integer;
  quiz_average numeric := 0;
  project_status text := 'not_submitted';
  lessons_ok boolean;
  quiz_ok boolean;
  project_ok boolean;
  passed boolean;
begin
  if uid is null then raise exception 'LOGIN_REQUIRED'; end if;

  select count(distinct (level_number, lesson_number))::int
    into completed_count
  from public.lesson_progress
  where user_id = uid and course_slug = p_course_slug and completed = true;

  select coalesce(avg(latest.score),0)
    into quiz_average
  from (
    select distinct on (level_number, lesson_number) score
    from public.quiz_results
    where user_id = uid and course_slug = p_course_slug
    order by level_number, lesson_number, created_at desc
  ) latest;

  select coalesce(status,'not_submitted')
    into project_status
  from public.course_project_submissions
  where user_id = uid and course_slug = p_course_slug;

  lessons_ok := completed_count >= 20;
  quiz_ok := quiz_average >= 60;
  project_ok := project_status = 'passed';
  passed := lessons_ok and quiz_ok and project_ok;

  return jsonb_build_object(
    'course_slug', p_course_slug,
    'completed_lessons', completed_count,
    'required_lessons', 20,
    'quiz_average', round(quiz_average,2),
    'required_quiz_average', 60,
    'project_status', project_status,
    'lessons_ok', lessons_ok,
    'quiz_ok', quiz_ok,
    'project_ok', project_ok,
    'passed', passed
  );
end;
$$;

revoke all on function public.course_success_status(text) from public;
grant execute on function public.course_success_status(text) to authenticated;

-- Re-apply the certificate gate so issuance always uses the same three requirements.
create or replace function public.issue_mis_certificate(p_course_slug text)
returns public.certificates
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  s jsonb;
  student_name_value text;
  existing public.certificates;
  new_cert public.certificates;
  generated_id text;
begin
  if uid is null then raise exception 'LOGIN_REQUIRED'; end if;

  s := public.course_success_status(p_course_slug);
  if coalesce((s->>'passed')::boolean,false) is not true then
    if coalesce((s->>'completed_lessons')::integer,0) < 20 then raise exception 'COURSE_NOT_COMPLETED'; end if;
    if coalesce((s->>'quiz_average')::numeric,0) < 60 then raise exception 'QUIZ_REQUIREMENT_NOT_MET'; end if;
    raise exception 'FINAL_PROJECT_NOT_PASSED';
  end if;

  select * into existing
  from public.certificates
  where user_id=uid and course_slug=p_course_slug and status='issued'
  order by issued_at asc limit 1;
  if existing.id is not null then return existing; end if;

  select coalesce(nullif(trim(full_name),''),'طالب') into student_name_value
  from public.profiles where id=uid;
  if student_name_value is null then student_name_value := 'طالب'; end if;

  generated_id := 'MISH-' || to_char(now(),'YYYY') || '-' ||
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
