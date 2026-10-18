-- =====================================================================
-- Вариант 6. Система учебного графика дисциплин факультета.
-- Модель Data Vault (хабы, линки, саттелиты). СУБД: PostgreSQL 17.
-- hk  — хэш-ключ (SHA-256 от бизнес-ключа, hex, 64 символа)
-- bk  — бизнес-ключ; load_dts — момент загрузки; record_source — источник
-- hashdiff — хэш атрибутов саттелита для обнаружения изменений
-- =====================================================================
DROP SCHEMA IF EXISTS dv CASCADE;
CREATE SCHEMA dv;
SET search_path = dv;

---------------------------------------------------------------- ХАБЫ
CREATE TABLE hub_faculty (
    faculty_hk    char(64)    PRIMARY KEY,
    faculty_bk    varchar(20) NOT NULL UNIQUE,
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL
);
CREATE TABLE hub_department (
    department_hk char(64)    PRIMARY KEY,
    department_bk varchar(100) NOT NULL UNIQUE,   -- код факультета + название кафедры
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL
);
CREATE TABLE hub_teacher (
    teacher_hk    char(64)    PRIMARY KEY,
    teacher_bk    varchar(30) NOT NULL UNIQUE,    -- табельный номер
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL
);
CREATE TABLE hub_group (
    group_hk      char(64)    PRIMARY KEY,
    group_bk      varchar(30) NOT NULL UNIQUE,
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL
);
CREATE TABLE hub_discipline (
    discipline_hk char(64)    PRIMARY KEY,
    discipline_bk varchar(30) NOT NULL UNIQUE,
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL
);
CREATE TABLE hub_semester (
    semester_hk   char(64)    PRIMARY KEY,
    semester_bk   varchar(20) NOT NULL UNIQUE,    -- 2026/2027-1
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL
);
CREATE TABLE hub_classroom (
    classroom_hk  char(64)    PRIMARY KEY,
    classroom_bk  varchar(30) NOT NULL UNIQUE,
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL
);

---------------------------------------------------------------- ЛИНКИ
CREATE TABLE link_department_faculty (
    link_hk       char(64)    PRIMARY KEY,
    department_hk char(64)    NOT NULL REFERENCES hub_department,
    faculty_hk    char(64)    NOT NULL REFERENCES hub_faculty,
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL,
    UNIQUE (department_hk, faculty_hk)
);
CREATE TABLE link_teacher_department (
    link_hk       char(64)    PRIMARY KEY,
    teacher_hk    char(64)    NOT NULL REFERENCES hub_teacher,
    department_hk char(64)    NOT NULL REFERENCES hub_department,
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL,
    UNIQUE (teacher_hk, department_hk)
);
CREATE TABLE link_group_faculty (
    link_hk       char(64)    PRIMARY KEY,
    group_hk      char(64)    NOT NULL REFERENCES hub_group,
    faculty_hk    char(64)    NOT NULL REFERENCES hub_faculty,
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL,
    UNIQUE (group_hk, faculty_hk)
);
-- Учебный план: группа + дисциплина + семестр
CREATE TABLE link_curriculum (
    link_hk       char(64)    PRIMARY KEY,
    group_hk      char(64)    NOT NULL REFERENCES hub_group,
    discipline_hk char(64)    NOT NULL REFERENCES hub_discipline,
    semester_hk   char(64)    NOT NULL REFERENCES hub_semester,
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL,
    UNIQUE (group_hk, discipline_hk, semester_hk)
);
-- Занятие: учебный план + преподаватель + аудитория
CREATE TABLE link_class_session (
    link_hk       char(64)    PRIMARY KEY,
    session_bk    varchar(50) NOT NULL UNIQUE,    -- бизнес-ключ занятия
    curriculum_hk char(64)    NOT NULL REFERENCES link_curriculum,
    teacher_hk    char(64)    NOT NULL REFERENCES hub_teacher,
    classroom_hk  char(64)    NOT NULL REFERENCES hub_classroom,
    load_dts      timestamp   NOT NULL DEFAULT now(),
    record_source varchar(50) NOT NULL
);

------------------------------------------------------------- САТТЕЛИТЫ
CREATE TABLE sat_faculty (
    faculty_hk    char(64) NOT NULL REFERENCES hub_faculty,
    load_dts      timestamp NOT NULL DEFAULT now(),
    hashdiff      char(64) NOT NULL,
    name          varchar(200),
    record_source varchar(50) NOT NULL,
    PRIMARY KEY (faculty_hk, load_dts)
);
CREATE TABLE sat_department (
    department_hk char(64) NOT NULL REFERENCES hub_department,
    load_dts      timestamp NOT NULL DEFAULT now(),
    hashdiff      char(64) NOT NULL,
    name          varchar(200),
    record_source varchar(50) NOT NULL,
    PRIMARY KEY (department_hk, load_dts)
);
CREATE TABLE sat_teacher (
    teacher_hk    char(64) NOT NULL REFERENCES hub_teacher,
    load_dts      timestamp NOT NULL DEFAULT now(),
    hashdiff      char(64) NOT NULL,
    full_name     varchar(200),
    position      varchar(100),
    record_source varchar(50) NOT NULL,
    PRIMARY KEY (teacher_hk, load_dts)
);
CREATE TABLE sat_group (
    group_hk       char(64) NOT NULL REFERENCES hub_group,
    load_dts       timestamp NOT NULL DEFAULT now(),
    hashdiff       char(64) NOT NULL,
    admission_year smallint,
    record_source  varchar(50) NOT NULL,
    PRIMARY KEY (group_hk, load_dts)
);
CREATE TABLE sat_discipline (
    discipline_hk char(64) NOT NULL REFERENCES hub_discipline,
    load_dts      timestamp NOT NULL DEFAULT now(),
    hashdiff      char(64) NOT NULL,
    name          varchar(200),
    record_source varchar(50) NOT NULL,
    PRIMARY KEY (discipline_hk, load_dts)
);
CREATE TABLE sat_semester (
    semester_hk   char(64) NOT NULL REFERENCES hub_semester,
    load_dts      timestamp NOT NULL DEFAULT now(),
    hashdiff      char(64) NOT NULL,
    starts_on     date,
    ends_on       date,
    record_source varchar(50) NOT NULL,
    PRIMARY KEY (semester_hk, load_dts)
);
CREATE TABLE sat_classroom (
    classroom_hk  char(64) NOT NULL REFERENCES hub_classroom,
    load_dts      timestamp NOT NULL DEFAULT now(),
    hashdiff      char(64) NOT NULL,
    capacity      smallint,
    record_source varchar(50) NOT NULL,
    PRIMARY KEY (classroom_hk, load_dts)
);
CREATE TABLE sat_curriculum (
    link_hk       char(64) NOT NULL REFERENCES link_curriculum,
    load_dts      timestamp NOT NULL DEFAULT now(),
    hashdiff      char(64) NOT NULL,
    lecture_hours smallint,
    lab_hours     smallint,
    assessment    varchar(30),
    record_source varchar(50) NOT NULL,
    PRIMARY KEY (link_hk, load_dts)
);
CREATE TABLE sat_class_session (
    link_hk       char(64) NOT NULL REFERENCES link_class_session,
    load_dts      timestamp NOT NULL DEFAULT now(),
    hashdiff      char(64) NOT NULL,
    lesson_type   varchar(30),
    weekday       smallint,
    start_time    time,
    end_time      time,
    week_parity   char(1),
    record_source varchar(50) NOT NULL,
    PRIMARY KEY (link_hk, load_dts)
);
