-- Тестовые данные для 3НФ (проверка схемы)
SET search_path = nf3;
INSERT INTO faculty(code,name) VALUES ('IT','Информационные технологии');
INSERT INTO department(faculty_id,name) VALUES (1,'Прикладная информатика'),(1,'Информационная безопасность');
INSERT INTO teacher(department_id,full_name,position) VALUES (1,'Ноздрин В.С.','доцент'),(1,'Петрова О.И.','профессор'),(2,'Иванов С.А.','доцент');
INSERT INTO study_group(faculty_id,code,admission_year) VALUES (1,'223-322',2022),(1,'223-321',2022);
INSERT INTO discipline(code,name) VALUES ('DB101','Хранилища данных'),('OS102','Операционные системы');
INSERT INTO semester(academic_year,term_no,starts_on,ends_on) VALUES ('2026/2027',1,'2026-09-01','2027-01-31');
INSERT INTO classroom(room_code,capacity) VALUES ('А-101',60),('Б-204',30);
INSERT INTO lesson_type VALUES (1,'лекция'),(2,'практика'),(3,'лабораторная');
INSERT INTO curriculum(group_id,discipline_id,semester_id,lecture_hours,lab_hours,assessment) VALUES (1,1,1,32,48,'экзамен'),(1,2,1,32,32,'зачёт'),(2,1,1,32,48,'экзамен');
INSERT INTO class_session(curriculum_id,teacher_id,classroom_id,lesson_type_id,weekday,start_time,end_time,week_parity) VALUES
 (1,1,1,1,1,'09:00','10:30','A'),(1,2,2,3,3,'10:40','12:10','O'),(2,3,2,1,5,'12:20','13:50','A');
