# MIS Career Hub — Owner Edition

## المرحلة الجديدة: منصة تعليمية حقيقية

### 1. أنشئ مشروع Supabase باسمك
### 2. من SQL Editor شغّل محتوى `supabase/schema.sql`
### 3. انسخ `supabase/config.example.js` إلى `supabase/config.js`
### 4. ضع Project URL وPublishable/Anon Key فقط
### 5. من Authentication فعّل Email، Google، Facebook وPhone حسب ما تحتاجه
### 6. أنشئ أول حساب لك من الموقع
### 7. في SQL Editor اجعل حسابك Owner:

```sql
update public.profiles
set role='owner'
where id=(select id from auth.users where email='YOUR_EMAIL');
```

## مهم جدًا
- لا تضع Service Role أو Secret Key داخل الموقع أو GitHub.
- مفاتيحك وحساباتك تظل ملكك أنت.
- Phone OTP يحتاج إعداد مزود SMS متوافق داخل Supabase.
- Google/Facebook يحتاجان إعداد Redirect URLs في مزودي OAuth.

## النشر
ارفع محتويات المشروع إلى GitHub ثم اربط المستودع بـ Vercel.
