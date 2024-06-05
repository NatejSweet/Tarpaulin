/* API endpoints related to application Users.
 */


/**
 * Create a new User.
 * Create and store a new application User with specified data and adds it to the application's database.  Only an authenticated User with 'admin' role can create users with the 'admin' or 'instructor' roles.

 */
app.post('/users', (req, res) => {

    // Status code: 201
    if (/* condition */) {
    } else if (/* condition */) {
        // Status code: 400
    } else if (/* condition */) {
        // Status code: 403
    } else {
        // unknown error
    }
    res.send()
    res.end()
    return
})



/**
 * Log in a User.
 * Authenticate a specific User with their email address and password.

 */
app.post('/users/login', (req, res) => {

    // Status code: 200
    if (/* condition */) {
    } else if (/* condition */) {
        // Status code: 400
    } else if (/* condition */) {
        // Status code: 401
    } else if (/* condition */) {
        // Status code: 500
    } else {
        // unknown error
    }
    res.send()
    res.end()
    return
})



/**
 * Fetch data about a specific User.
 * Returns information about the specified User.  If the User has the 'instructor' role, the response should include a list of the IDs of the Courses the User teaches (i.e. Courses whose `instructorId` field matches the ID of this User).  If the User has the 'student' role, the response should include a list of the IDs of the Courses the User is enrolled in.  Only an authenticated User whose ID matches the ID of the requested User can fetch this information.

 */
app.get('/users/{id}', (req, res) => {

    // Status code: 200
    if (/* condition */) {
    } else if (/* condition */) {
        // Status code: 403
    } else if (/* condition */) {
        // Status code: 404
    } else {
        // unknown error
    }
    res.send()
    res.end()
    return
})

