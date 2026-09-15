(()=>{
  const TRACKS=['sql','excel','power-bi','systems-analysis','erp','python','web','cybersecurity','cloud','project-management','career','digital-transformation'];
  const names=['الأساسيات وبناء الصورة الكبيرة','المفاهيم والأدوات الأساسية','التطبيق العملي والتحليل','حل المشكلات واتخاذ القرار','المهارات المتقدمة','الممارسة المهنية','الإتقان والمشروع النهائي'];
  const sizes=[3,3,3,3,3,3,2];
  const flatten=course=>{
    if(!course) return [];
    if(Array.isArray(course.levels)) return course.levels.flat().filter(Boolean);
    if(course.levels&&typeof course.levels==='object') return Object.keys(course.levels).sort((a,b)=>+a-+b).flatMap(k=>course.levels[k]||[]).filter(Boolean);
    return [];
  };
  const normalize=(course,source)=>{
    const lessons=flatten(course).slice(0,20);
    const levels=[]; let p=0;
    sizes.forEach(size=>{levels.push(lessons.slice(p,p+size));p+=size;});
    return {...(course||{}),source,levelCount:7,lessonCount:lessons.length,levelNames:names,levels};
  };
  const rich=window.MIS_RICH_20||{};
  const legacy=window.MIS_COURSE_CONTENT||{};
  window.MIS_CURRICULUM_20={};
  window.MIS_COURSE_CONTENT_7={};
  window.MIS_CONTENT_DIAGNOSTICS={};
  TRACKS.forEach(k=>{
    const richCount=flatten(rich[k]).length;
    const legacyCount=flatten(legacy[k]).length;
    const useRich=richCount>=20;
    const source=useRich?'rich':legacyCount?'legacy':'missing';
    const c=useRich?rich[k]:legacy[k];
    const normalized=normalize(c,source);
    window.MIS_CONTENT_DIAGNOSTICS[k]={source,richLessons:richCount,legacyLessons:legacyCount,lessons:normalized.lessonCount};
    if(normalized.lessonCount) {
      window.MIS_CURRICULUM_20[k]=normalized;
      window.MIS_COURSE_CONTENT_7[k]=normalized;
    }
  });
  const banks=window.MIS_RICH_QUIZZES||{};
  TRACKS.forEach(k=>{
    const c=window.MIS_CURRICULUM_20[k],bank=banks[k];
    if(c&&bank){let n=1;c.levels.forEach(level=>level.forEach(lesson=>{lesson[6]=bank[n++]||[]}));}
  });
  const tracks=window.MIS_TRACK_CONTENT||{};
  window.MIS_TRACK_CONTENT_7={};
  Object.keys(tracks).forEach(k=>window.MIS_TRACK_CONTENT_7[k]={...tracks[k],levelCount:7,lessonCount:window.MIS_CURRICULUM_20[k]?.lessonCount||20,levelNames:names});
  window.MIS_COURSE_STRUCTURE_7={levelCount:7,totalLessons:20,lessonSizes:sizes};
})();
