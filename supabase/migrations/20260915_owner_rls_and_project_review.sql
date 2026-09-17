-- MIS Career Hub — Owner/RLS hardening for the 20-lesson platform
-- Run this migration in Supabase SQL Editor for the live project.
-- Safe version: does not assume optional course_slug/status columns exist on every table.

create schema if not exists private;

create or replace function private.is_admin()
returns boolean
language sql
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.role = 'admin'
  );
$$;

revoke all on function private.is_admin() from public;
grant execute on function private.is_admin() to authenticated;

-- Profiles
alter table public.profiles enable row level security;
drop policy if exists "profiles_select_own_or_admin" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin" on public.profiles
  for select to authenticated
  using ((select auth.uid()) = id or (select private.is_admin()));
create policy "profiles_insert_own" on public.profiles
  for insert to authenticated
  with check ((select auth.uid()) = id);
create policy "profiles_update_own_or_admin" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id or (select private.is_admin()))
  with check ((select auth.uid()) = id or (select private.is_admin()));

-- Final project submissions
alter table public.course_project_submissions enable row level security;
drop policy if exists "project_select_own_or_admin" on public.course_project_submissions;
drop policy if exists "project_insert_own" on public.course_project_submissions;
drop policy if exists "project_update_own_or_admin" on public.course_project_submissions;
drop policy if exists "project_delete_admin" on public.course_project_submissions;
create policy "project_select_own_or_admin" on public.course_project_submissions
  for select to authenticated
  using ((select auth.uid()) = user_id or (select private.is_admin()));
create policy "project_insert_own" on public.course_project_submissions
  for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "project_update_own_or_admin" on public.course_project_submissions
  for update to authenticated
  using ((select auth.uid()) = user_id or (select private.is_admin()))
  with check ((select auth.uid()) = user_id or (select private.is_admin()));
create policy "project_delete_admin" on public.course_project_submissions
  for delete to authenticated
  using ((select private.is_admin()));

-- Student progress
alter table public.lesson_progress enable row level security;
drop policy if exists "lesson_progress_select_own_or_admin" on public.lesson_progress;
drop policy if exists "lesson_progress_insert_own" on public.lesson_progress;
drop policy if exists "lesson_progress_update_own_or_admin" on public.lesson_progress;
create policy "lesson_progress_select_own_or_admin" on public.lesson_progress
  for select to authenticated
  using ((select auth.uid()) = user_id or (select private.is_admin()));
create policy "lesson_progress_insert_own" on public.lesson_progress
  for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "lesson_progress_update_own_or_admin" on public.lesson_progress
  for update to authenticated
  using ((select auth.uid()) = user_id or (select private.is_admin()))
  with check ((select auth.uid()) = user_id or (select private.is_admin()));

-- Quiz results
alter table public.quiz_results enable row level security;
drop policy if exists "quiz_results_select_own_or_admin" on public.quiz_results;
drop policy if exists "quiz_results_insert_own" on public.quiz_results;
create policy "quiz_results_select_own_or_admin" on public.quiz_results
  for select to authenticated
  using ((select auth.uid()) = user_id or (select private.is_admin()));
create policy "quiz_results_insert_own" on public.quiz_results
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

-- Course enrollments
alter table public.course_enrollments enable row level security;
drop policy if exists "enrollments_select_own_or_admin" on public.course_enrollments;
drop policy if exists "enrollments_insert_own" on public.course_enrollments;
create policy "enrollments_select_own_or_admin" on public.course_enrollments
  for select to authenticated
  using ((select auth.uid()) = user_id or (select private.is_admin()));
create policy "enrollments_insert_own" on public.course_enrollments
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

-- CMS lesson content
alter table public.lesson_content enable row level security;
drop policy if exists "lesson_content_read_published" on public.lesson_content;
drop policy if exists "lesson_content_admin_all" on public.lesson_content;
create policy "lesson_content_read_published" on public.lesson_content
  for select to authenticated
  using (published = true or (select private.is_admin()));
create policy "lesson_content_admin_all" on public.lesson_content
  for all to authenticated
  using ((select private.is_admin()))
  with check ((select private.is_admin()));

-- CMS lesson quizzes
alter table public.lesson_quizzes enable row level security;
drop policy if exists "lesson_quizzes_read_published" on public.lesson_quizzes;
drop policy if exists "lesson_quizzes_admin_all" on public.lesson_quizzes;
create policy "lesson_quizzes_read_published" on public.lesson_quizzes
  for select to authenticated
  using (published = true or (select private.is_admin()));
create policy "lesson_quizzes_admin_all" on public.lesson_quizzes
  for all to authenticated
  using ((select private.is_admin()))
  with check ((select private.is_admin()));

-- Certificates
alter table public.certificates enable row level security;
drop policy if exists "certificates_select_own_or_admin" on public.certificates;
drop policy if exists "certificates_admin_all" on public.certificates;
create policy "certificates_select_own_or_admin" on public.certificates
  for select to authenticated
  using ((select auth.uid()) = user_id or (select private.is_admin()));
create policy "certificates_admin_all" on public.certificates
  for all to authenticated
  using ((select private.is_admin()))
  with check ((select private.is_admin()));

-- Keep browser roles narrow; service_role remains the server-side bypass role.
revoke all on table public.course_project_submissions from anon;
revoke all on table public.course_project_submissions from authenticated;
grant select, insert, update, delete on table public.course_project_submissions to authenticated;

revoke all on table public.lesson_content from anon;
revoke all on table public.lesson_content from authenticated;
grant select, insert, update, delete on table public.lesson_content to authenticated;

revoke all on table public.lesson_quizzes from anon;
revoke all on table public.lesson_quizzes from authenticated;
grant select, insert, update, delete on table public.lesson_quizzes to authenticated;

revoke all on table public.certificates from anon;
revoke all on table public.certificates from authenticated;
grant select, insert, update, delete on table public.certificates to authenticated;

revoke all on table public.lesson_progress from anon;
revoke all on table public.lesson_progress from authenticated;
grant select, insert, update on table public.lesson_progress to authenticated;

revoke all on table public.quiz_results from anon;
revoke all on table public.quiz_results from authenticated;
grant select, insert on table public.quiz_results to authenticated;

revoke all on table public.course_enrollments from anon;
revoke all on table public.course_enrollments from authenticated;
grant select, insert on table public.course_enrollments to authenticated;

revoke all on table public.profiles from anon;
revoke all on table public.profiles from authenticated;
grant select, insert, update on table public.profiles to authenticated;

-- Indexes were intentionally removed here because the live schema may use
-- different column names. RLS works correctly without these optional indexes.
