/* API endpoints related to Courses.
 */

const { Assignment } = require("../mongodb/schemas");

/**
 * Fetch the list of all Courses.
 * Returns the list of all Courses.  This list should be paginated.  The Courses returned should not contain the list of students in the Course or the list of Assignments for the Course.

 */

module.exports = (app) => {
  const User = require("../mongodb/schemas").User;
  const Course = require("../mongodb/schemas").Course;
  const Assignment = require("../mongodb/schemas").Assignment;
  const Submission = require("../mongodb/schemas").Submission;
  const mongoose = require("mongoose");
  const { ObjectId } = require("mongodb");

  app.get("/courses", async (req, res) => {
    try {
      if (!req.body | !req.user) {
        // Status code: 500
        res.status(500).send();
        return;
      }
      const courses = await Course.find().select(
        "subject number title term _id"
      );
      if (!courses) {
        // Status code: 500
        res.status(500).send();
        return;
      } else {
        // Status code: 200
        res.status(200).send({ courses: courses });
        return;
      }
    } catch (err) {
      res.status(500).send();
      return;
    }
  });

  /**
 * Create a new course.
 * Creates a new Course with specified data and adds it to the application's database.  Only an authenticated User with 'admin' role can create a new Course.

 */
  app.post("/courses", async (req, res) => {
    function validateCourse() {
      if (
        !req.body ||
        !req.body.subject ||
        !req.body.number ||
        !req.body.title ||
        !req.body.term ||
        !req.body.instructorId ||
        !mongoose.Types.ObjectId.isValid(req.body.instructorId)
      ) {
        return false;
      }
      return true;
    }
    try {
      if (!req.body || !req.user || !validateCourse(req.body)) {
        // Status code: 400
        res.status(400).send();
        return;
      }
      const user = await User.findOne({ _id: req.user });
      if (user.role != "admin") {
        // Status code: 403
        res.status(403).send();
        return;
      }
      let newCourse = new Course(req.body);
      let error = newCourse.validateSync();
      if (error) {
        // Status code: 400
        res.status(400).send();
        return;
      }
      const result = await Course.create(req.body);
      if (!result) {
        // Status code: 500
        res.status(500).send();
        return;
      } else {
        // Status code: 201
        res.status(201).send({ _id: result._id });
        return;
      }
    } catch (err) {
      // Status code: 500
      res.status(500).send();
      return;
    }
  });

  /**
 * Fetch data about a specific Course.
 * Returns summary data about the Course, excluding the list of students enrolled in the course and the list of Assignments for the course.

 */
  app.get("/courses/:id", async (req, res) => {
    try {
      if (!req.body) {
        // Status code: 500
        res.status(500).send();
        return;
      }
      const course = await Course.findOne({ _id: req.params.id }).select(
        "subject number title term instructorId"
      );
      if (!course) {
        // Status code: 404
        res.status(404).send();
        return;
      } else {
        // Status code: 200
        res.status(200).send({ course: course });
        return;
      }
    } catch (err) {
      res.status(500).send();
      return;
    }
  });

  /**
 * Update data for a specific Course.
 * Performs a partial update on the data for the Course.  Note that enrolled students and assignments cannot be modified via this endpoint.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can update Course information.

 */
  app.patch("/courses/:id", async (req, res) => {
    function validateCourse() {
      if (
        !req.body ||
        !req.body.subject ||
        !req.body.number ||
        !req.body.title ||
        !req.body.term ||
        !req.body.instructorId ||
        !mongoose.Types.ObjectId.isValid(req.body.instructorId)
      ) {
        return false;
      }
      return true;
    }
    try {
      if (!req.body || !req.user || !validateCourse(req.body)) {
        // Status code: 400
        res.status(400).send();
        return;
      }
      const user = await User.findOne({ _id: req.user });
      if (!user) {
        // Status code: 500
        res.status(500).send();
        return;
      }
      const course = await Course.findOne({ _id: req.params.id });
      if (!course) {
        // Status code: 404
        res.status(404).send();
        return;
      }
      if (
        user.role !== "admin" &&
        course.instructorId.toString() !== user._id.toString()
      ) {
        // Status code: 403

        res.status(403).send();
        return;
      }
      try {
        let newCourse = new Course(req.body);
        let error = newCourse.validateSync();
        if (error) {
          // Status code: 400
          res.status(400).send();
          return;
        }
        const updateData = { ...req.body };
        delete updateData._id;
        const result = await Course.updateOne(
          { _id: req.params.id },
          updateData
        );
        if (result.modifiedCount < 1) {
          // Status code: 500
          res.status(500).send();
        } else {
          // Status code: 200
          res.status(200).send();
        }
      } catch (err) {
        console.log(err);
        res.status(500).send();
        return;
      }
    } catch (err) {
      console.log(err);
      res.status(500).send();
      return;
    }
  });

  /**
 * Remove a specific Course from the database.
 * Completely removes the data for the specified Course, including all enrolled students, all Assignments, etc.  Only an authenticated User with 'admin' role can remove a Course.

 */
  app.delete("/courses/:id", async (req, res) => {
    try {
      if (!req.body || !req.user) {
        // Status code: 400
        res.status(400).send();
        return;
      }
      const user = await User.findOne({ _id: req.user });
      if (user.role != "admin") {
        // Status code: 403
        res.status(403).send();
        return;
      }
      const course = await Course.findOne({ _id: req.params.id });
      if (!course) {
        // Status code: 404
        res.status(404).send();
        return;
      }
      const result = await Course.deleteOne({ _id: req.params.id });
      const students = await User.find({ courses: req.params.id });
      for (let student of students) {
        student.courses = student.courses.filter(
          (course) => course != req.params.id
        );
        await student.save();
      }
      const assignments = await Assignment.deleteMany({
        courseId: req.params.id,
      });
      if (!assignments.acknowledged || result.deletedCount < 1) {
        // Status code: 500
        res.status(500).send();
        return;
      } else {
        // Status code: 200
        res.status(200).send();
        return;
      }
    } catch (err) {
      res.status(500).send();
      return;
    }
  });

  /**
 * Fetch a list of the students enrolled in the Course.
 * Returns a list containing the User IDs of all students currently enrolled in the Course.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can fetch the list of enrolled students.

 */
  app.get("/courses/:id/students", async (req, res) => {
    try {
      if (!req.body || !req.user) {
        // Status code: 400
        res.status(400).send();
        return;
      }
      const user = await User.findOne({ _id: req.user });
      const course = await Course.findOne({ _id: req.params.id });
      if (
        user.role !== "admin" &&
        course.instructorId.toString() !== user._id.toString()
      ) {
        // Status code: 403
        res.status(403).send();
        return;
      }
      // Status code: 200
      res.status(200).send({ students: course.students });
      return;
    } catch (err) {
      // Status code: 500
      res.status(500).send();
      return;
    }
  });

  /**
 * Update enrollment for a Course.
 * Enrolls and/or unenrolls students from a Course.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can update the students enrolled in the Course.

 */
  app.post("/courses/:id/students", async (req, res) => {
    try {
      if (!req.body || !req.user || !(req.body.adds || req.body.removes)) {
        res.status(400).send();
        return;
      }
      const user = await User.findOne({ _id: req.user });
      const course = await Course.findOne({ _id: req.params.id });
      if (!user || !course) {
        res.status(404).send();
        return;
      }
      if (
        user.role !== "admin" &&
        course.instructorId.toString() !== user._id.toString()
      ) {
        res.status(403).send();
        return;
      }
      if (req.body.adds) {
        course.students.push(...req.body.adds);
        await course.save();
      }
      if (req.body.removes) {
        console.log("Before removal: ", course.students); // Print the students array before removal

        course.students = course.students.filter(
          (student) => !req.body.removes.includes(student.toString())
        );

        console.log("After removal: ", course.students); // Print the students array after removal

        await course.save();
      }
      res.status(200).send({ students: course.students });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).send();
      return;
    }
  });

  /**
 * Fetch a CSV file containing list of the students enrolled in the Course.
 * Returns a CSV file containing information about all of the students currently enrolled in the Course, including names, IDs, and email addresses.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can fetch the course roster.

 */
  app.get("/courses/:id/roster", async (req, res) => {
    if (!req.body || !req.user) {
      // Status code: 400
      res.status(400).send();
      return;
    }
    const user = await User.findOne({ _id: req.user });
    if (!user) {
      // Status code: 403
      res.status(403).send();
      return;
    }
    const course = await Course.findOne({ _id: req.params.id });
    if (!course) {
      // Status code: 404
      res.status(404).send();
      return;
    }
    if (
      user.role !== "admin" &&
      course.instructorId.toString() !== user._id.toString()
    ) {
      // Status code: 403
      res.status(403).send();
      return;
    }
    const students = await User.find({ _id: { $in: course.students } });
    if (!students) {
      // Status code: 500
      res.status(500).send();
      return;
    }
    let csv = "Name,ID,Email\n";
    for (let student of students) {
      csv += `${student.name},${student._id},${student.email}\n`;
    }
    res.setHeader("Content-Type", "text/csv");
    res.setHeader(
      "Content-Disposition",
      'attachment; filename="' + "download-" + Date.now() + '.csv"'
    );
    res.status(200).send(csv);
  });

  /**
 * Fetch a list of the Assignments for the Course.
 * Returns a list containing the Assignment IDs of all Assignments for the Course.

 */
  app.get("/courses/:id/assignments", async (req, res) => {
    console.log("GET /courses/:id/assignments");
    try {
      if (!req.body || !req.user) {
        console.log("No body or user");
        // Status code: 400
        res.status(400).send();
        return;
      }
      const user = await User.findOne({ _id: req.user });
      if (!user) {
        // Status code: 403
        res.status(403).send();
        return;
      }
      const course = await Course.findOne({ _id: req.params.id });
      if (!course) {
        console.log("Course not found");
        // Status code: 404
        res.status(404).send();
        return;
      }
      const assignments = await Assignment.find({
        courseId: req.params.id,
      }).select("_id");
      if (!assignments) {
        // Status code: 500
        console.log("Assignments not found");
        res.status(500).send();
        return;
      }
      // Status code: 200
      res.status(200).send({ assignments: assignments });
      return;
    } catch (err) {
      // Status code: 500
      res.status(500).send();
      return;
    }
  });

  app.post("/courses/:id/assignments", async (req, res) => {
    try {
      if (!req.body || !req.user) {
        // Status code: 400
        console.log("course assign post : no body or user");
        res.status(400).send();
        return;
      }
      const user = await User.findOne({ _id: req.user });

      if (!user) {
        // Status code: 403
        console.log("course assign post : user not found");
        res.status(403).send();
        return;
      }

      const course = await Course.findOne({ _id: req.params.id });

      if (!course) {
        // Status code: 404
        console.log("course assign post : course not found");
        res.status(404).send();
        return;
      }

      if (user.role !== "admin" && course.instructorId !== user._id) {
        // Status code: 403
        console.log("course assign post : not admin or instructor");
        res.status(403).send();
        return;
      }

      if (req.body) {
        const assignment = new Assignment(req.body);
        if (assignment.validateSync() !== undefined) {
          // Status code: 400
          console.log("course assign post : invalid assignment");
          res.status(400).send();
          return;
        }
        assignment.courseId = course._id;
        await assignment.save();
        res.status(201).send({ _id: assignment._id });
        return;
      } else {
        // Status code: 400
        console.log("course assign post : invalid assignment");
        res.status(400).send();
        return;
      }
    } catch (err) {
      // Status code: 500
      console.log("course assign post :", err);
      res.status(500).send();
      return;
    }
  });
};
