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

//redis
const redis = require("redis");
const client = redis.createClient({
  host: "localhost", // Docker container running on the same host
  port: 6379,
});

client.on("error", (err) => {
  console.error("Redis error:", err);
});

const rateLimitMiddleware = async (req, res, next) => {
  const ip = req.ip;
  const bucketSize = 10; // Maximum number of tokens in the bucket
  const refillRate = 1; // Tokens added per second
  const refillInterval = 1000; // Refill interval in milliseconds
  const hashKey = `rate_limit:${ip}`;

  const currentTime = Date.now();
  const hashData = await client.hgetall(hashKey);

  let tokens;
  let lastRefillTime;

  if (hashData && Object.keys(hashData).length > 0) {
    tokens = parseInt(hashData.tokens);
    lastRefillTime = parseInt(hashData.lastRefillTime);
  } else {
    tokens = bucketSize;
    lastRefillTime = currentTime;
  }

  // Calculate the number of tokens to add based on elapsed time
  const elapsedTime = (currentTime - lastRefillTime) / refillInterval;
  const newTokens = Math.min(
    bucketSize,
    tokens + Math.floor(elapsedTime * refillRate)
  );
  tokens = newTokens;
  lastRefillTime =
    currentTime - ((currentTime - lastRefillTime) % refillInterval);

  if (tokens > 0) {
    // Consume a token
    tokens -= 1;
    await client.hset(hashKey, "tokens", tokens);
    await client.hset(hashKey, "lastRefillTime", lastRefillTime);
    next();
  } else {
    res.status(429).send("Too many requests, please try again later.");
  }
};

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
app.use(rateLimitMiddleware); //make first if we want to allow not logged in users, but still limit

// add our routes
require("./routes/users")(app);
require("./routes/courses")(app);
require("./routes/assignments")(app);

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
