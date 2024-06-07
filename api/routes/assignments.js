/* API endpoints related to Assignments.
 */


/**
 * Create a new Assignment.
 * Create and store a new Assignment with specified data and adds it to the application's database.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course corresponding to the Assignment's `courseId` can create an Assignment.

 */
app.post('/assignments', (req, res) => {

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
 * Fetch data about a specific Assignment.
 * Returns summary data about the Assignment, excluding the list of Submissions.

 */
app.get('/assignments/{id}', (req, res) => {

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
 * Update data for a specific Assignment.
 * Performs a partial update on the data for the Assignment.  Note that submissions cannot be modified via this endpoint.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course corresponding to the Assignment's `courseId` can update an Assignment.

 */
app.patch('/assignments/{id}', (req, res) => {

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
 * Remove a specific Assignment from the database.
 * Completely removes the data for the specified Assignment, including all submissions.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course corresponding to the Assignment's `courseId` can delete an Assignment.

 */
app.delete('/assignments/{id}', (req, res) => {

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
 * Fetch the list of all Submissions for an Assignment.
 * Returns the list of all Submissions for an Assignment.  This list should be paginated.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course corresponding to the Assignment's `courseId` can fetch the Submissions for an Assignment.

 */
app.get('/assignments/{id}/submissions', (req, res) => {

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
 * Create a new Submission for an Assignment.
 * Create and store a new Assignment with specified data and adds it to the application's database.  Only an authenticated User with 'student' role who is enrolled in the Course corresponding to the Assignment's `courseId` can create a Submission.

 */
app.post('/assignments/{id}/submissions', (req, res) => {

    // Status code: 201
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

