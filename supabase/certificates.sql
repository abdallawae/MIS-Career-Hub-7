-- MIS Career Hub: one-time migration for real certificate issuance + public verification.
-- Run this in Supabase SQL Editor using the same project as the site.

create table if not exists public.certificates (
  id uuid primary key default gen_random_uuid(),
  certificate_id text not null unique,
  user_id uuid not null references auth.users(id) on delete cascade,
  student_name text not null,
  course_slug text not null,
  issued_at timestamptz not null default now(),
  status text not null default 'issued' check (status in ('issued','revoked')),
  created_at timestamptz not null default now()
);

create index if not exists certificates_user_id_idx on public.certificates(user_id);
create index if not exists certificates_course_slug_idx on public.certificates(course_slug);
create index if not exists certificates_status_idx on public.certificates(status);

alter table public.certificates enable row level security;

drop policy if exists "certificate owner can insert" on public.certificates;
create policy "certificate owner can insert"
on public.certificates for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "certificate owner can update" on public.certificates;
create policy "certificate owner can update"
on public.certificates for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "certificate owner can view own" on public.certificates;
create policy "certificate owner can view own"
on public.certificates for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "public can verify issued certificates" on public.certificates;
create policy "public can verify issued certificates"
on public.certificates for select
to anon, authenticated
using (status = 'issued');
