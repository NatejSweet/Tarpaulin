# Tarpaulin API

## Technologies
- node, express, express-rate-limit
- mongoose for MongoDB, whith gridfs for file storage
- multer for file upload
- jsonwebtoken for authentication
- bcrypt for password hashing
- redis for caching
- docker for containerization

## Entities
- User
    - Student
        - Can be in courses and have submissions
    - Teacher
        - Can have courses
- Course
    - Can have one teacher, many students and assignments
- Assignment
    - Can have submissions
- Submission
    - Has one assignment and one student
    - Has content, (file or text)
    - Can have a grade
    
## Uses
- Teacher
    - Create a course
    - Add/Remove students to a course
    - Create an assignment
    - Grade submissions

- Student
    - See course info
    - Submit assignments
    - See submission info

# Docker info


# Rationale 

We chose express, because it will enable use to easily add routes programmatically from the openAPI spec. 
express-rate-limit is the standard choice for rate limiting, similiar with multer for upload.
mongoose was chosen so that we can remain in json land constantly, and cache mega-objects with all their foreighn keys filled in.
We will be creating our own hashing and authentication system with just jwt and bcrypt, as we do not need to associate accounts with 3rd party services.
Redis will allow us to easily distribute standard requests, like seeing all assignments in a course. 
Docker will only launch instance of each by default. 
When the app is started, all submodules are started and some sample data is inserted into the database.