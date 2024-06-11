status() {
    printf "\n=====================================================\n"
    printf "%s\n" "$1"
    printf -- "-----------------------------------------------------\n"
}
# url is
url="http://localhost:8000"


post() {
    curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$1" $url$2
}
get() {
    curl -s -X GET "$url$1" -H "Authorization: Bearer $TOKEN"
}
put() {
    curl -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$1" $url$2
}
delete() {
    curl -X DELETE -H "Authorization: Bearer $TOKEN" $url$1
}
status "GETTING AUTH FOR ADMIN TO MAKE DATA"
login='{
    "email": "example@example.com",
    "password": "hunter2"
}'

response=$(curl -X POST -H "Content-Type: application/json" -d "$login" $url/users/login)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
    ADMINTOKEN=$(echo $response | jq -r '.token')
fi

status "MAKING A INSTRUCTOR"
instructor='{
    "name": "new instructor",
    "email": "instruction@.com",
    "password": "hunterzzzz",
    "role": "instructor"
}'
response=$(curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $ADMINTOKEN" -d "$instructor" $url/users)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
    INSTRUCTORID=$(echo $response | jq -r '._id')
fi

status "POSTING A COURSE AS ADMIN "
course='{
    "title": "new course",
    "subject": "CS",
    "number": "101",
    "term": "Fall 2021",
    "instructorId": "'$INSTRUCTORID'" 

}' #the instructor id is a fake id
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$course" "$url/courses" -H "Authorization: Bearer $ADMINTOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 201 ]; then 
    printf "SUCCESS: $responseCode\n"
    printf "$responseBody\n"
    courseId=$(echo $responseBody | jq -r '._id')
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi
status "POSTING AN ALTERNATE COURSE AS ADMIN"
course='{
    "title": "new course",
    "subject": "CS",
    "number": "102",
    "term": "Fall 2021",
    "instructorId": "'$INSTRUCTORID'" 

}' #the instructor id is a fake id
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$course" "$url/courses" -H "Authorization: Bearer $ADMINTOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 201 ]; then 
    printf "SUCCESS: $responseCode\n"
    printf "$responseBody\n"
    alternateCourseId=$(echo $responseBody | jq -r '._id')
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "ADDING AN ASSIGNMENT TO A COURSE"
assignment='{
    "courseId": "'$courseId'",
    "title": "new assignment",  
    "points": 10,
    "due": "2022-12-31"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/assignments" -H "Content-Type: application/json" -H "Authorization: Bearer $ADMINTOKEN" -d "$assignment" )
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 201 ]; then
    printf "SUCCESS: $response\n"
    assignmentId=$(echo $response | jq -r '._id')
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "POSTING AN ALTERNATE ASSIGNMENT TO A COURSE"
assignment='{
    "courseId": "'$alternateCourseId'",
    "title": "new assignment",  
    "points": 10,
    "due": "2022-12-31"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/assignments" -H "Content-Type: application/json" -H "Authorization: Bearer $ADMINTOKEN" -d "$assignment" )
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 201 ]; then
    printf "SUCCESS: $response\n"
    alternateAssignmentId=$(echo $response | jq -r '._id')
else
    printf "FAILURE: $response\n"
    exit 1
fi


status "POSTING A STUDENT"
student='{
    "name": "student",
    "email": "anotheremail@ent.com",
    "password": "hunter7",
    "role": "student"
    }'
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $ADMINTOKEN" -d "$student" "$url/users")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 201 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi
studentId=$(echo $responseBody | jq -r '._id')


status "ADDING A STUDENT TO A COURSE"
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $ADMINTOKEN" -d '{"adds": ["'"$studentId"'"]}' "$url/courses/$courseId/students")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
    printf "enrollment: $responseBody\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "LOGGING IN AS STUDENT"
login='{
    "email": "anotheremail@ent.com",
    "password": "hunter7"
}'
response=$(curl -X POST -H "Content-Type: application/json" -d "$login" $url/users/login)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
    TOKEN=$(echo $response | jq -r '.token')
fi

status "GETTING ALL COURSES"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq  200 ]; then
    printf "SUCCESS: $responseBody\n"
    otherCourseId=$(echo "$responseBody" | jq -r '.courses[0]._id')
else
    printf "FAILURE: Empty response\n"
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "POSTING A COURSE AS STUDENT IS FORBIDDEN"
course='{
    "title": "new course",
    "description": "new course description",
    "subject": "CS",
    "number": "101",
    "term": "Fall 2021",
    "instructorId": "6667374fc4a0c73614394733" 

}' #the instructor id is a fake id
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$course" "$url/courses" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then 
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "UPDATING A COURSE AS STUDENT IS FORBIDDEN"
course='{
    "title": "new UPDATED course",
    "subject": "CS",
    "number": "101",
    "term": "Fall 2021",
    "instructorId": "6667374fc4a0c73614394733" 

}' #the instructor id is a fake id

printf "$courseId\n"
response=$(curl -s -w "\n%{http_code}" -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$course" "$url/courses/$courseId")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "DELETING A COURSE AS STUDENT IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "$url/courses/$courseId")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "GETTING ALL STUDENTS IN A COURSE IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$courseId/students" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "ADDING ENROLLMENT AS STUDENT IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"adds": ["6667374fc4a0c73614394733"]}' "$url/courses/$courseId/students")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "REMOVING ENROLLMENT AS STUDENT IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"removes": ["6667374fc4a0c73614394733"]}' "$url/courses/$courseId/students")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi
status "GETTING STUDENT ROSTER AS A STUDENT IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$courseId/students" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING ALL ASSIGNMENTS AS A STUDENT"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$courseId/assignments" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
    printf "SUCCESS: $responseBody\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "POSTING AN ASSIGNMENT AS A STUDENT IS FORBIDDEN"
assignment='{
    "courseId": "'$courseId'",
    "title": "new assignment",
    "points": 100,
    "due": "2021-12-31"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/courses/$courseId/assignments" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$assignment") 
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING AN ASSIGNMENT AS A STUDENT"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/assignments/$assignmentId" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
    printf "SUCCESS: $responseBody\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "UPDATING AN ASSIGNMENT AS A STUDENT IS FORBIDDEN"
assignment='{
    "courseId": "'$courseId'",
    "title": "updated assignment",
    "points": 100,
    "due": "2021-12-31"
}'
response=$(curl -s -w "\n%{http_code}" -X PATCH "http://localhost:8000/assignments/$assignmentId" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$assignment")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi
status "POSTING A SUBMISSION TO A CLASS ENROLLED IN"
submission='{
    "student_id": "'$studentId'",
    "assignment_id": "'$assignmentId'",
    "timestamp": "2022-12-31",
    "grade": 10,
    "file": "file"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/assignments/$assignmentId/submissions" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$submission")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 201 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi
status "POSTING A SUBMISIIONS TO A CLASS YOU ARE NOT ENROLLED IN IS FORBIDDEN"
submission='{
    "student_id": "'$studentId'",
    "assignment_id": "'$alternateAssignmentId'",
    "timestamp": "2022-12-31",
    "grade": 10,
    "file": "file"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/assignments/$alternateAssignmentId/submissions" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$submission")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING ALL SUBMISSIONS FOR AN ASSIGNMENT IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/assignments/$assignmentId/submissions" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "DELETING AN ASSIGNMENT AS STUDENT IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X DELETE "$url/assignments/$assignmentId" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi



