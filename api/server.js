console.log("we are starting ");

require("./mongodb/connect")().then(() => {
  //connect to mongodb
  console.log("connected, uploading initial data");
  require("./mongodb/upload")(); //upload data to mongodb
});

const express = require("express");
const bodyParser = require("body-parser");
const app = express();
app.use(bodyParser.json());
module.exports.app = app;
const port = process.env.PORT;

// Rate limiting
const rateLimit = require('express-rate-limit')

const limiter = rateLimit({
	windowMs: 15 * 60 * 1000, // 15 minutes
	limit: 100, // Limit each IP to 100 requests per `window` (here, per 15 minutes).
	standardHeaders: 'draft-7', // draft-6: `RateLimit-*` headers; draft-7: combined `RateLimit` header
	legacyHeaders: false, // Disable the `X-RateLimit-*` headers.
	// store: ... , // Redis, Memcached, etc. See below.
})

// Apply the rate limiting middleware to all requests.
app.use(limiter)

//json web token
const jwt = require("jsonwebtoken");
const jwtVerificationMiddleware = async (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  if (req.path === "/users/login") {
    return next();
  }

  if (!token) {
    return res.status(401).send("Access denied");
  }

  try {
    const verified = await jwt.verify(token, process.env.TOKEN_SECRET);
    req.user = verified;
    next();
  } catch (err) {
    res.status(403).send("Invalid token");
  }
};

app.use(jwtVerificationMiddleware); //keep first if we only allow loged in users to do anything

// add our routes
require("./routes/users")(app);
require("./routes/courses")(app);
require("./routes/assignments")(app);

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
