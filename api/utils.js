const User = require('../mongodb/schemas').User
const Course = require('../mongodb/schemas').Course
const Assignment = require('../mongodb/schemas').Assignment
const Submission = require('../mongodb/schemas').Submission

module.exports.getUser = function (user) {
    return User.findOne({ password: user }); // password is the hashed password and user is the jwt verified token
}
