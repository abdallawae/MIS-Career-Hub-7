(()=>{
  const names=['الأساسيات وبناء الصورة الكبيرة','المفاهيم والأدوات الأساسية','التطبيق العملي والتحليل','حل المشكلات واتخاذ القرار','المهارات المتقدمة','الممارسة المهنية','الإتقان والمشروع النهائي'];
  const sizes=[3,3,3,3,3,3,2];
  const load=(src)=>document.write('<script src="'+src+'"><\\/script>');
  load('assets/rich-sql-20.js?v=20260923');
  load('assets/rich-sql-quizzes-v2.js?v=20260923');
  load('assets/rich-excel-20.js?v=20260923');
  load('assets/rich-excel-quizzes-v2.js?v=20260923');
  const normalize=course=>{if(!course)return null;return {...course,levelCount:7,lessonCount:20,levelNames:names}};
  const curated=window.MIS_RICH_20||{};
  window.MIS_CURRICULUM_20=window.MIS_CURRICULUM_20||{};
  if(curated.sql)window.MIS_CURRICULUM_20.sql=normalize(curated.sql);
  if(curated.excel)window.MIS_CURRICULUM_20.excel=normalize(curated.excel);
  const sql=window.MIS_CURRICULUM_20.sql;
  if(sql&&window.MIS_RICH_QUIZZES?.sql){let n=0;sql.levels.forEach(level=>level.forEach(lesson=>{lesson[6]=window.MIS_RICH_QUIZZES.sql[n++]||[]}));}
  const excel=window.MIS_CURRICULUM_20.excel;
  if(excel&&window.MIS_RICH_QUIZZES?.excel){let n=1;excel.levels.forEach(level=>level.forEach(lesson=>{lesson[6]=window.MIS_RICH_QUIZZES.excel[n++]||[]}));}
  if(sql)window.MIS_COURSE_CONTENT_7={...(window.MIS_COURSE_CONTENT||{}),sql};
  if(excel)window.MIS_COURSE_CONTENT_7={...(window.MIS_COURSE_CONTENT_7||{}),excel};
  const tracks=window.MIS_TRACK_CONTENT||{};window.MIS_TRACK_CONTENT_7={};
  Object.keys(tracks).forEach(k=>window.MIS_TRACK_CONTENT_7[k]={...tracks[k],levelCount:7,lessonCount:20,levelNames:names});
  window.MIS_COURSE_STRUCTURE_7={levelCount:7,totalLessons:20,lessonSizes:sizes};
})();