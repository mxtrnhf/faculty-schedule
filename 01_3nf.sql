-- =====================================================================
-- Вариант 6. Система учебного графика дисциплин факультета.
-- Модель в третьей нормальной форме (3НФ). СУБД: PostgreSQL 17.
-- Каждый неключевой атрибут зависит только от первичного ключа своей
-- таблицы; справочные данные вынесены в отдельные таблицы.
-- =====================================================================
DROP SCHEMA IF EXISTS nf3 CASCADE;
CREATE SCHEMA nf3;
SET search_path = nf3;

-- Факультет
CREATE TABLE faculty (
    faculty_id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code         varchar(20)  NOT NULL UNIQUE,   -- краткий код факультета
    name         varchar(200) NOT NULL
);

-- Кафедра принадлежит факультету
CREATE TABLE department (
    department_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    faculty_id    integer      NOT NULL REFERENCES faculty(faculty_id),
    name          varchar(200) NOT NULL,
    UNIQUE (faculty_id, name)
);

-- Преподаватель работает на кафедре
CREATE TABLE teacher (
    teacher_id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_id integer      NOT NULL REFERENCES department(department_id),
    full_name     varchar(200) NOT NULL,
    position      varchar(100) NOT NULL          -- должность
);

-- Учебная группа
CREATE TABLE study_group (
    group_id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    faculty_id     integer     NOT NULL REFERENCES faculty(faculty_id),
    code           varchar(30) NOT NULL UNIQUE,  -- например 223-322
    admission_year smallint    NOT NULL CHECK (admission_year BETWEEN 2000 AND 2100)
);

-- Дисциплина
CREATE TABLE discipline (
    discipline_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code          varchar(30)  NOT NULL UNIQUE,
    name          varchar(200) NOT NULL
);

-- Учебный семестр
CREATE TABLE semester (
    semester_id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    academic_year varchar(9) NOT NULL,           -- 2026/2027
    term_no       smallint   NOT NULL CHECK (term_no IN (1, 2)),
    starts_on     date       NOT NULL,
    ends_on       date       NOT NULL,
    UNIQUE (academic_year, term_no),
    CHECK (ends_on > starts_on)
);

-- Аудитория
CREATE TABLE classroom (
    classroom_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_code    varchar(30) NOT NULL UNIQUE,
    capacity     smallint    NOT NULL CHECK (capacity > 0)
);

-- Справочник видов занятий (лекция, практика, лабораторная)
CREATE TABLE lesson_type (
    lesson_type_id smallint PRIMARY KEY,
    name           varchar(30) NOT NULL UNIQUE
);

-- Учебный план: сколько часов и какого вида отведено дисциплине для группы в семестре
CREATE TABLE curriculum (
    curriculum_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id      integer NOT NULL REFERENCES study_group(group_id),
    discipline_id integer NOT NULL REFERENCES discipline(discipline_id),
    semester_id   integer NOT NULL REFERENCES semester(semester_id),
    lecture_hours smallint NOT NULL DEFAULT 0 CHECK (lecture_hours >= 0),
    lab_hours     smallint NOT NULL DEFAULT 0 CHECK (lab_hours >= 0),
    assessment    varchar(30) NOT NULL,          -- экзамен / зачёт
    UNIQUE (group_id, discipline_id, semester_id)
);

-- Занятие в расписании (учебный график)
CREATE TABLE class_session (
    session_id     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    curriculum_id  integer  NOT NULL REFERENCES curriculum(curriculum_id),
    teacher_id     integer  NOT NULL REFERENCES teacher(teacher_id),
    classroom_id   integer  NOT NULL REFERENCES classroom(classroom_id),
    lesson_type_id smallint NOT NULL REFERENCES lesson_type(lesson_type_id),
    weekday        smallint NOT NULL CHECK (weekday BETWEEN 1 AND 7),
    start_time     time     NOT NULL,
    end_time       time     NOT NULL,
    week_parity    char(1)  NOT NULL DEFAULT 'A' CHECK (week_parity IN ('A', 'O', 'E')), -- каждая / нечётная / чётная
    CHECK (end_time > start_time)
);
CREATE INDEX ix_session_teacher   ON class_session(teacher_id, weekday, start_time);
CREATE INDEX ix_session_classroom ON class_session(classroom_id, weekday, start_time);
