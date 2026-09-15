(()=>{
  const flatten=(course)=>{
    if(!course) return [];
    const levels=course.levels;
    const list=Array.isArray(levels)?levels:Object.keys(levels||{}).sort((a,b)=>Number(a)-Number(b)).map(k=>levels[k]);
    return list.flatMap(level=>Array.isArray(level)?level:[]).filter(Boolean);
  };
  const redistribute=(course)=>{
    const flat=flatten(course);
    const sizes=[9,9,9,9,8,8,8];
    const levels=[]; let p=0;
    sizes.forEach(n=>{levels.push(flat.slice(p,p+n));p+=n;});
    return {...course,levels,levelCount:7,lessonCount:flat.length};
  };
  const sql=window.MIS_COURSE_CONTENT?.sql;
  if(sql) window.MIS_COURSE_CONTENT_7={...(window.MIS_COURSE_CONTENT||{}),sql:redistribute(sql)};
  const tracks=window.MIS_TRACK_CONTENT||{};
  window.MIS_TRACK_CONTENT_7={};
  Object.keys(tracks).forEach(k=>window.MIS_TRACK_CONTENT_7[k]=redistribute(tracks[k]));
  window.MIS_COURSE_STRUCTURE_7={levelCount:7,totalLessons:60,lessonSizes:[9,9,9,9,8,8,8]};
})();
