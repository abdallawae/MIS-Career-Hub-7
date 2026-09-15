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
