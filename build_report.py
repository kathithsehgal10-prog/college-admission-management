from pathlib import Path
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Preformatted, KeepTogether, Image
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.graphics.shapes import Drawing, Rect, String, Line
from xml.sax.saxutils import escape
r=Path(__file__).resolve().parents[1]
styles=getSampleStyleSheet()
styles.add(ParagraphStyle(name='BodyC',fontName='Helvetica',fontSize=10,leading=15,spaceAfter=8,textColor=colors.HexColor('#263449')))
styles.add(ParagraphStyle(name='CoverC',fontName='Helvetica-Bold',fontSize=28,leading=34,textColor=colors.HexColor('#173f63'),spaceAfter=18))
styles.add(ParagraphStyle(name='SmallC',fontName='Helvetica',fontSize=8,leading=11))
styles['Heading1'].textColor=colors.HexColor('#173f63');styles['Heading1'].fontSize=19;styles['Heading1'].spaceAfter=14
styles['Heading2'].textColor=colors.HexColor('#173f63');styles['Heading2'].fontSize=12
flow=[]
def p(s): flow.append(Paragraph(s,styles['BodyC']))
def h(s): flow.append(Paragraph(s,styles['Heading1']))
def table(rows,widths):
 t=Table([[Paragraph(escape(str(v)),styles['SmallC']) for v in row] for row in rows],colWidths=widths,repeatRows=1,hAlign='LEFT')
 t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#e5edf4')),('VALIGN',(0,0),(-1,-1),'TOP'),('GRID',(0,0),(-1,-1),.4,colors.HexColor('#cbd5e1')),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),6),('BOTTOMPADDING',(0,0),(-1,-1),6)]));flow.append(t)
flow.append(Spacer(1,60));flow.append(Paragraph('College Admission<br/>Management System',styles['CoverC']));p('Project report | Relational Database Management Systems')
p('<b>Assignment:</b> Case 1 - Project Report + Live Demo (5 + 15 marks)')
flow.append(Spacer(1,30))
for label in ['Student name','Roll number','Institution / department','Instructor','Submission date']:p(f'<b>{label}:</b> ___________________________________')
flow.append(Spacer(1,35));p('<b>Technology:</b> React UI + Express REST API + MySQL / InnoDB')
p('This report describes the design and implementation. Fill in the cover details and attach screenshots from the completed MySQL demonstration before submission.')
flow.append(PageBreak());h('1. Problem, objectives and architecture')
p('The College Admission Management System is an administrative website for student registration, course applications, admission review, hostel allocation and bus passes. Admission cycles, announcements, review history and a manual payment ledger extend the workflow.')
p('Independent spreadsheets and paper forms can duplicate records, hide seat availability and lose the history of decisions. A relational database centralizes records and enforces their relationships.')
flow.append(Paragraph('Assignment objectives',styles['Heading2']))
for s in ['Prepare a report covering the problem, design, implementation and verification.','Develop an interface connected to MySQL for persistent administrative operations.','Demonstrate UI changes in MySQL through SELECT queries, refresh and reporting.','Validate input, prevent duplicate active allocations and use atomic transactions.']:p('&#8226; '+s)
flow.append(Paragraph('Request and data flow',styles['Heading2']))
table([['Layer','Responsibility'],['React / Vite','Forms, tables, charts, routes and error messages'],['Express API','JWT authentication, request validation and business rules'],['mysql2 pool','Parameterized SQL and transaction connections'],['MySQL / InnoDB','Persistent tables, keys, constraints, views and routines']],[120,380])
flow.append(Spacer(1,12));p('Browser form -> REST request -> validation -> SQL transaction -> JSON response -> refreshed interface.')
p('<b>Environment:</b> Node.js 20.19+ or 22.12+, npm, MySQL 8.0.16+, modern browser. Local ports: UI 5173; API 5001; MySQL 3307. Credentials live in server/.env. A MySQL failure is displayed as disconnected; there is no SQLite substitution.')
flow.append(PageBreak());h('2. Relational schema and ER model')
rows=[['Relation','PK','Relationship / purpose']]
items=[('users','user_id','Optional applicant accounts'),('admins','admin_id','Administrator accounts'),('departments','department_id','Academic department catalog'),('courses','course_id','Department FK; program and capacity'),('tutors','tutor_id','Department FK; faculty records'),('students','student_id','User/department FKs; academic dossier'),('admission_cycles','cycle_id','Session dates and status'),('applications','application_id','Student, course, cycle FKs'),('application_status_history','history_id','Application FK; decision timeline'),('hostels','hostel_id','Facility and bed capacity'),('hostel_allocations','allocation_id','Student and hostel FKs'),('buses','bus_id','Routes and passenger capacity'),('bus_allocations','allocation_id','Student and bus FKs'),('announcements','announcement_id','Administrative notices'),('payments','payment_id','Application FK; manual fee ledger'),('audit_logs','log_id','Database state-change records')]
table(rows+items,[140,108,252]);flow.append(Spacer(1,10));p('A department has many courses, tutors and assigned students. Applications bridge students and courses, with an optional admission cycle. Each application has many history/payment rows. Allocation rows preserve student-facility assignment history.')
p('Each student may hold one approved admission, one active hostel bed and one active bus pass. Historical inactive allocations remain stored.')
flow.append(PageBreak());h('Entity-relationship diagram')
d=Drawing(500,450)
nodes={'departments':(190,395),'courses':(370,305),'tutors':(10,305),'students':(190,305),'applications':(370,215),'hostel_allocations':(10,215),'bus_allocations':(190,215),'hostels':(10,125),'buses':(190,125),'admission_cycles':(370,125),'history':(100,35),'payments':(250,35)}
edges=[('departments','courses'),('departments','tutors'),('departments','students'),('students','applications'),('courses','applications'),('students','hostel_allocations'),('students','bus_allocations'),('hostels','hostel_allocations'),('buses','bus_allocations'),('admission_cycles','applications'),('applications','history'),('applications','payments')]
for a,b in edges:
 x1,y1=nodes[a];x2,y2=nodes[b]
 if a=='applications' and b in ['history','payments']:
  points=[(x1+60,y1),(x1+60,190),(340,190),(340,90),(x2+60,90),(x2+60,y2+32)]
 else: points=[(x1+60,y1+15),(x2+60,y2+15)]
 for start,end in zip(points,points[1:]):d.add(Line(*start,*end,strokeColor=colors.HexColor('#94a3b8'),strokeWidth=1))
