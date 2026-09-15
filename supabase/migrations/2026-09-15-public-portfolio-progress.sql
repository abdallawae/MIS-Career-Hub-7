-- Public Portfolio: expose only aggregate public learning data for profiles that opted in.
create or replace function public.get_public_portfolio(p_slug text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  p record;
  result jsonb;
begin
  select user_id, public_slug, display_name, headline, bio, avatar_url,
         linkedin_url, github_url, website_url, skills, projects
  into p
  from public.portfolio_profiles
  where public_slug = p_slug
    and public_enabled = true;

  if not found then
    return null;
  end if;

  select jsonb_build_object(
    'profile', jsonb_build_object(
      'public_slug', p.public_slug,
      'display_name', p.display_name,
      'headline', p.headline,
      'bio', p.bio,
      'avatar_url', p.avatar_url,
      'linkedin_url', p.linkedin_url,
      'github_url', p.github_url,
      'website_url', p.website_url,
      'skills', p.skills,
      'projects', p.projects
    ),
    'progress', coalesce((
      select jsonb_agg(jsonb_build_object(
        'course_slug', x.course_slug,
        'completed_lessons', x.completed_lessons
      ) order by x.course_slug)
      from (
        select lp.course_slug, count(distinct (lp.level_number, lp.lesson_number))::int as completed_lessons
        from public.lesson_progress lp
        where lp.user_id = p.user_id
        group by lp.course_slug
      ) x
    ), '[]'::jsonb),
    'certificates', coalesce((
      select jsonb_agg(jsonb_build_object(
        'certificate_id', c.certificate_id,
        'course_slug', c.course_slug,
        'issued_at', c.issued_at
      ) order by c.issued_at desc)
      from public.certificates c
      where c.user_id = p.user_id
        and c.status = 'issued'
    ), '[]'::jsonb)
  ) into result;

  return result;
end;
$$;

revoke all on function public.get_public_portfolio(text) from public;
grant execute on function public.get_public_portfolio(text) to anon, authenticated;
