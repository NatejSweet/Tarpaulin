/* API endpoints related to Courses.
 */


/**
 * Fetch the list of all Courses.
 * Returns the list of all Courses.  This list should be paginated.  The Courses returned should not contain the list of students in the Course or the list of Assignments for the Course.

 */
app.get('/courses', async (req, res) => {//does this need auth?\
    try {
        if (!req.body) {
            // Status code: 500
            res.status(500).send()
            return
        }
        const courses = await Course.find().select('subject number title term _id')
        if (!courses) {
            // Status code: 500
            res.status(500).send()
            return

        } else {
            // Status code: 200
            res.status(200).send({courses: courses})
            return
        }
    } catch (err) {
        console.error(err);
        res.status(500).send()
        return
    }
})



/**
 * Create a new course.
 * Creates a new Course with specified data and adds it to the application's database.  Only an authenticated User with 'admin' role can create a new Course.

 */
app.post('/courses', async (req, res) => {
    try {
        if (!req.body || !req.body.course || !req.body.user ) {
            // Status code: 400
            res.status(400).send()
            return
        }
        const user = await User.findOne({password: req.body.user})
        if (user.role != 'admin') {
            // Status code: 403
            res.status(403).send()
            return
        }
        if (Course.validateSync(req.body.course)) {
            // Status code: 201
            const course = await Course.create(req.body.course)
            if (!course) {
                // Status code: 500
                res.status(500).send()
                return
            }
            // Status code: 201
            res.status(201).send({course_id: course._id})
            return
        } else {
            // Status code: 400
            res.status(400).send()
            return
        }
    }
    catch (err) {
        console.error(err);
        res.status(500).send()
        return
    }


})



/**
 * Fetch data about a specific Course.
 * Returns summary data about the Course, excluding the list of students enrolled in the course and the list of Assignments for the course.

 */
app.get('/courses/{id}', async (req, res) => {
    try {
        if (!req.body) {
                // Status code: 500   
                res.status(500).send()
                return
            }
            const course = await Course.findOne({_id: req.params.id}).select('subject number title term instructorId')
            if (!course) {
                // Status code: 404
                res.status(404).send()
                return
            } else {
                // Status code: 200
                res.status(200).send({course: course})
                return

            }
    } catch (err) {
        console.error(err);
        res.status(500).send()
        return
    }
})



/**
 * Update data for a specific Course.
 * Performs a partial update on the data for the Course.  Note that enrolled students and assignments cannot be modified via this endpoint.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can update Course information.

 */
app.patch('/courses/:id', async (req, res) => {
    try {
        if (!req.body || !req.body.course || !req.body.user ) {
            // Status code: 400
            res.status(400).send();
            return;
        }
        const user = await User.findOne({password: req.body.user});
        const course = await Course.findOne({_id: req.params.id});
        if (user.role !== 'admin' && (user.role !== 'instructor' || course.instructorId !== user._id)) {
            // Status code: 403
            res.status(403).send();
            return;
        }
        try {
            Course.validateSync(req.body.course);
        } catch (err) {
            // Status code: 400
            res.status(400).send();
            return;
        }
        const result = await Course.updateOne({_id: req.params.id}, req.body.course);
        if (!result.nModified > 0) {
            // Status code: 500
            res.status(500).send();

        } else {
            // Status code: 200
            res.status(200).send();
            
        }
    } catch (err) {
        console.error(err);
        res.status(500).send();
    }
});



/**
 * Remove a specific Course from the database.
 * Completely removes the data for the specified Course, including all enrolled students, all Assignments, etc.  Only an authenticated User with 'admin' role can remove a Course.

 */
