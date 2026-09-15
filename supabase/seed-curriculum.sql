-- MIS Career Hub: seed the 12-track / 720-lesson curriculum.
-- Run this file once in Supabase SQL Editor after lesson-content.sql.
-- It is idempotent: existing lesson rows are updated, not duplicated.

create or replace function public.seed_mis_curriculum()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  tracks jsonb := $tracks$
  {
    "sql": {"title":"SQL وقواعد البيانات","levels":[
      ["ما هي قاعدة البيانات؟","الجداول والصفوف والأعمدة","DBMS وSQL","إنشاء قاعدة وجدول","أول SELECT","مراجعة المستوى الأول"],
      ["WHERE وتصفية البيانات","AND وOR وNOT","ORDER BY","DISTINCT وAlias","LIMIT وPagination","تحدي المستوى الثاني"],
      ["COUNT وSUM","AVG وMIN وMAX","GROUP BY","HAVING","CASE","مراجعة التقارير التجميعية"],
      ["INSERT","UPDATE","DELETE","PRIMARY KEY","NOT NULL وUNIQUE وCHECK","مراجعة CRUD"],
      ["العلاقات بين الجداول","INNER JOIN","LEFT JOIN","JOIN بأكثر من جدول","مشكلة التكرار في JOIN","مشروع العلاقات"],
      ["Subquery","IN وEXISTS","CTE وWITH","UNION وUNION ALL","VIEW","مراجعة المستوى السادس"],
      ["التطبيع Normalization","Indexes","Transactions","ACID","EXPLAIN وخطة التنفيذ","تحدي الأداء"],
      ["Window Functions","ROW_NUMBER وRANK","Stored Procedures","Triggers","NULL وCOALESCE","مراجعة SQL المتقدم"],
      ["من السؤال الإداري إلى Query","تقارير المبيعات","تحليل العملاء","تحليل الاتجاهات الزمنية","جودة البيانات والتحقق","مشروع تحليل SQL"],
      ["تصميم مشروع قاعدة بيانات","ERD والمفاتيح","بناء قاعدة المشروع","10 استعلامات Portfolio","التوثيق وGitHub Portfolio","مشروع التخرج SQL"]
    ]},
    "excel":{"title":"Excel الاحترافي","levels":[
      ["واجهة Excel وWorkbook","الخلايا والصفوف والأعمدة","أنواع البيانات والتنسيق","إدخال البيانات بسرعة","المراجع النسبية والمطلقة","تطبيق جدول مبيعات"],
      ["Sort وFilter","تنسيق الجداول Tables","Find وReplace","Data Validation","التعامل مع التواريخ","تحدي تنظيف بيانات"],
      ["SUM وAVERAGE وCOUNT","IF وIFS","SUMIF وCOUNTIF","XLOOKUP وVLOOKUP","النصوص وTEXT functions","مراجعة الدوال"],
      ["التنسيق الشرطي","التعامل مع الأخطاء IFERROR","Named Ranges","المخططات الأساسية","اختيار الرسم المناسب","تقرير مبيعات أولي"],
      ["PivotTable من الصفر","تجميع البيانات داخل Pivot","Slicers وFilters","PivotChart","حساب مؤشرات KPI","Dashboard بسيط"],
      ["تنظيف البيانات","Text to Columns","Remove Duplicates","Power Query مقدمة","Merge وAppend","مشروع تجهيز Dataset"],
      ["Power Query transformations","استيراد ملفات متعددة","توحيد الأعمدة","تغيير أنواع البيانات","خطوات قابلة لإعادة الاستخدام","مشروع ETL صغير"],
      ["دوال متقدمة","Dynamic Arrays","INDEX وMATCH","دوال التاريخ المتقدمة","تحليل الحساسية","تحسين نموذج Excel"],
      ["تصميم Dashboard","KPIs للإدارة","تفاعل المستخدم","حماية ورقة وملف","تحسين الأداء","مشروع Dashboard"],
      ["مشروع Excel متكامل","تحليل بيانات حقيقية","بناء التقرير","مراجعة الدقة","توثيق المشروع","Portfolio Excel النهائي"]
    ]},
    "power-bi":{"title":"Power BI","levels":[
      ["ما هو Power BI","واجهة Power BI Desktop","استيراد أول Dataset","أنواع مصادر البيانات","Power Query overview","أول تقرير"],
      ["تنظيف البيانات","Data Types","Remove/Replace Values","Merge Queries","Append Queries","تطبيق ETL"],
      ["العلاقات بين الجداول","Star Schema","Fact وDimension","Cardinality","Filter Direction","بناء Model صحيح"],
      ["Visuals الأساسية","Cards وKPIs","Bar وLine Charts","Tables وMatrix","Slicers","تقرير تفاعلي"],
      ["DAX fundamentals","SUM وCOUNT","CALCULATE","FILTER","DIVIDE وIF","مراجعة DAX"],
      ["Time Intelligence","Date Table","YTD وMTD","Previous Period","Growth Rate","تحليل الاتجاهات"],
      ["Dashboard design","ألوان وتسلسل بصري","Tooltips","Drillthrough","Bookmarks","تجربة المستخدم"],
      ["Performance","تقليل حجم النموذج","فهم العلاقات","قياس أداء DAX","تنظيم Measures","تحسين تقرير"],
      ["Power BI Service","Publish","Workspaces","Sharing","Refresh","أساسيات الحوكمة"],
      ["مشروع BI متكامل","تصميم Dataset","Model + DAX","Dashboard","Insights","Portfolio Power BI"]
    ]},
    "systems-analysis":{"title":"تحليل وتصميم النظم","levels":[
      ["مفهوم النظام","دور محلل النظم","مشكلة العمل","أصحاب المصلحة","حدود النظام","دراسة حالة"],["جمع المتطلبات","المقابلات","الاستبيانات","الملاحظة","ورش العمل","توثيق المتطلبات"],["Functional Requirements","Non-functional Requirements","User Stories","Acceptance Criteria","الأولوية","مراجعة المتطلبات"],["Process Modeling","Flowchart","BPMN basics","As-Is","To-Be","تحليل فجوة"],["UML basics","Use Case","Activity Diagram","Sequence Diagram","Class Diagram","تطبيق UML"],["Data Modeling","ERD","Entities","Attributes","Relationships","تحويل ERD لجداول"],["System Design","Architecture","واجهة المستخدم","API concept","Security requirements","اختيار الحل"],["Testing","Test Case","Unit/System/UAT","Traceability","Bug report","خطة اختبار"],["Agile للمحلل","Backlog","Sprint","Refinement","Collaboration","مشروع Agile"],["مشروع تحليل كامل","Scope","Requirements","Models","Prototype","وثيقة SRS نهائية"]
    ]},
    "erp":{"title":"ERP","levels":[["مقدمة ERP","لماذا ERP","Modules","Master Data","Transactions","دراسة مؤسسة"],["Finance","Accounts","GL","AR وAP","Cost Centers","تدفق مالي"],["Sales","Customers","Quotations","Sales Orders","Invoices","Sales cycle"],["Procurement","Suppliers","Purchase Requisition","Purchase Order","Receiving","Procure-to-Pay"],["Inventory","Items","Warehouses","Stock Movements","Reorder Point","Inventory cycle"],["HR","Employees","Attendance","Payroll concept","Leave","HR workflow"],["Integration","Module integration","Data consistency","APIs","Interfaces","تدفق End-to-End"],["ERP implementation","Requirements","Configuration","Migration","Training","Go-live"],["Reporting","Operational reports","KPIs","Audit trail","Permissions","ERP analytics"],["مشروع ERP","اختيار مؤسسة","Process map","Module design","Implementation plan","عرض المشروع"]]},
    "python":{"title":"Python وتحليل البيانات","levels":[["Python basics","Variables","Data Types","Input/Output","Operators","تمرين أساسيات"],["Control Flow","if","for","while","Functions","تطبيق منطقي"],["Data Structures","Lists","Tuples","Dictionaries","Sets","تمرين بيانات"],["Files","CSV","JSON","Exceptions","Modules","مشروع ملف بيانات"],["NumPy","Arrays","Indexing","Vectorized operations","Statistics","تطبيق رقمي"],["Pandas","DataFrame","Filtering","GroupBy","Merge","تحليل Dataset"],["Cleaning","Missing values","Duplicates","Types","Outliers","تنظيف Dataset"],["Visualization","Matplotlib","Charts","Subplots concept","Annotations","تقرير بصري"],["Analytics","Descriptive statistics","Correlation","Segmentation","KPI","تحليل عملي"],["مشروع Python","اختيار Dataset","EDA","Cleaning","Visualization","Portfolio project"]]},
    "web":{"title":"تطوير الويب","levels":[["HTML basics","Document structure","Headings","Links","Images","Forms"],["CSS basics","Selectors","Box Model","Typography","Flexbox","Responsive design"],["JavaScript basics","Variables","Functions","Conditions","Arrays","DOM basics"],["DOM","Events","Forms validation","Dynamic UI","LocalStorage","Mini app"],["Modern JavaScript","Modules","Async concept","Fetch API","JSON","API project"],["Git وGitHub","Repository","Commits","Branches","Pull Requests","نشر مشروع"],["Backend concepts","HTTP","REST","Authentication concept","Database connection","API design"],["Security basics","Input validation","XSS concept","CORS","Secrets","Secure deployment"],["Performance وSEO","Semantic HTML","Metadata","Accessibility","Performance","SEO checklist"],["مشروع Web","تصميم الصفحة","Frontend","API integration","Testing","Portfolio deployment"]]},
    "cybersecurity":{"title":"الأمن السيبراني","levels":[["Security fundamentals","CIA Triad","Assets","Threats","Vulnerabilities","Risk"],["Networking basics","IP","DNS","HTTP/HTTPS","Ports","Firewalls"],["Identity","Authentication","Authorization","MFA","Passwords","Access control"],["Web security","OWASP concept","Input validation","Sessions","CSRF concept","Secure coding"],["Endpoint security","Updates","Antivirus concept","Hardening","Logs","Backup"],["Security monitoring","Events","Indicators","SIEM concept","Alert triage","Incident notes"],["Risk management","Risk assessment","Controls","Policies","Awareness","Risk register"],["Incident response","Preparation","Detection","Containment","Recovery","Lessons learned"],["Governance","Security policy","Compliance concept","Audit","Third-party risk","Business continuity"],["مشروع Security","Asset inventory","Risk register","Controls","Incident scenario","Security report"]]},
    "cloud":{"title":"الحوسبة السحابية","levels":[["Cloud fundamentals","Cloud definition","IaaS/PaaS/SaaS","Public/Private/Hybrid","Regions","Use cases"],["Compute","Virtual machines","Containers concept","Autoscaling","Load balancing","Compute design"],["Storage","Object storage","Block/File","Backup","Lifecycle","Storage choice"],["Networking","VPC concept","Subnets","Routing","Security groups","Cloud network"],["Databases","Managed DB","SQL/NoSQL","Availability","Backup","Database choice"],["IAM","Users/Roles","Least privilege","MFA","Policies","Access review"],["Monitoring","Metrics","Logs","Alerts","Health checks","Operations"],["Cost","Pricing models","Budgets","Tags","Rightsizing","Cost report"],["Architecture","Reliability","Scalability","Security","Disaster recovery","Architecture review"],["مشروع Cloud","Requirements","Architecture diagram","Services","Cost estimate","Deployment plan"]]},
    "project-management":{"title":"إدارة المشروعات","levels":[["مقدمة PM","Project vs Operations","Stakeholders","Objectives","Constraints","Case study"],["Scope","Charter","Requirements","Deliverables","WBS","Scope baseline"],["Schedule","Tasks","Dependencies","Milestones","Critical path concept","Schedule"],["Cost","Estimate","Budget","Contingency","Earned value concept","Cost report"],["Risk","Risk identification","Probability/Impact","Response","Risk register","Review"],["Quality","Quality planning","Acceptance","Testing","Checklists","Quality report"],["Agile","Manifesto","Scrum roles","Backlog","Sprint","Retrospective"],["Team","Roles","Communication","Conflict","Motivation","Team plan"],["Monitoring","KPIs","Status report","Change control","Issue log","Steering"],["مشروع PM","Charter","WBS","Schedule","Risk plan","Final presentation"]]},
    "career":{"title":"المسار الوظيفي","levels":[["اكتشاف المسار","MIS jobs","Business Analyst","Data Analyst","BI Analyst","اختيار المسار"],["أساسيات CV","Structure","Summary","Skills","Projects","ATS basics"],["LinkedIn","Profile","Headline","About","Projects","Networking"],["Portfolio","Project selection","README","Screenshots","Case study","عرض المهارة"],["Interview","Common questions","STAR","Technical discussion","Business questions","Mock interview"],["SQL career","SQL skills","Practice","Portfolio","Assessment","Job readiness"],["BI career","Excel","Power BI","DAX","Dashboard","Job readiness"],["Analyst career","Requirements","Analysis","Documentation","Stakeholders","Case study"],["Job search","Applications","Tracking","Networking","Freelance basics","Weekly plan"],["مشروع التخرج الوظيفي","CV final","Portfolio final","Interview simulation","Application strategy","90-day career plan"]]},
    "digital-transformation":{"title":"التحول الرقمي","levels":[["مفهوم التحول","Digital transformation","Digitization vs Digitalization","Drivers","Maturity","Case study"],["Strategy","Vision","Objectives","Business model","Roadmap","KPIs"],["Process transformation","Process mapping","Automation","Bottlenecks","Redesign","To-Be process"],["Data strategy","Data as asset","Governance","Quality","Analytics","Data roadmap"],["Customer experience","Customer journey","Channels","Personalization","Feedback","CX metrics"],["Automation","RPA concept","Workflow","APIs","AI concept","Automation case"],["Change management","People","Communication","Training","Resistance","Adoption plan"],["Technology architecture","Cloud","Integration","Security","Scalability","Architecture case"],["Measurement","ROI","KPIs","Benefits realization","Dashboard","Executive report"],["مشروع Transformation","Assessment","Target state","Initiatives","Roadmap","Executive presentation"]]}
  }
  $tracks$::jsonb;
  slug text;
  track jsonb;
  lv integer;
  ls integer;
  title text;
  total integer := 0;