for name,(x,y) in nodes.items():
 d.add(Rect(x,y,120,32,fillColor=colors.HexColor('#e5edf4'),strokeColor=colors.HexColor('#173f63'),rx=4,ry=4));d.add(String(x+60,y+12,name,fontSize=8,textAnchor='middle',fillColor=colors.HexColor('#173f63')))
flow.append(d)
p('Each line represents a foreign-key relationship: one parent may have many child rows. Applications and allocation tables connect students to courses and facilities. The history box represents application_status_history.')
p('Users link optionally to students. Administrator credentials, announcements and audit logs support the portal independently of the main admission relationships.')
flow.append(PageBreak());h('3. Normalization and integrity')
for title,text in [('1NF','Scalar fields hold one value. Applications and allocations are individual rows rather than repeating lists.'),('2NF','Entity attributes depend on the entity key; dates and statuses of relationships belong to their bridge rows.'),('3NF','Course/department/facility details live in separate relations and are referenced through foreign keys. Counts and available seats are derived.')]:p(f'<b>{title}:</b> {text}')
table([['Mechanism','Rule'],['Primary / foreign keys','Identify records; enforce valid parent-child references'],['Unique constraints','Emails, application references and transaction references'],['Generated conditional keys','One approved admission / active allocation per student'],['Generated cycle key','Duplicate application protection even when cycle_id is NULL'],['CHECK + API validation','Mark/age/capacity boundaries, valid dates, positive payment amounts'],['Parameterized SQL','Form data is bound as values rather than SQL text']],[150,350])
flow.append(Spacer(1,12));flow.append(Paragraph('Transactions',styles['Heading2']))
p('Creation writes the application and initial history together. Review updates status, review fields, history and enrollment in one transaction. Approval checks course capacity and existing approved admissions. Revocation/deletion synchronizes the student department.')
p('Allocation creation and reactivation lock the student and resource, check duplicates and occupancy, and then insert/update. Capacity edits use the same resource locks. READ COMMITTED makes occupancy reads observe commits after lock waits. Errors roll back; connections are released.')
p('<b>Authentication:</b> bcrypt hashes passwords and JWT tokens authenticate API requests. Only the admins table permits entry to the administrator portal.')
flow.append(PageBreak());h('4. SQL and implementation')
p('<b>Views:</b> view_department_stats, view_hostel_occupancy, view_bus_occupancy calculate department totals and available facilities.')
p('<b>Routines:</b> merit and availability functions; approval, hostel allocation and department report procedures. The routines/triggers file is imported separately. The API viva page reads information_schema so it lists installed objects accurately.')
code="""SELECT s.name, c.course_name, d.department_name, a.status
FROM applications a
JOIN students s ON s.student_id = a.student_id
JOIN courses c ON c.course_id = a.course_id
JOIN departments d ON d.department_id = c.department_id
WHERE a.status = 'APPROVED';

SELECT * FROM view_hostel_occupancy;

SELECT department_id, COUNT(*) AS student_count
FROM students
GROUP BY department_id;"""
flow.append(Preformatted(code,ParagraphStyle(name='CodeC',fontName='Courier',fontSize=8,leading=12,backColor=colors.HexColor('#f1f5f9'),borderPadding=10)));flow.append(Spacer(1,15))
p('The SQL demonstration runner uses read-only transactions, rejects modification/file export statements and refuses multiple statements. CSV reports escape text that could otherwise become a spreadsheet formula.')
p('Payments are administrative ledger records. The project does not perform real payments or integrate a payment gateway. Applicant self-service is future work.')
flow.append(PageBreak());h('5. Verification and live demonstration')
p('Automated controller/validation checks passed: 48 tests, 0 failures. The frontend production build passed with a non-fatal large-bundle warning. Some tests use controlled database mocks; they do not establish live MySQL connectivity.')
p('The db:check command verifies real MySQL, all 16 tables and curated SQL demonstrations. On success it saves docs/MYSQL_VERIFICATION.json with version, installed objects and query results. Live verification passed against MySQL 26.7.0 on 127.0.0.1:3307, database college_submission: all 16 tables, 12 SQL demonstrations and 16 workflow checks. Chrome login and the connection diagnostics were also verified.')
flow.append(Paragraph('Live demonstration sequence',styles['Heading2']))
for i,s in enumerate(['Sign in; show Settings and the MySQL connection status.','Register a fictional student; show the row in Workbench with SELECT.','Create and approve an application; show its history and enrollment.','Allocate a hostel bed/bus pass; demonstrate duplicate/full rejection.','Export a CSV and execute JOIN, aggregate, subquery and view examples.','Refresh the UI to show persistence. Explain keys, normalization and transactions.'],1):p(f'<b>{i}.</b> {s}')
flow.append(Paragraph('Conclusion and next steps',styles['Heading2']))
p('The project combines a functional administrative interface with a relational schema, integrity constraints, transactions, joins and views. Completion of the live MySQL checklist demonstrates the assignment requirements. Fill in the report cover and append demonstration screenshots.')
flow.append(Paragraph('References',styles['Heading2']))
for link in ['https://dev.mysql.com/doc/refman/8.4/en/','https://dev.mysql.com/doc/refman/8.4/en/innodb-locking-reads.html','https://expressjs.com/','https://react.dev/']:flow.append(Paragraph(link,styles['SmallC']))
flow.append(PageBreak());h('6. Live UI and MySQL evidence')
p('The connection diagnostic shows the actual database, host, port and MySQL version. The student registration screenshot shows a browser-submitted fictional test record; its persistence was confirmed by a direct SELECT query and the fixture was then removed.')
for filename,caption in [('mysql-connected.jpg','Verified connection to college_submission on MySQL 26.7.0, port 3307.'),('student-registration.jpg','Student creation through the React UI, confirmed in MySQL.')]:
 from PIL import Image as PILImage
 if filename=='student-registration.jpg':
  flow.append(PageBreak());h('7. Student registration evidence')
  p('A fictional student was submitted through the UI and appeared in the list with its MySQL-assigned ID. The saved UI_VERIFICATION.json records the direct database check. The test row was removed afterwards.')
 file=r/'docs/screenshots'/filename
 w,hgt=PILImage.open(file).size
 flow.append(Image(str(file),width=500,height=500*hgt/w));flow.append(Spacer(1,6));flow.append(Paragraph(caption,styles['SmallC']));flow.append(Spacer(1,12))
def footer(canvas,doc):
 canvas.setStrokeColor(colors.HexColor('#cbd5e1'));canvas.line(47,44,548,44);canvas.setFont('Helvetica',8);canvas.setFillColor(colors.HexColor('#526174'));canvas.drawString(47,30,'College Admission Management System | RDBMS');canvas.drawRightString(548,30,str(doc.page))
out=r/'output/pdf/Project_Report.pdf'
SimpleDocTemplate(str(out),pagesize=A4,rightMargin=47,leftMargin=47,topMargin=46,bottomMargin=57,title='College Admission Management System - RDBMS Project Report',author='').build(flow,onFirstPage=footer,onLaterPages=footer)
print(out)
