import { Schema } from 'mongoose';

const UserS = new Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['admin', 'instructor', 'student'], default: 'student' }
});

const CourseS = new Schema({
    subject: { type: String, required: true },
    number: { type: String, required: true },
    title: { type: String, required: true },
    term: { type: String, required: true },
    instructorId: { type: Schema.Types.ObjectId, ref: 'User' }
});

const AssignmentS = new Schema({
    courseId: { type: Schema.Types.ObjectId, ref: 'Course' },
    title: { type: String, required: true },
    points: { type: Number, required: true },
    due: { type: Date, required: true }
});

const SubmissionS = new Schema({
    assignmentId: { type: Schema.Types.ObjectId, ref: 'Assignment' },
    studentId: { type: Schema.Types.ObjectId, ref: 'User' },
    timestamp: { type: Date, required: true },
    grade: { type: Number },
    file: { type: String }
});

// use the Schema to define a model
export const User = mongoose.model('User', UserS);
export const Course = mongoose.model('Course', CourseS);
export const Assignment = mongoose.model('Assignment', AssignmentS);
export const Submission = mongoose.model('Submission', SubmissionS);
