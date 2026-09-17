-- Prevent an already-approved final project from being reset to pending by a student.
-- Run after the existing course-success migration in Supabase SQL Editor.

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

  select * into result
  from public.course_project_submissions
  where user_id = uid and course_slug = p_course_slug
  limit 1;

  if result.status = 'passed' then
    return result;
  end if;

  insert into public.course_project_submissions(
    user_id, course_slug, project_title, project_description, project_url,
    status, reviewer_note, submitted_at, reviewed_at
  ) values (
    uid,
    p_course_slug,
    coalesce(nullif(trim(p_project_title), ''), 'مشروع التخرج من المسار'),
    coalesce(nullif(trim(p_project_description), ''), ''),
    coalesce(nullif(trim(p_project_url), ''), ''),
    'pending', '', now(), null
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
