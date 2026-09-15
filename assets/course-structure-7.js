(()=>{
  const flatten=course=>{if(!course)return[];const lv=course.levels;const list=Array.isArray(lv)?lv:Object.keys(lv||{}).sort((a,b)=>+a-+b).map(k=>lv[k]);return list.flatMap(x=>Array.isArray(x)?x:[]).filter(Boolean)};
  const redistribute=course=>{const flat=flatten(course).slice(0,20),sizes=[3,3,3,3,3,3,2],levels=[],names=['الأساسيات وبناء الصورة الكبيرة','المفاهيم والأدوات الأساسية','التطبيق العملي والتحليل','حل المشكلات واتخاذ القرار','المهارات المتقدمة','الممارسة المهنية','الإتقان والمشروع النهائي'];let p=0;sizes.forEach(n=>{levels.push(flat.slice(p,p+n));p+=n});return {...course,levels,levelCount:7,lessonCount:20,levelNames:names}};
  const sql=window.MIS_COURSE_CONTENT?.sql;if(sql)window.MIS_COURSE_CONTENT_7={...(window.MIS_COURSE_CONTENT||{}),sql:redistribute(sql)};
  const tracks=window.MIS_TRACK_CONTENT||{};window.MIS_TRACK_CONTENT_7={};Object.keys(tracks).forEach(k=>window.MIS_TRACK_CONTENT_7[k]=redistribute(tracks[k]));
  window.MIS_COURSE_STRUCTURE_7={levelCount:7,totalLessons:20,lessonSizes:[3,3,3,3,3,3,2]};
})();
