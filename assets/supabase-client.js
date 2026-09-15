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
    if (!user) return;
    await window.sb.from('profiles').upsert({ id: user.id, full_name: name || user.user_metadata?.full_name || user.email?.split('@')[0] || 'طالب' });
  },
  async completeLesson(courseSlug, level, lesson) {
    const user = await this.user();
    if (!user) return false;
    await window.sb.from('course_enrollments').upsert({ user_id: user.id, course_slug: courseSlug }, { onConflict: 'user_id,course_slug' });
    const { error } = await window.sb.from('lesson_progress').upsert({ user_id: user.id, course_slug: courseSlug, level_number: Number(level), lesson_number: Number(lesson), completed: true, completed_at: new Date().toISOString() }, { onConflict: 'user_id,course_slug,level_number,lesson_number' });
    return !error;
  },
  async saveQuiz(courseSlug, level, lesson, score) {
    const user = await this.user();
    if (!user) return false;
    const { error } = await window.sb.from('quiz_results').insert({ user_id: user.id, course_slug: courseSlug, level_number: Number(level), lesson_number: Number(lesson), score: Number(score) });
    return !error;
  }
};
