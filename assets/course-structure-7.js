(()=>{
  const names=['الأساسيات وبناء الصورة الكبيرة','المفاهيم والأدوات الأساسية','التطبيق العملي والتحليل','حل المشكلات واتخاذ القرار','المهارات المتقدمة','الممارسة المهنية','الإتقان والمشروع النهائي'];
  const sizes=[3,3,3,3,3,3,2];
  const load=(src)=>document.write('<script src="'+src+'"><\\/script>');
  load('assets/rich-sql-20.js?v=20260923');load('assets/rich-sql-quizzes-v2.js?v=20260923');
  load('assets/rich-excel-20.js?v=20260923');load('assets/rich-excel-quizzes-v2.js?v=20260923');
  load('assets/rich-powerbi-20.js?v=20260923');load('assets/rich-powerbi-quizzes-v2.js?v=20260923');
  load('assets/rich-systems-analysis-20.js?v=20260924');load('assets/rich-systems-analysis-quizzes-v2.js?v=20260924');
  load('assets/rich-erp-20.js?v=20260924');load('assets/rich-erp-quizzes-v2.js?v=20260924');
  load('assets/rich-python-20.js?v=20260925');load('assets/rich-python-quizzes-v2.js?v=20260925');
  const normalize=course=>course?{...course,levelCount:7,lessonCount:20,levelNames:names}:null;
  const curated=window.MIS_RICH_20||{};window.MIS_CURRICULUM_20=window.MIS_CURRICULUM_20||{};
  ['sql','excel','power-bi','systems-analysis','erp','python'].forEach(k=>{if(curated[k])window.MIS_CURRICULUM_20[k]=normalize(curated[k]);});
  ['sql','excel','power-bi','systems-analysis','erp','python'].forEach(k=>{const c=window.MIS_CURRICULUM_20[k],bank=window.MIS_RICH_QUIZZES?.[k];if(c&&bank){let n=1;c.levels.forEach(level=>level.forEach(lesson=>{lesson[6]=bank[n++]||[]}));}});
  window.MIS_COURSE_CONTENT_7={...(window.MIS_COURSE_CONTENT||{})};['sql','excel','power-bi','systems-analysis','erp','python'].forEach(k=>{if(window.MIS_CURRICULUM_20[k])window.MIS_COURSE_CONTENT_7[k]=window.MIS_CURRICULUM_20[k];});
  const tracks=window.MIS_TRACK_CONTENT||{};window.MIS_TRACK_CONTENT_7={};Object.keys(tracks).forEach(k=>window.MIS_TRACK_CONTENT_7[k]={...tracks[k],levelCount:7,lessonCount:20,levelNames:names});
  window.MIS_COURSE_STRUCTURE_7={levelCount:7,totalLessons:20,lessonSizes:sizes};
})();