begin
  for slug, track in select key, value from jsonb_each(tracks) loop
    for lv in 1..10 loop
      for ls in 1..6 loop
        title := track->'levels'->(lv-1)->>(ls-1);
        insert into public.lesson_content(course_slug, level_number, lesson_number, title, goal, concept, example, mistakes, challenge, published)
        values (
          slug, lv, ls, title,
          format('تعلّم %s ضمن المستوى %s من مسار %s، مع ربط المهارة بتطبيقات سوق العمل.', title, lv, track->>'title'),
          format('هذا الدرس يشرح %s بصورة عملية: افهم الفكرة، ثم طبّقها على مثال صغير، ثم راجع النتيجة قبل الانتقال للدرس التالي.', title),
          format('تطبيق عملي: أنشئ مثالًا صغيرًا مرتبطًا بـ %s، نفّذ الخطوات واحدة واحدة، وسجّل النتيجة في ملف ملاحظاتك أو Portfolio.', title),
          'تجنب حفظ الخطوات دون فهم الهدف. راجع المدخلات والنتائج، واختبر الحل قبل اعتماده، ووثّق أي افتراضات مهمة.',
          format('تحدي: نفّذ تطبيقًا مصغرًا لـ %s، ثم اكتب المشكلة والحل والنتيجة في Portfolio.', title),
          true
        )
        on conflict (course_slug, level_number, lesson_number) do update set
          title=excluded.title, goal=excluded.goal, concept=excluded.concept, example=excluded.example,
          mistakes=excluded.mistakes, challenge=excluded.challenge, published=true, updated_at=now();
        total := total + 1;
      end loop;
    end loop;
  end loop;
  return total;
end;
$$;

revoke all on function public.seed_mis_curriculum() from public, authenticated, anon;
grant execute on function public.seed_mis_curriculum() to postgres, service_role;

-- Execute from Supabase SQL Editor (which runs with owner/service privileges):
select public.seed_mis_curriculum();

-- Verify:
select count(*) as total_lessons,
       count(*) filter (where published=true) as published_lessons,
       count(distinct course_slug) as tracks
from public.lesson_content;