app.delete('/courses/{id}', async (req, res) => {
    try {
        if (!req.body || !req.body.user ) {
            // Status code: 400
            res.status(400).send();
            return;
        }
        const user = await User.findOne({password: req.body.user});
        if (user.role != 'admin') {
            // Status code: 403
            res.status(403).send();
            return;
        }
        const course = await Course.findOne({_id: req.params.id});
        if (!course) {
            // Status code: 404
            res.status(404).send();
            return;
        }
        const result = await Course.delete({_id: req.params.id});
        if (!result.deletedCount>0) {
            // Status code: 500
            res.status(500).send();
            return;
        }
        const students = await User.find({courses: req.params.id});
        for (let student of students) {
            student.courses = student.courses.filter(course => course != req.params.id);
            await student.save();
        }
        const assignments = await Assignment.deleteMany({courseId: req.params.id});
        if (assignments.deletedCount>0) {
            // Status code: 200
            res.status(200).send();
        } else {
            // Status code: 500
            res.status(500).send();
        }
    } catch (err) {
        console.error(err);
        res.status(500).send();
    }
});


/**
 * Fetch a list of the students enrolled in the Course.
 * Returns a list containing the User IDs of all students currently enrolled in the Course.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can fetch the list of enrolled students.

 */
app.get('/courses/{id}/students',async  (req, res) => {
    try {
        if (!req.body || !req.body.user ) {
            // Status code: 400
            res.status(400).send()
            return
        }
        const user =  await User.findOne({password: req.body.user})
        const course =  await Course.findOne({_id: req.params.id})
        if (user.role != 'admin' || (user.role != 'instructor' && course.instructorId != user._id)) {
            // Status code: 403
            res.status(403).send()
            return
        }
        // Status code: 200
        res.status(200).send({students: course.students})
        return 
    }
    catch (err) {
        console.error(err);
        // Status code: 500
        res.status(500).send()
        return
    }
})



/**
 * Update enrollment for a Course.
 * Enrolls and/or unenrolls students from a Course.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can update the students enrolled in the Course.

 */
app.post('/courses/:id/students', async (req, res) => {
    try {
        if (!req.body || !req.body.user || (!req.body.adds && !req.body.removes)) {
            res.status(400).send();
            return;
        }
        const user = await User.findOne({password: req.body.user});
        const course = await Course.findOne({_id: req.params.id});
        if (user.role !== 'admin' && (user.role !== 'instructor' || course.instructorId !== user._id)) {
            res.status(403).send();
            return;
        }
        if (req.body.adds){
            course.students.push(...req.body.adds);
            await course.save();
            for (let studentId of req.body.adds) {
                let student = await User.findOne({_id: studentId});
                if (student) {
                    student.courses.push(req.params.id);
                    await student.save();
                }
            }
        }
        if (req.body.removes){
            course.students = course.students.filter(student => !req.body.removes.includes(student));
            await course.save();
            for (let studentId of req.body.removes) {
                let student = await User.findOne({_id: studentId});
                if (student) {
                    student.courses = student.courses.filter(course => course != req.params.id);
                    await student.save();
                }
            }
        }
    } catch (err) {
        console.error(err);
        res.status(500).send();
    }
    res.status(200).send();
    return;
});



/**
 * Fetch a CSV file containing list of the students enrolled in the Course.
 * Returns a CSV file containing information about all of the students currently enrolled in the Course, including names, IDs, and email addresses.  Only an authenticated User with 'admin' role or an authenticated 'instructor' User whose ID matches the `instructorId` of the Course can fetch the course roster.

 */
app.get('/courses/{id}/roster', async (req, res) => {

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
app.get('/courses/{id}/assignments', async (req, res) => {
    try {
        if (!req.body || !req.body.user ) {
            // Status code: 400
            res.status(400).send()
            return
        }
        const user = await User.findOne({password: req.body.user})
        if (!user) {
            // Status code: 403
            res.status(403).send()
            return
        }
        const course = await Course.findOne({_id: req.params.id})
        if (!course) {
            // Status code: 404
            res.status(404).send()
            return
        }
        const assignments = await Assignment.find({courseId: req.params.id}).select('_id')
        if (!assignments) {
            // Status code: 500
            res.status(500).send()
            return
        }
        // Status code: 200
        res.status(200).send({assignments: assignments})
        return
    } catch (err) {
        console.error(err);
        // Status code: 500
        res.status(500).send()
    }

})

