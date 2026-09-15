# MIS Career Hub — Supabase Connected

تم إعداد `supabase/config.js` باستخدام Project URL والمفتاح Publishable اللذين وفرهما مالك المشروع.

## قبل الاختبار
1. نفّذ `supabase/schema.sql` مرة واحدة داخل Supabase SQL Editor.
2. في Authentication فعّل Google/Facebook إذا أردت استخدامهما، وأضف Redirect URL:
   `https://abdallawae.github.io/MIS-Career-Hub-7/auth.html`
3. فعّل مزود SMS إذا أردت Phone OTP.
4. لإنشاء المالك: سجّل حسابًا عاديًا أولًا، ثم غيّر `profiles.role` لهذا الحساب إلى `admin` من SQL Editor مرة واحدة.

> المفتاح الموجود في `config.js` Publishable/Anon فقط. لا تضع Service Role/Secret Key في GitHub.
