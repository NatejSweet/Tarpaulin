/* API endpoints related to Courses.
 */


/**
 * Fetch the list of all Courses.
 * Returns the list of all Courses.  This list should be paginated.  The Courses returned should not contain the list of students in the Course or the list of Assignments for the Course.

 */
app.get('/courses', (req, res) => {

    // Status code: 200
    if (/* condition */) {
    } else {
        // unknown error
    }
    res.send()
    res.end()
    return
})



/**
 * Create a new course.
 * Creates a new Course with specified data and adds it to the application's database.  Only an authenticated User with 'admin' role can create a new Course.

 */
app.post('/courses', (req, res) => {

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
 * Fetch data about a specific Course.
 * Returns summary data about the Course, excluding the list of students enrolled in the course and the list of Assignments for the course.

 */
app.get('/courses/{id}', (req, res) => {

    // Status code: 200
    if (/* condition */) {
    } else if (/* condition */) {
        // Status code: 404
    } else {
        // unknown error
    }
    res.send()
    res.end()
    return
})



/**
 * Update data for a specific Course.
 * Performs a partial update on the data for the Course.  Note that enrolled students and assignments cannot be modified via this endpoint.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can update Course information.

 */
app.patch('/courses/{id}', (req, res) => {

    // Status code: 200
    if (/* condition */) {
    } else if (/* condition */) {
        // Status code: 400
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



/**
 * Remove a specific Course from the database.
 * Completely removes the data for the specified Course, including all enrolled students, all Assignments, etc.  Only an authenticated User with 'admin' role can remove a Course.

 */
app.delete('/courses/{id}', (req, res) => {

    // Status code: 204
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



/**
 * Fetch a list of the students enrolled in the Course.
 * Returns a list containing the User IDs of all students currently enrolled in the Course.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can fetch the list of enrolled students.

 */
app.get('/courses/{id}/students', (req, res) => {

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



/**
 * Update enrollment for a Course.
 * Enrolls and/or unenrolls students from a Course.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can update the students enrolled in the Course.

 */
app.post('/courses/{id}/students', (req, res) => {

    // Status code: 200
    if (/* condition */) {
    } else if (/* condition */) {
        // Status code: 400
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



/**
 * Fetch a CSV file containing list of the students enrolled in the Course.
 * Returns a CSV file containing information about all of the students currently enrolled in the Course, including names, IDs, and email addresses.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can fetch the course roster.

 */
app.get('/courses/{id}/roster', (req, res) => {

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



/**
 * Fetch a list of the Assignments for the Course.
 * Returns a list containing the Assignment IDs of all Assignments for the Course.

 */
app.get('/courses/{id}/assignments', (req, res) => {

    // Status code: 200
    if (/* condition */) {
    } else if (/* condition */) {
        // Status code: 404
    } else {
        // unknown error
    }
    res.send()
    res.end()
    return
})

