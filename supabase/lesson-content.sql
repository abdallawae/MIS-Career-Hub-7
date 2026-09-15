-- MIS Career Hub: lesson content CMS
create table if not exists public.lesson_content (
  id uuid primary key default gen_random_uuid(),
  course_slug text not null,
  level_number integer not null check (level_number between 1 and 10),
  lesson_number integer not null check (lesson_number between 1 and 6),
  title text not null,
  goal text not null default '',
  concept text not null default '',
  example text not null default '',
  mistakes text not null default '',
  challenge text not null default '',
  published boolean not null default true,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(course_slug, level_number, lesson_number)
);

create index if not exists lesson_content_course_idx on public.lesson_content(course_slug);
create index if not exists lesson_content_published_idx on public.lesson_content(published);

alter table public.lesson_content enable row level security;

drop policy if exists "Public can read published lesson content" on public.lesson_content;
drop policy if exists "Admins can read all lesson content" on public.lesson_content;
drop policy if exists "Admins can insert lesson content" on public.lesson_content;
drop policy if exists "Admins can update lesson content" on public.lesson_content;
drop policy if exists "Admins can delete lesson content" on public.lesson_content;

create policy "Public can read published lesson content"
on public.lesson_content for select
to anon, authenticated
using (published = true);

create policy "Admins can read all lesson content"
on public.lesson_content for select
to authenticated
using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create policy "Admins can insert lesson content"
on public.lesson_content for insert
to authenticated
with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create policy "Admins can update lesson content"
on public.lesson_content for update
to authenticated
using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'))
with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create policy "Admins can delete lesson content"
on public.lesson_content for delete
to authenticated
using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create or replace function public.set_lesson_content_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists lesson_content_updated_at on public.lesson_content;
create trigger lesson_content_updated_at
before update on public.lesson_content
for each row execute function public.set_lesson_content_updated_at();