// MongoDB, лабораторная работа №1 (основы). Вариант 6 — учебный график факультета.
// Запуск: mongosh --file mongo/faculty_schedule.js
use('faculty_schedule');
db.dropDatabase();

// 1. Создание коллекций
db.createCollection('disciplines');
db.createCollection('schedule');

// 2. Добавление документов (вложенные документы hours, time и массивы teachers, weeks)
db.disciplines.insertMany([
  { _id: "DB101", name: "Хранилища данных", semester: 5, hours: { lectures: 32, labs: 48 }, teachers: ["Иванов", "Петрова"] },
  { _id: "OS102", name: "Операционные системы", semester: 5, hours: { lectures: 32, labs: 32 }, teachers: ["Сидоров"] },
  { _id: "AI201", name: "Искусственный интеллект", semester: 6, hours: { lectures: 24, labs: 40 }, teachers: ["Петрова", "Смирнов"] },
  { _id: "NET203", name: "Компьютерные сети", semester: 6, hours: { lectures: 16, labs: 32 }, teachers: ["Козлов"] }
]);
db.schedule.insertMany([
  { _id: 1, group: "223-322", disciplineId: "DB101", day: "Понедельник", time: { start: "09:00", end: "10:30" }, weeks: [1, 2, 3, 4], room: "А-101" },
  { _id: 2, group: "223-322", disciplineId: "OS102", day: "Среда", time: { start: "10:40", end: "12:10" }, weeks: [1, 2, 3, 4], room: "Б-204" },
  { _id: 3, group: "223-321", disciplineId: "AI201", day: "Пятница", time: { start: "12:20", end: "13:50" }, weeks: [3, 4, 5, 6], room: "В-305" },
  { _id: 4, group: "223-321", disciplineId: "NET203", day: "Вторник", time: { start: "09:00", end: "10:30" }, weeks: [1, 3, 5], room: "А-101" }
]);

// 3. Выборки
printjson(db.disciplines.find().toArray());
printjson(db.disciplines.find({ semester: 5 }).toArray());
printjson(db.disciplines.find({ semester: { $gt: 5 } }, { name: 1, semester: 1 }).toArray());
printjson(db.schedule.find({ group: '223-322', day: { $in: ['Понедельник', 'Среда'] } }, { day: 1, room: 1 }).toArray());
printjson(db.disciplines.find().sort({ name: 1 }).limit(2).toArray());

// 4. Вложенные документы и массивы
printjson(db.disciplines.find({ 'hours.lectures': { $gte: 32 } }, { name: 1, hours: 1 }).toArray());
printjson(db.schedule.find({ 'time.start': '09:00' }, { group: 1, room: 1, time: 1 }).toArray());
printjson(db.disciplines.find({ teachers: 'Петрова' }, { name: 1, teachers: 1 }).toArray());
printjson(db.schedule.find({ weeks: { $all: [1, 3] } }, { group: 1, weeks: 1 }).toArray());
printjson(db.disciplines.find({ teachers: { $size: 2 } }, { name: 1 }).toArray());

// 5. Изменение документов
db.disciplines.updateOne({ _id: 'NET203' }, { $set: { semester: 7 }, $push: { teachers: 'Орлова' } });
db.disciplines.updateMany({ semester: 5 }, { $inc: { 'hours.labs': 8 } });

// 6. Удаление документа, коллекции и базы данных
db.schedule.deleteOne({ _id: 4 });
print(db.schedule.countDocuments());
db.schedule.drop();
print(db.getCollectionNames());
db.dropDatabase();
