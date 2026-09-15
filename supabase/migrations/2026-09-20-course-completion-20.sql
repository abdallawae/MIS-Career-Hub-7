-- MIS Career Hub: 20-lesson course completion + certificate issuance
-- Run this once in Supabase SQL Editor.
create or replace function public.issue_mis_certificate(p_course_slug text)
returns public.certificates
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  completed_count integer;
  student_name_value text;
  existing public.certificates;
  new_cert public.certificates;
  generated_id text;
begin
  if uid is null then raise exception 'LOGIN_REQUIRED'; end if;

  select count(distinct (level_number, lesson_number))::int
    into completed_count
  from public.lesson_progress
  where user_id = uid
    and course_slug = p_course_slug
    and completed = true;

  if completed_count < 20 then
    raise exception 'COURSE_NOT_COMPLETED';
  end if;

  select * into existing
  from public.certificates
  where user_id = uid
    and course_slug = p_course_slug
    and status = 'issued'
  order by issued_at asc
  limit 1;

  if existing.id is not null then return existing; end if;

  select coalesce(nullif(trim(full_name), ''), 'طالب')
    into student_name_value
  from public.profiles
  where id = uid;

  if student_name_value is null then student_name_value := 'طالب'; end if;

  generated_id := 'MISH-' || to_char(now(), 'YYYY') || '-' || upper(substr(replace(uid::text,'-',''),1,8)) || '-' || upper(substr(md5(p_course_slug || uid::text),1,4));

  insert into public.certificates(certificate_id,user_id,student_name,course_slug,status)
  values(generated_id,uid,student_name_value,p_course_slug,'issued')
  returning * into new_cert;

  return new_cert;
exception
  when unique_violation then
    select * into existing from public.certificates where user_id=uid and course_slug=p_course_slug and status='issued' order by issued_at asc limit 1;
    return existing;
end;
$$;
revoke all on function public.issue_mis_certificate(text) from public;
grant execute on function public.issue_mis_certificate(text) to authenticated;
