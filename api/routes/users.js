/* API endpoints related to application Users.
 */

module.exports = (app) => {
  const User = require("../mongodb/schemas").User;
  const Course = require("../mongodb/schemas").Course;
  const Assignment = require("../mongodb/schemas").Assignment;
  const Submission = require("../mongodb/schemas").Submission;

  /**
     * Create a new User.
     * Create and store a new application User with specified data and adds it to the application's database.  Only an authenticated User with 'admin' role can create users with the 'admin' or 'instructor' roles.

    */
  app.post("/users", async (req, res) => {
    function canCreateUser(creator, role) {
      if (role === "admin" || role === "instructor") {
        return creator === "admin";
      } else if (role === "student") {
        return creator === "admin" || creator === "instructor";
      } else {
        return false;
      }
    }

    if (!req.body || !req.body.role) {
      // Status code: 400
      res.status(400).send();
      return;
    }
    let user = await User.findOne({ _id: req.user._id });
    if (!user) {
      // Status code: 403
      res.status(403).send();
      return;
    }

    if (canCreateUser(user.role, req.body.role)) {
      // create user
      let newUser = new User(req.body);
      let error = newUser.validateSync();

      if (!error) {
        // create user
        await User.create(req.body);
        res.status(201).send();
        return;
      } else {
        // Status code: 400
        res.status(400).send();
        return;
      }
    } else {
      // Status code: 403
      res.status(403).send();
      return;
    }
  });

  /**
     * Log in a User.
     * Authenticate a specific User with their email address and password.

    */
  app.post("/users/login", async (req, res) => {
    const jwt = require("jsonwebtoken");
    const bcrypt = require("bcrypt");

    if (!req.body || !req.body.email || !req.body.password) {
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }

    const user = await User.findOne({ email: req.body.email });

    if (!user) {
      // Status code: 500
      res.status(500);
      res.send();
      return;
    } else if (!user.password) {
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }

    // Status code: 200
    if (await bcrypt.compare(req.body.password, user.password)) {
      const token = jwt.sign({ _id: user._id }, process.env.TOKEN_SECRET);

      res.status(200).send({ token: token });
    } else {
      // Status code: 400
      res.status(400);
      res.send();
    }
    return;
  });

  /**
     * Fetch data about a specific User.
     * Returns information about the specified User.  If the User has the 'instructor' role, the response should include a list of the IDs of the Courses the User teaches (i.e. Courses whose `instructorId` field matches the ID of this User).  If the User has the 'student' role, the response should include a list of the IDs of the Courses the User is enrolled in.  Only an authenticated User whose ID matches the ID of the requested User can fetch this information.

    */
  app.get("/users/:id", async (req, res) => {
    const u = await User.findOne({ _id: req.params.id });

    if (!u) {
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }

    if (u._id.toString() !== req.params.id) {
      // Status code: 403
      res.status(403);
      res.send();
      return;
    }

    // Status code: 200
    if (u.role === "instructor") {
      const courses = await Course.find({ instructorId: u._id });
      res.status(200);
      res.send(courses);
      return;
    } else if (u.role === "student") {
      // find all courses where this student is in the students list
      const courses = await Course.find({ students: u._id });
      res.status(200);
      res.send(courses);
      return;
    } else {
      // Status code: 404
      res.status(404).send();
    }
  });
};
