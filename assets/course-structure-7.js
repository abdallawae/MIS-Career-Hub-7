(()=>{
  const names=['الأساسيات وبناء الصورة الكبيرة','المفاهيم والأدوات الأساسية','التطبيق العملي والتحليل','حل المشكلات واتخاذ القرار','المهارات المتقدمة','الممارسة المهنية','الإتقان والمشروع النهائي'];
  const sizes=[3,3,3,3,3,3,2];
  const load=(src)=>document.write('<script src="'+src+'"><\\/script>');
  load('assets/rich-sql-20.js?v=20260923');
  load('assets/rich-sql-quizzes-v2.js?v=20260923');
  const redistribute=course=>{const flat=(course?.levels||[]).flatMap(x=>Array.isArray(x)?x:[]).filter(Boolean).slice(0,20);const levels=[];let p=0;sizes.forEach(n=>{levels.push(flat.slice(p,p+n));p+=n});return {...course,levels,levelCount:7,lessonCount:20,levelNames:names}};
  const curated=window.MIS_RICH_20||{};
  const sql=curated.sql;
  const oldSql=window.MIS_COURSE_CONTENT?.sql;
  const sql7=sql&&Array.isArray(sql.levels)?{...sql,levelCount:7,lessonCount:20,levelNames:names}:redistribute(oldSql);
  window.MIS_CURRICULUM_20=window.MIS_CURRICULUM_20||{};
  if(sql7)window.MIS_CURRICULUM_20.sql=sql7;
  if(sql7&&window.MIS_RICH_QUIZZES?.sql){let n=0;sql7.levels.forEach(level=>level.forEach(lesson=>{lesson[6]=window.MIS_RICH_QUIZZES.sql[n++]||[]}));}
  if(sql7)window.MIS_COURSE_CONTENT_7={...(window.MIS_COURSE_CONTENT||{}),sql:sql7};
  const tracks=window.MIS_TRACK_CONTENT||{};
  window.MIS_TRACK_CONTENT_7={};
  Object.keys(tracks).forEach(k=>window.MIS_TRACK_CONTENT_7[k]=redistribute(tracks[k]));
  window.MIS_COURSE_STRUCTURE_7={levelCount:7,totalLessons:20,lessonSizes:sizes};
})();