-- MIS Career Hub: seed the 12 official learning tracks into public.courses
-- Run this once in Supabase SQL Editor after the courses table exists.

insert into public.courses (name, slug, is_published)
values
  ('SQL وقواعد البيانات', 'sql', true),
  ('Excel الاحترافي', 'excel', true),
  ('Power BI', 'power-bi', true),
  ('تحليل وتصميم النظم', 'systems-analysis', true),
  ('ERP', 'erp', true),
  ('Python وتحليل البيانات', 'python', true),
  ('تطوير الويب', 'web', true),
  ('الأمن السيبراني', 'cybersecurity', true),
  ('الحوسبة السحابية', 'cloud', true),
  ('إدارة المشروعات', 'project-management', true),
  ('المسار الوظيفي', 'career', true),
  ('التحول الرقمي', 'digital-transformation', true)
on conflict (slug) do update
set name = excluded.name,
    is_published = excluded.is_published;

-- Verification
select count(*) as total_courses,
       count(*) filter (where is_published = true) as published_courses
from public.courses;
