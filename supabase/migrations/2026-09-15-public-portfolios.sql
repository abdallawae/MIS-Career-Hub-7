-- MIS Career Hub: public student portfolios
-- Run this once in Supabase SQL Editor. No password or secret key is required.
create table if not exists public.portfolio_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  public_slug text not null unique check (public_slug ~ '^[a-z0-9][a-z0-9-]{2,48}$'),
  display_name text not null default 'طالب MIS',
  headline text not null default 'طالب نظم معلومات إدارية',
  bio text not null default 'طالب نظم معلومات إدارية يهتم بالتعلم العملي وبناء مهارات قابلة للتطبيق في سوق العمل.',
  avatar_url text,
  linkedin_url text,
  github_url text,
  website_url text,
  public_enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.portfolio_profiles enable row level security;

drop policy if exists "public can view enabled portfolios" on public.portfolio_profiles;
create policy "public can view enabled portfolios"
on public.portfolio_profiles for select
using (public_enabled = true);

drop policy if exists "student can manage own portfolio" on public.portfolio_profiles;
create policy "student can manage own portfolio"
on public.portfolio_profiles for all
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create or replace function public.touch_portfolio_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

drop trigger if exists portfolio_profiles_updated_at on public.portfolio_profiles;
create trigger portfolio_profiles_updated_at
before update on public.portfolio_profiles
for each row execute function public.touch_portfolio_updated_at();

create or replace function public.ensure_my_portfolio()
returns public.portfolio_profiles
language plpgsql security definer set search_path = public
as $$
declare p public.portfolio_profiles; base_slug text; candidate text; n integer := 0;
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  select * into p from public.portfolio_profiles where user_id = auth.uid();
  if p.user_id is not null then return p; end if;
  base_slug := 'student-' || replace(substr(auth.uid()::text,1,8),'-','');
  candidate := base_slug;
  while exists (select 1 from public.portfolio_profiles where public_slug = candidate) loop
    n := n + 1; candidate := base_slug || '-' || n::text;
  end loop;
  insert into public.portfolio_profiles(user_id, public_slug, display_name)
  values (auth.uid(), candidate, coalesce((select full_name from public.profiles where id=auth.uid()), 'طالب MIS'))
  returning * into p;
  return p;
end;
$$;

grant execute on function public.ensure_my_portfolio() to authenticated;
revoke execute on function public.ensure_my_portfolio() from anon;
