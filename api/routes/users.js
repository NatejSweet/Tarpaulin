/* API endpoints related to application Users.
 */
const bcrypt = require("bcrypt");

module.exports = (app) => {
  const User = require("../mongodb/schemas").User;
  const Course = require("../mongodb/schemas").Course;
  const Assignment = require("../mongodb/schemas").Assignment;
  const Submission = require("../mongodb/schemas").Submission;
  const mongoose = require("mongoose");

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

    if (
      !req.body ||
      !req.user ||
      !req.body.role ||
      !req.body.email ||
      !req.body.password ||
      !req.body.name ||
      !req.body
    ) {
      // Status code: 400
      console.log("Invalid request");
      res.status(400).send();
      return;
    }
    let user = await User.findOne({ _id: req.user });
    if (!user) {
      // Status code: 403
      console.log("User not found");
      res.status(403).send();
      return;
    }
    let existingUser = await User.findOne({ email: req.body.email });
    if (existingUser) {
      // Status code: 409
      console.log("User already exists");
      res.status(409).send();
      return;
    }

    if (canCreateUser(user.role, req.body.role)) {
      console.log("Creating user");
      // create user
      req.body.password = await bcrypt.hash(req.body.password, 10);
      let newUser = new User(req.body);
      let error = newUser.validateSync();

      if (!error) {
        // create user
        let createdUser = await User.create(req.body);
        console.log("User created: " + createdUser);
        res.status(201).send({ _id: createdUser._id });
        return;
      } else {
        console.log("Error creating user");
        // Status code: 400
        res.status(400).send();
        return;
      }
    } else {
      // Status code: 403
      console.log("Cannot create user");
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
      res.status(500).send({ message: "User not found" });
      return;
    } else if (!user.password) {
      // Status code: 400
      res.status(400).send({ message: "Password not provided" });
      return;
    }

    // Status code: 200
    if (await bcrypt.compare(req.body.password, user.password)) {
      const token = jwt.sign({ _id: user._id }, process.env.TOKEN_SECRET);
      res.status(200).send({ token: token });
    } else {
      // Status code: 400
      res.status(400).send({ message: "Invalid password" });
    }

    res.send();
    return;
  });

  /**
     * Fetch data about a specific User.
     * Returns information about the specified User.  If the User has the 'instructor' role, the response should include a list of the IDs of the Courses the User teaches (i.e. Courses whose `instructorId` field matches the ID of this User).  If the User has the 'student' role, the response should include a list of the IDs of the Courses the User is enrolled in.  Only an authenticated User whose ID matches the ID of the requested User can fetch this information.

    */
  app.get("/users/:id", async (req, res) => {
    console.log("GET /users/:id");
    if (!req.user || !req.params.id) {
      // Status code: 401
      res.status(401).send();
      return;
    }
    let u;
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      console.log("Invalid ID");
      // if passed an incorrect id
      u = await User.findOne({ _id: req.user }); // use token's id to get
    } else {
      console.log("Valid ID");
      u = await User.findOne({ _id: req.params.id }); // use passed id to get
    }

    if (!u) {
      console.log("User not found");
      // Status code: 400
      res.status(400);
      res.send();
      return;
    }
    if (u._id.toString() !== req.user._id.toString() && u.role !== "admin") {
      // Status code: 403
      res.status(403);
      res.send();
      return;
    }

    // Status code: 200
    if (u.role === "instructor") {
      console.log("Instructor");
      const courses = await Course.find({ instructorId: u._id });
      res.status(200);
      res.send(courses);
      return;
    } else if (u.role === "student") {
      console.log("Student");
      // find all courses where this student is in the students list
      const courses = await Course.find({ students: u._id });
      res.status(200);
      res.send(courses);
      return;
    } else {
      console.log("Admin");
      res.status(200);
      res.send(u);
      return;
    }
  });

  app.get("/users/", async (req, res) => {
    //fetch all users for admins only
    let user = await User.findOne({ _id: req.user });
    if (!user || user.role !== "admin") {
      res.status(403).send();
      return;
    }
    let users = await User.find({});
    res.status(200).send(users);
  });

};