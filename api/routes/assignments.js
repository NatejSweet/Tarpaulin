const { assignments } = require("../mongodb/initial_database");

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
    const createdAssignment = await Assignment.create(assignment);
    if (createdAssignment) {
      // Status code: 201
      res.status(201);
      res.send({ _id: createdAssignment._id });
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
  app.get("/assignments/:id", async (req, res) => {
    console.log("get assignment: ", req.params.id);
    if (!req.body || !req.user) {
      console.log("error: no body or user");
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }
    const user = await User.findOne({ _id: req.user });
    if (!user) {
      console.log("error: no user");
      // Status code: 500
      res.status(500);
      res.send();
      return;
    }
    const assignment = await Assignment.findOne({
      _id: req.params.id,
    });
    if (!assignment) {
      console.log("error: no assignment");
      // Status code: 404
      res.status(404);
      res.send();
      return;
    } else {
      console.log("assignment: ", assignment);
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
  app.patch("/assignments/:id", async (req, res) => {
    if (
      !req.body ||
      !req.body.courseId ||
      !req.body.title ||
      !req.body.points ||
      !req.body.due
    ) {
      console.log("error: missing fields");
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }
    const user = await User.findOne({ _id: req.user });
    if (!user) {
      // Status code: 500
      console.log("error: user not found");
      res.status(500);
      res.send();
      return;
    }
    const course = await Course.findOne({ _id: req.body.courseId });
    if (!course) {
      // Status code: 404
      console.log("error: course not found");
      res.status(404);
      res.send();
      return;
    }
    if (
      user.role !== "admin" &&
      (user.role !== "instructor" || course.instructorId !== user._id)
    ) {
      console.log("error: not authorized");
      // Status code: 403
      res.status(403);
      res.send();
      return;
    }
    const result = await Assignment.updateOne(
      { _id: req.params.id },
      {
        $set: {
          title: req.body.title,
          points: req.body.points,
          due: req.body.due,
        },
      }
    );
    console.log("modified count: ", result.modifiedCount);
    if (result.modifiedCount > 0) {
      // Status code: 200
      console.log("updated assignment: ", result);
      res.status(200);
      res.send(result);
      return;
    } else {
      // Status code: 500
      console.log("error: not updated");
      res.status(500);
      res.send();
      return;
    }
  });

  /**
 * Remove a specific Assignment from the database.
 * Completely removes the data for the specified Assignment, including all submissions.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course corresponding to the Assignment's `courseId` can delete an Assignment.

 */
  app.delete("/assignments/:id", async (req, res) => {
    console.log("delete assignment: ", req.params.id);
    const user = await User.findOne({ _id: req.user });
    if (!user) {
      // Status code: 500
      console.log("error: user not found");
      res.status(500);
      res.send();
      return;
    } else {
      console.log("user: ", user);
    }

    const assignment = await Assignment.findOne({ _id: req.params.id });

    const course = await Course.findOne({ _id: assignment.courseId });
    if (!course) {
      // Status code: 404
      console.log("error: course not found");
      res.status(404);
      res.send();
      return;
    }
    if (
      user.role != "admin" &&
      user.role != "instructor" &&
      course.instructorId != user._id
    ) {
      // Status code: 403
      console.log("error: not authorized, ", user.role != "admin");
      res.send();
      return;
    }
    
    const result = await Assignment.deleteOne({ _id: req.params.id });

    if (result.deletedCount > 0) {
      // Status code: 200
      console.log("deleted assignment: ", result);
      res.status(200);
      res.send();
      return;
    } else {
      // Status code: 500
      console.log("error: not deleted");
      res.status(500);
      res.send();
      return;
    }
  });

  /**
 * Fetch the list of all Submissions for an Assignment.
 * Returns the list of all Submissions for an Assignment.  This list should be paginated.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course corresponding to the Assignment's `courseId` can fetch the Submissions for an Assignment.

 */
  app.get("/assignments/:id/submissions", async (req, res) => {
    console.log("get submissions: ", req.params.id);
    try {
      const assignment = await Assignment.findOne({ _id: req.params.id });
      if (!assignment) {
        // Status code: 404
        console.log("error: assignment not found");
        res.status(404);
        res.send();
        return;
      }
      
      const user = await User.findOne({ _id: req.user });
      if (!user) {
        // Status code: 500
        console.log("error: user not found");
        res.status(500);
        res.send();
        return;
      }

      const course = await Course.findOne({ _id: assignment.courseId });
      if (!course) {
        // Status code: 404
        res.status(404);
        res.send();
        return;
      }
      if (
        user.role != "admin" &&
        user.role != "instructor" &&
        course.instructorId != user._id
      ) {
        // Status code: 403
        console.log("error: not authorized");
        res.status(403);
        res.send();
        return;
      }
      const submissions = await Submission.find({
        assignmentId: req.params.id,
      });
      if (submissions) {
        // Status code: 200
        console.log("submissions: ", submissions);
        res.status(200);
        res.send(submissions);
        return;
      } else {
        // Status code: 500
        console.log("error: no submissions");
        res.status(500);
        res.send();
        return;
      }
    } catch (error) {
      console.log("error: ", error);
      console.error(error);
      res.status(500).send();
    }
  });

  /**
 * Create a new Submission for an Assignment.
 * Create and store a new Assignment with specified data and adds it to the application's database.  Only an authenticated User with 'student' role who is enrolled in the Course corresponding to the Assignment's `courseId` can create a Submission.

 */
  app.post("/assignments/:id/submissions", async (req, res) => {
   
    const assignment = await Assignment.findOne({ _id: req.params.id });
    if (!assignment) {
      // Status code: 404
      res.status(404);
      res.send();
      return;
    }
    if (!req.body && !req.body.file) {
      console.log("error: missing fields");
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }
    const user = await User.findOne({ _id: req.user });
    if (!user) {
      console.log("error: user not found");
      // Status code: 500
      res.status(500);
      res.send();
      return;
    }
    const course = await Course.findOne({ _id: assignment.courseId });
    if (!course) {
      console.log("error: course not found");
      // Status code: 404
      res.status(404);
      res.send();
      return;
    }
    if ((user.role != "student" || !course.students.includes(user._id)) && user.role != "admin") {
      // Status code: 403
      console.log("error: not authorized");
      res.status(403);
      res.send();
      return;
    }
    const submission = {
      assignmentId: assignment._id,
      studentId: user._id,
      timestamp: new Date(),
      grade: null,
      file: req.body.file,
    };
    
    try {
      const sub = new Submission(submission);
      const newSubmission = await sub.save();
      console.log("new submission: ", newSubmission);
      res.status(201).send(newSubmission);
    } catch (err) {
      console.log("error: ", err);
      console.error(err);
      res.status(500).send();
    }
  });
};