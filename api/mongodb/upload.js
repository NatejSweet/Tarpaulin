function upload() {
    const bcrypt = require('bcrypt');

    const User = require('./schemas').User;
    const Course = require('./schemas').Course;
    const Assignment = require('./schemas').Assignment;
    const Submission = require('./schemas').Submission;

    const users = require('./initial_database').users;
    const courses = require('./initial_database').courses;  
    const assignments = require('./initial_database').assignments;
    const submissions = require('./initial_database').submissions;

    for (let i = 0; i < users.length; i++) {
        users[i].password = bcrypt.hashSync(users[i].password, bcrypt.genSaltSync(10));
    }

    User.insertMany(users);

    const instructor = User.findOne({role: 'instructor'});

    for (let i = 0; i < courses.length; i++) {
        courses[i].instructorId = instructor._id;
    }

    Course.insertMany(courses);

    for (let i = 0; i < assignments.length; i++) {
        assignments[i].courseId = Course.findOne({subject: 'CS', number: '101'})._id;
    }

    Assignment.insertMany(assignments);

    for (let i = 0; i < submissions.length; i++) {
        submissions[i].assignmentId = Assignment.findOne({title: 'Homework 1'})._id;
        submissions[i].studentId = User.findOne({role: 'student'})._id;
    }

    Submission.insertMany(submissions);

    console.log('Database uploaded successfully');

}

module.exports = upload;