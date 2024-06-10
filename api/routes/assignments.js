/* API endpoints related to Assignments.
 */
module.exports = (app) => {
  const User = require("../mongodb/schemas").User;
  const Course = require("../mongodb/schemas").Course;
  const Assignment = require("../mongodb/schemas").Assignment;
  const Submission = require("../mongodb/schemas").Submission;
  const mongoose = require("mongoose");

  /**
 * Create a new Assignment.
 * Create and store a new Assignment with specified data and adds it to the application's database.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course corresponding to the Assignment's `courseId` can create an Assignment.

 */
  app.post("/assignments", async (req, res) => {
    console.log(req.body);
    if (
      !req.body ||
      !req.user ||
      !req.body.courseId ||
      !req.body.title ||
      !req.body.points ||
      !req.body.due
    ) {
      console.log("error");
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }
    const user = await User.findOne({ _id: req.user });
    if (!user) {
      // Status code: 500
      res.status(500);
      res.send();
      return;
    }
    const course = await Course.findOne({ _id: req.body.courseId });
    if (!course) {
      // Status code: 404
      res.status(404);
      res.send();
      return;
    }
    if (
      user.role !== "admin" &&
      (user.role !== "instructor" || course.instructorId !== user._id)
    ) {
      // Status code: 403
      res.status(403);
      res.send();
      return;
    }
    const assignment = new Assignment(req.body);
    const validationError = assignment.validateSync();

    if (validationError) {
      // Status code: 400
      console.log("error");
      res.status(400);
      res.send();
      return;
    }
    const createdAssignment = await assignment.save();
    if (createdAssignment) {
      // Status code: 201
      res.status(201);
      res.send(createdAssignment);
      return;
    } else {
      // Status code: 500
      res.status(500);
      res.send();
      return;
    }
  });

  /**
 * Fetch data about a specific Assignment.
 * Returns summary data about the Assignment, excluding the list of Submissions.

 */
  app.get("/assignments/{id}", (req, res) => {
    if (!req.body || !req.user || !req.body.assignment_id) {
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }
    const user = User.findOne({ _id: req.user });
    if (!user) {
      // Status code: 500
      res.status(500);
      res.send();
      return;
    }
    const assignment = Assignment.findOne({ _id: req.body.assignment_id });
    if (!assignment) {
      // Status code: 404
      res.status(404);
      res.send();
      return;
    } else {
      // Status code: 200
      res.status(200);
      res.send(assignment);
      return;
    }
  });

  /**
 * Update data for a specific Assignment.
 * Performs a partial update on the data for the Assignment.  Note that submissions cannot be modified via this endpoint.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course corresponding to the Assignment's `courseId` can update an Assignment.

 */
  app.patch("/assignments/{id}", (req, res) => {
    if (
      (!req.body || !req.body.email || !req.body.assignment_id,
      !req.body.assignment)
    ) {
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }
    const user = User.findOne({ _id: req.user });
    if (!user) {
      // Status code: 500
      res.status(500);
      res.send();
      return;
    }
    const course = Course.findOne({ _id: assignment.courseId });
    if (!course) {
      // Status code: 404
      res.status(404);
      res.send();
      return;
    }
    if (
      user.role != "admin" ||
      user.role != "instructor" ||
      course.instructorId != user._id
    ) {
      // Status code: 403
      res.status(403);
      res.send();
      return;
    }
    const result = Assignment.updateOne(
      { _id: req.body.assignment_id },
      {
        $set: {
          title: req.body.assignment.title,
          points: req.body.assignment.points,
          due: req.body.assignment.due,
        },
      }
    );
    if (result.nModified > 0) {
      // Status code: 200
      res.status(200);
      res.send();
      return;
    } else {
      // Status code: 500
      res.status(500);
      res.send();
      return;
    }
  });

  /**
 * Remove a specific Assignment from the database.
 * Completely removes the data for the specified Assignment, including all submissions.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course corresponding to the Assignment's `courseId` can delete an Assignment.

 */
  app.delete("/assignments/{id}", (req, res) => {
    if (!req.body || !req.body.email || !req.body.assignment_id) {
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }
    const user = User.findOne({ _id: req.user });
    if (!user) {
      // Status code: 500
      res.status(500);
      res.send();
      return;
    }
    const course = Course.findOne({ _id: assignment.courseId });
    if (!course) {
      // Status code: 404
      res.status(404);
      res.send();
      return;
    }
    if (
      user.role != "admin" ||
      user.role != "instructor" ||
      course.instructorId != user._id
    ) {
      // Status code: 403
      res.status(403);
      res.send();
      return;
    }
    const result = Assignment.delete({ _id: req.body.assignment_id });
    if (result.deletedCount > 0) {
      // Status code: 200
      res.status(200);
      res.send();
      return;
    } else {
      // Status code: 500
      res.status(500);
      res.send();
      return;
    }
  });

  /**
 * Fetch the list of all Submissions for an Assignment.
 * Returns the list of all Submissions for an Assignment.  This list should be paginated.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course corresponding to the Assignment's `courseId` can fetch the Submissions for an Assignment.

 */
  app.get("/assignments/{id}/submissions", (req, res) => {
    try {
      if (!req.body || !req.user || !req.body.assignment_id) {
        // Status code: 400
        res.status(400);
        res.send();
        return;
      }
      const user = User.findOne({ _id: req.user });
      if (!user) {
        // Status code: 500
        res.status(500);
        res.send();
        return;
      }
      const course = Course.findOne({ _id: assignment.courseId });
      if (!course) {
        // Status code: 404
        res.status(404);
        res.send();
        return;
      }
      if (
        user.role != "admin" ||
        user.role != "instructor" ||
        course.instructorId != user._id
      ) {
        // Status code: 403
        res.status(403);
        res.send();
        return;
      }
      const submissions = Submission.find({
        assignmentId: req.body.assignment_id,
      });
      if (submissions) {
        // Status code: 200
        res.status(200);
        res.send(submissions);
        return;
      } else {
        // Status code: 500
        res.status(500);
        res.send();
        return;
      }
    } catch (error) {
      console.error(error);
      res.status(500).send();
    }
  });

  /**
 * Create a new Submission for an Assignment.
 * Create and store a new Assignment with specified data and adds it to the application's database.  Only an authenticated User with 'student' role who is enrolled in the Course corresponding to the Assignment's `courseId` can create a Submission.

 */
  app.post("/assignments/{id}/submissions", (req, res) => {
    if (!req.body || !req.user || !req.body.assignment_id || !req.body.file) {
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }
    const user = User.findOne({ _id: req.user });
    if (!user) {
      // Status code: 500
      res.status(500);
      res.send();
      return;
    }
    const course = Course.findOne({ _id: assignment.courseId });
    if (!course) {
      // Status code: 404
      res.status(404);
      res.send();
      return;
    }
    if (user.role != "student" || !course.students.includes(user._id)) {
      // Status code: 403
      res.status(403);
      res.send();
      return;
    }
    const submission = {
      assignmentId: req.body.assignment_id,
      studentId: user._id,
      timestamp: new Date(),
      grade: null,
      file: req.body.file,
    };
    Submission.create(submission, (err, newSubmission) => {
      if (err) {
        // handle error
        console.error(err);
        res.status(500).send();
        return;
      } else {
        // Status code: 201
        res.status(201);
        res.send(newSubmission);
        return;
      }
    });
  });
};
