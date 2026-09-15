/* MIS Career Hub — Rich Lesson Enrichment
 * Expands every lesson into a deeper, professional learning experience.
 * The source lesson remains editable from Owner/Supabase; this layer adds
 * pedagogical structure without replacing the original content.
 */
(function(){
  const TRACKS={
    sql:'SQL وقواعد البيانات',excel:'Excel الاحترافي','power-bi':'Power BI','systems-analysis':'تحليل وتصميم النظم',erp:'ERP','python':'Python وتحليل البيانات',web:'تطوير الويب',cybersecurity:'الأمن السيبراني',cloud:'الحوسبة السحابية','project-management':'إدارة المشروعات',career:'المسار الوظيفي','digital-transformation':'التحول الرقمي'
  };
  const normalize=s=>String(s??'').trim();
  const bullets=s=>normalize(s).split(/[\n،؛]+/).map(x=>x.trim()).filter(Boolean).slice(0,8);
  function keywords(title,slug){
    const t=normalize(title).toLowerCase();
    const map={
      sql:['Database','Table','SELECT','WHERE','JOIN','GROUP BY','Primary Key','Foreign Key','NULL','Index','Transaction','Normalization'],
      excel:['Workbook','Worksheet','Cell','Formula','Function','Table','PivotTable','Lookup','Chart','Validation','Power Query','Dashboard'],
      'power-bi':['Power BI','Data Model','Power Query','DAX','Measure','Column','Relationship','Visual','Dashboard','Filter'],
      'systems-analysis':['Requirement','Stakeholder','Process','UML','Use Case','DFD','ERD','System Design','Testing','Documentation'],
      erp:['ERP','Module','Process','Master Data','Workflow','Inventory','Purchasing','Sales','Finance','Integration'],
      python:['Python','Variable','Data Type','Function','List','Dictionary','Pandas','NumPy','DataFrame','Exception','File'],
      web:['HTML','CSS','JavaScript','DOM','HTTP','API','Responsive Design','Form','Accessibility','Git'],
      cybersecurity:['CIA Triad','Threat','Vulnerability','Risk','Authentication','Authorization','Encryption','Phishing','Firewall','Incident'],
      cloud:['Cloud','IaaS','PaaS','SaaS','Virtual Machine','Storage','Network','IAM','Scaling','Backup'],
      'project-management':['Project','Scope','Schedule','Cost','Risk','Stakeholder','WBS','Agile','Scrum','KPI'],
      career:['CV','Portfolio','LinkedIn','Interview','Communication','Networking','Freelancing','Personal Brand','Job Search','Skills'],
      'digital-transformation':['Digital Transformation','Process','Automation','Data','Cloud','AI','Integration','Change Management','KPI','Governance']
    };
    const base=map[slug]||[];
    return base.filter(k=>t.includes(k.toLowerCase())).slice(0,4).concat(base.slice(0,4)).filter((v,i,a)=>a.indexOf(v)===i).slice(0,6);
  }
  function build(item,slug,level,lesson){
    const title=normalize(item?.title||item?.[0]||'الدرس');
    const goal=normalize(item?.goal||item?.[1]);
    const concept=normalize(item?.concept||item?.[2]);
    const example=normalize(item?.example||item?.[3]);
    const mistakes=bullets(item?.mistakes||item?.[4]);
    const challenge=normalize(item?.challenge||item?.[5]);
    const track=TRACKS[slug]||slug;
    const keys=keywords(title,slug);
    const prerequisites=level<=1?'لا توجد متطلبات سابقة. ابدأ من الصفر واقرأ المصطلحات الأساسية ببطء.':`راجع الدروس السابقة في المستوى ${Math.max(1,level-1)} قبل البدء، خصوصًا المصطلحات والأمثلة العملية.`;
    const steps=[
      `ابدأ بفهم السؤال أو المشكلة التي يحلها درس «${title}».`,
      'حدد المصطلحات الجديدة واكتب معناها بكلماتك أنت.',
      'تابع المثال خطوة بخطوة ولا تنتقل للنتيجة قبل فهم سبب كل خطوة.',
      'أعد تنفيذ المثال بنفسك مع تغيير البيانات أو السيناريو.',
      'نفّذ التحدي بدون نسخ الحل ثم راجع أخطاءك.',
      'اكتب ملخصًا من 3 إلى 5 نقاط قبل الانتقال للدرس التالي.'
    ];
    const realWorld=`في ${track}، تظهر فكرة «${title}» عندما نحتاج إلى تحويل مشكلة حقيقية داخل شركة إلى خطوات قابلة للتنفيذ والقياس. لا تتعامل مع الدرس كمعلومة للحفظ فقط؛ اربطه بعملية أو تقرير أو قرار إداري يمكن أن تستخدمه في مشروع حقيقي.`;
    const why=`لماذا يهمك هذا؟ لأن طالب MIS يحتاج إلى الجمع بين فهم التقنية وفهم احتياج العمل. إتقان «${title}» يساعدك على قراءة المشكلة، اختيار الحل المناسب، شرح الحل لغير المتخصص، ثم قياس النتيجة.`;
    const deep=`${concept}\n\nلفهم الموضوع بعمق، اسأل نفسك أربعة أسئلة: ما المشكلة التي يحلها؟ ما المدخلات التي يحتاجها؟ ما النتيجة التي ينتجها؟ ومتى لا يكون هذا الأسلوب هو الاختيار الأفضل؟\n\n${why}`;
    const practical=`${example}\n\nخطوات التطبيق المقترحة:\n${steps.map((s,i)=>`${i+1}. ${s}`).join('\n')}`;
    const terms=(keys.length?keys:['المفهوم الأساسي','المدخلات','المخرجات','التطبيق']).map(k=>`${k}: افهم المصطلح في سياق الدرس، ثم حاول إعطاء مثال من شركة أو مشروع تستخدمه فيه.`);
    const checklist=['هل أستطيع شرح الفكرة بدون النظر إلى الشرح؟','هل أستطيع تنفيذ المثال بنفسي؟','هل أعرف متى أستخدمها ومتى لا أستخدمها؟','هل أستطيع اكتشاف الخطأ إذا تغيرت البيانات؟','هل أستطيع ربطها بحالة عمل حقيقية؟'];
    const interview=[`اشرح «${title}» لشخص غير متخصص في دقيقة واحدة.`,`اذكر حالة عملية داخل شركة يمكن أن تستخدم فيها «${title}».`,`ما الخطأ الذي قد يحدث إذا استخدمت هذا المفهوم بطريقة غير صحيحة؟`];
    return {title,goal,deep,practical,mistakes,challenge,prerequisites,terms,checklist,interview,realWorld,summary:`بعد إنهاء هذا الدرس يجب أن تكون قادرًا على شرح «${title}»، تنفيذ مثال عليه، اكتشاف الأخطاء الأساسية، وربطه بسيناريو عملي داخل ${track}.`};
  }
  window.MIS_ENRICH_LESSON=build;
})();
