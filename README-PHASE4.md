# MIS Career Hub — Phase 4

هذه النسخة تضيف أساس لوحة Owner مرتبطة بـSupabase.

## قبل النشر
1. أنشئ مشروع Supabase باسمك.
2. نفّذ `supabase/schema.sql` في SQL Editor.
3. انسخ `supabase/config.example.js` إلى `supabase/config.js` وضع **Project URL + public anon key فقط**.
4. لا تضع `service_role` أو أي Secret Key في GitHub.
5. أنشئ حسابك في Auth ثم غيّر `profiles.role` إلى `admin` من داخل قاعدة البيانات.
6. فعّل Google/Facebook/Phone في Supabase حسب بيانات مزودي الخدمة.

> لوحة Owner لن تعتبر المستخدم Admin إلا إذا كان `role='admin'` في جدول profiles.
