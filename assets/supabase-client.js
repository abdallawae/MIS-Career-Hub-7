window.sb = window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY);

window.MIS = {
  async user() {
    const { data } = await window.sb.auth.getUser();
    return data?.user || null;
  },
  async profile() {
    const user = await this.user();
    if (!user) return null;
    const { data } = await window.sb.from('profiles').select('*').eq('id', user.id).maybeSingle();
    return data || null;
  },
  async saveProfile(name) {
    const user = await this.user();
    if (!user) return null;
    const payload = { id: user.id, full_name: name || user.user_metadata?.full_name || user.email?.split('@')[0] || 'طالب' };
    const { data } = await window.sb.from('profiles').upsert(payload).select().maybeSingle();
    return data || null;
  },
  async enroll(courseSlug) {
    const user = await this.user();
    if (!user) return false;
    const { error } = await window.sb.from('course_enrollments').upsert({ user_id: user.id, course_slug: courseSlug }, { onConflict: 'user_id,course_slug' });
    return !error;
  },
  async completeLesson(courseSlug, level, lesson) {
    const user = await this.user();
    if (!user) return false;
    await this.enroll(courseSlug);
    const { error } = await window.sb.from('lesson_progress').upsert({ user_id: user.id, course_slug: courseSlug, level_number: Number(level), lesson_number: Number(lesson), completed: true, completed_at: new Date().toISOString() }, { onConflict: 'user_id,course_slug,level_number,lesson_number' });
    return !error;
  },
  async getProgress(courseSlug) {
    const user = await this.user();
    if (!user) return [];
    const { data } = await window.sb.from('lesson_progress').select('level_number,lesson_number,completed').eq('user_id', user.id).eq('course_slug', courseSlug).eq('completed', true);
    return data || [];
  },
  async saveQuiz(courseSlug, level, lesson, score) {
    const user = await this.user();
    if (!user) return false;
    const { error } = await window.sb.from('quiz_results').insert({ user_id: user.id, course_slug: courseSlug, level_number: Number(level), lesson_number: Number(lesson), score: Number(score) });
    return !error;
  },
  async issueCertificate(courseSlug, studentName) {
    const user = await this.user();
    if (!user) return { data: null, error: 'not_authenticated' };
    const progress = await this.getProgress(courseSlug);
    if (progress.length < 60) return { data: null, error: 'course_not_complete' };
    const profile = await this.profile();
    const name = studentName || profile?.full_name || user.user_metadata?.full_name || user.email?.split('@')[0] || 'طالب';
    const year = new Date().getFullYear();
    const shortUser = String(user.id).replace(/-/g, '').slice(0, 8).toUpperCase();
    const prefix = String(courseSlug).slice(0, 4).toUpperCase();
    const certificateId = `MISH-${year}-${shortUser}-${prefix}`;
    const { data, error } = await window.sb.from('certificates').upsert({ certificate_id: certificateId, user_id: user.id, student_name: name, course_slug: courseSlug, status: 'issued' }, { onConflict: 'certificate_id' }).select().single();
    return { data, error: error?.message || null };
  },
  async getCertificate(courseSlug) {
    const user = await this.user();
    if (!user) return null;
    const { data } = await window.sb.from('certificates').select('*').eq('user_id', user.id).eq('course_slug', courseSlug).eq('status', 'issued').maybeSingle();
    return data || null;
  },
  async verifyCertificate(certificateId) {
    const { data, error } = await window.sb.from('certificates').select('certificate_id,student_name,course_slug,issued_at,status').eq('certificate_id', certificateId).eq('status', 'issued').maybeSingle();
    return { data, error: error?.message || null };
  }
};
