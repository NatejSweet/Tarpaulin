module.exports.users = [
  { // these need password hashing
    name: "Alice",
    email: "example@example.com",
    password: "hunter2",
    role: "admin",
    },
    {
        name: "Bob",
        email: "example2@example.com",
        password: "hunter2",
        role: "instructor",
    },
    {
        name: "Charlie",
        email: "example3@example.com",
        password: "hunter2",
        role: "student",
    }
];

module.exports.courses = [
  { // these need instructorId lookup
    subject: "CS",
    number: "101",
    title: "Intro to Computer Science",
    term: "Fall 2020",
    instructorId: 0,
  },
  {
    subject: "CS",
    number: "102",
    title: "Data Structures",
    term: "Fall 2020",
    instructorId: 0,
  },
  {
    subject: "CS",
    number: "201",
    title: "Algorithms",
    term: "Fall 2020",
    instructorId: 0,
  },
];

module.exports.assignments = [
  { // these need courseId lookup
    courseId: 0,
    title: "Homework 1",
    points: 10,
    due: new Date("2020-09-01T23:59:59"),
  },
  {
    courseId: 0,
    title: "Homework 2",
    points: 10,
    due: new Date("2020-09-08T23:59:59"),
  },
  {
    courseId: 0,
    title: "Midterm",
    points: 100,
    due: new Date("2020-09-15T23:59:59"),
  },
];

module.exports.submissions = [
  { // these need assignmentId and studentId lookup
    assignmentId: 0,
    studentId: 2,
    timestamp: new Date("2020-09-01T23:59:59"),
    grade: 10,
    file: "homework1.pdf",
  },
  {
    assignmentId: 1,
    studentId: 2,
    timestamp: new Date("2020-09-08T23:59:59"),
    grade: 10,
    file: "homework2.pdf",
  },
  {
    assignmentId: 2,
    studentId: 2,
    timestamp: new Date("2020-09-15T23:59:59"),
    grade: 90,
    file: "midterm.pdf",
  },
];