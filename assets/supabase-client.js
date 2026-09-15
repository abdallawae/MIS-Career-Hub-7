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
  async issueCertificate(courseSlug) {
    const { data, error } = await window.sb.rpc('issue_mis_certificate', { p_course_slug: courseSlug });
    return { data: data || null, error: error?.message || null };
  },
  async getCertificate(courseSlug) {
    const user = await this.user();
    if (!user) return null;
    const { data } = await window.sb.from('certificates').select('*').eq('user_id', user.id).eq('course_slug', courseSlug).eq('status', 'issued').order('issued_at', { ascending: true }).maybeSingle();
    return data || null;
  },
  async verifyCertificate(certificateId) {
    const { data, error } = await window.sb.from('certificates').select('certificate_id,student_name,course_slug,issued_at,status').eq('certificate_id', String(certificateId || '').trim()).eq('status', 'issued').maybeSingle();
    return { data, error: error?.message || null };
  }
};
