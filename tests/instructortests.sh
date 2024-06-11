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

printf "LOGGING IN AS ADMIN TO MAKE NEW INSTRUCTOR(AS TO GET ID FOR A COURSE)\n"
login='{
    "email": "example@example.com",
    "password": "hunter2"
}'
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$login" $url/users/login)
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    ADMINTOKEN=$( echo $responseBody | jq -r '.token')
else
    printf "ADMIN FAILED TO LOG IN: $responseCode\n"
    exit 1
fi
printf "POSTING A NEW INSTRUCTOR\n"
user='{
    "name": "new user",
    "email": "newInst2@user.com",
    "password": "thenewguy",
    "role": "instructor"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/users" -H "Content-Type: application/json" -H "Authorization: Bearer $ADMINTOKEN" -d "$user")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 201 ]; then
    userId=$(echo $responseBody | jq -r '._id')
else
    printf "FAILURE, INSTRUCTOR NOT CREATED: $responseCode\n"
    exit 1
fi

printf "POSTING A COURSE FOR INSTRUCTOR AS ADMIN \n"
course='{
    "title": "new course",
    "subject": "CS",
    "number": "101",
    "term": "Fall 2021",
    "instructorId": "'$userId'" 

}'
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$course" "$url/courses" -H "Authorization: Bearer $ADMINTOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 201 ]; then 
    instructorCourseId=$(echo $responseBody | jq -r '._id')
else
    printf "COURSE NOT POSTED: $responseCode\n"
    exit 1
fi

status "POSTING A NEW STUDENT USER TO ADD TO A COURSE"
student='{
    "name": "student",
    "email": "stu@ent.com",
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
printf "$studentId\n"

status "POSTING A NEW ASSIGNMENT FOR A COURSE"
assignment='{
    "courseId": "'$instructorCourseId'",
    "title": "new assignment",  
    "points": 10,
    "due": "2022-12-31"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/assignments" -H "Content-Type: application/json" -H "Authorization: Bearer $ADMINTOKEN" -d "$assignment" )
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 201 ]; then
    printf "SUCCESS: $responseCode\n"
    assignmentId=$(echo $responseBody | jq -r '._id')
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi



status "LOGGING IN AS INSTRUCTOR"
login='{
    "email": "example2@example.com",
    "password": "hunter2"
}'
response=$(curl -X POST -H "Content-Type: application/json" -d "$login" $url/users/login)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
    WRONG_INSTRUCTOR_TOKEN=$(echo $response | jq -r '.token')
fi

status "GETTING ALL COURSES"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq  200 ]; then
    printf "SUCCESS: $responseBody\n"
    courseId=$(echo "$responseBody" | jq -r '.courses[0]._id')
else
    printf "FAILURE: Empty response\n"
    printf "FAILURE: $responseCode\n"

    exit 1
fi



status "POSTING A COURSE AS INSTRUCTOR IS FORBIDDEN"
course='{
    "title": "new course",
    "description": "new course description",
    "subject": "CS",
    "number": "101",
    "term": "Fall 2021",
    "instructorId": "6667374fc4a0c73614394733" 

}' #the instructor id is a fake id
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN"  -d "$course" "$url/courses" )
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then 
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi


status "UPDATING A COURSE AS WRONG INSTRUCTOR IS FORBIDDEN"
course='{
    "title": "new UPDATED course",
    "subject": "CS",
    "number": "101",
    "term": "Fall 2021",
    "instructorId": "6667374fc4a0c73614394733" 

}' #the instructor id is a fake id
response=$(curl -s -w "\n%{http_code}" -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN" -d "$course" "$url/courses/$instructorCourseId")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "LOGGING IN AS NEW INSTRUCTOR"
login='{
    "email": "newInst2@user.com",
    "password": "thenewguy"
}'
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$login" $url/users/login)
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseCode\n"
    TOKEN=$( echo $responseBody | jq -r '.token')
else
    printf "INSTRUCTOR FAILED TO LOG IN: $responseCode\n"
    exit 1
fi

status "UPDATING A COURSE AS COURSE'S INSTRUCTOR IS ALLOWED"
course='{
    "title": "new UPDATED course",
    "subject": "CS",
    "number": "101",
    "term": "Fall 2021",
    "instructorId": "'$userId'" 
}'
printf "$instructorCourseId\n"
response=$(curl -s -w "\n%{http_code}" -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$course" "$url/courses/$instructorCourseId")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi 

status "DELETING A COURSE AS INSTRUCTOR IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X DELETE -H "Authorization: Bearer $TOKEN" "$url/courses/$instructorCourseId")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "ADDING A STUDENT TO A COURSE AS CORRECT INSTRUCTOR"
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"adds": ["'"$studentId"'"]}' "$url/courses/$instructorCourseId/students")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
    printf "enrollment: $responseBody\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "ADDING A STUDENT TO A COURSE AS WRONG INSTRUCTOR IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN" -d '{"adds": ["'"$studentId"'"]}' "$url/courses/$instructorCourseId/students")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "GETTING ALL STUDENTS IN A COURSE AS CORRECT INSTRUCTOR"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$instructorCourseId/students" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
    printf "enrollment: $responseBody\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING ALL STUDENTS IN A COURSE AS WRONG INSTRUCTOR IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$instructorCourseId/students" -H "Content-Type: application/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "DELETING A STUDENT FROM A COURSE AS CORRECT INSTRUCTOR"
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"removes": ["'"$studentId"'"]}' "$url/courses/$instructorCourseId/students")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseCode\n"
    printf "enrollment: $responseBody\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "DELETING A STUDENT FROM A COURSE AS WRONG INSTRUCTOR IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN" -d '{"removes": ["'"$studentId"'"]}' "$url/courses/$instructorCourseId/students")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING STUDENT ROSTER AS CORRECT INSTRUCTOR"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$instructorCourseId/roster" -H "Content-Type: applicaiton/json" -H "Authorization: Bearer $TOKEN" --output roster.csv)
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING STUDENT ROSTER AS WRONG INSTRUCTOR IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$instructorCourseId/roster" -H "Content-Type: applicaiton/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN" --output roster.csv)
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING ALL ASSIGNMENTS IN A COURSE AS CORRECT INSTRUCTOR"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$instructorCourseId/assignments" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseCode\n"
    printf "SUCCESS: $responseBody\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING ALL ASSIGNMENTS IN A COURSE AS WRONG INSTRUCTOR IS ALLOWED"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$instructorCourseId/assignments" -H "Content-Type: application/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseCode\n"
    printf "SUCCESS: $responseBody\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "POSTING A NEW ASSIGNMENT FOR A COURSE AS CORRECT INSTRUCTOR"
assignment='{
    "courseId": "'$instructorCourseId'",
    "title": "newer assignment",  
    "points": 100,
    "due": "2022-12-31"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/assignments" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$assignment" ) 
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 201 ]; then
    printf "SUCCESS: $responseCode\n"
    printf "SUCCESS: $responseBody\n"
    assignmentId=$(echo $responseBody | jq -r '._id')
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi


status "POSTING AN ASSIGNMENT AS CORRECT INSTRUCTOR"
assignment='{
    "courseId": "'$instructorCourseId'",
    "title": "new assignment",  
    "points": 10,
    "due": "2022-12-31"
}'
printf "$assignment\n"
response=$(curl -s -w "\n%{http_code}" -X POST "$url/assignments" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$assignment" )
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 201 ]; then
    printf "SUCCESS: $responseCode\n"
    printf "SUCCESS: $responseBody\n"
    assignmentId=$(echo $responseBody | jq -r '._id')
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "POSTING AN ASSIGNMENT AS WRONG INSTRUCTOR IS FORBIDDEN"
assignment='{
    "courseId": "'$instructorCourseId'",
    "title": "new assignment",  
    "points": 10,
    "due": "2022-12-31"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/assignments" -H "Content-Type: application/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN" -d "$assignment" )
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "GETTING AN ASSIGNMENT AS CORRECT INSTRUCTOR"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/assignments/$assignmentId" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseCode\n"
    printf "SUCCESS: $responseBody\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "GETTING AN ASSIGNMENT AS WRONG INSTRUCTOR IS ALLOWED"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/assignments/$assignmentId" -H "Content-Type: application/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "UPDATING AN ASSIGNMENT AS CORRECT INSTRUCTOR"
assignment='{
    "courseId": "'$instructorCourseId'",
    "title": "new updated assignment",  
    "points": 20,
    "due": "2022-12-31"
}'
response=$( curl -s -w "\n%{http_code}" -X PATCH "$url/assignments/$assignmentId" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$assignment")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "UPDATING AN ASSIGNMENT AS WRONG INSTRUCTOR IS FORBIDDEN"
assignment='{
    "courseId": "'$instructorCourseId'",
    "title": "new updated assignment",  
    "points": 20,
    "due": "2022-12-31"
}'
response=$( curl -s -w "\n%{http_code}" -X PATCH "$url/assignments/$assignmentId" -H "Content-Type: application/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN" -d "$assignment")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "POSTING A SUBMISSION AS INSTRUCTOR IS FORBIDDEN"
submission='{
    "student_id": "'$studentId'",
    "assignment_id": "'$assignmentId'",
    "timestamp": "2022-12-31",
    "grade": 10,
    "file": "file"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/assignments/$assignmentId/submissions" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$submission")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "GETTING ALL SUBMISSIONS FOR AN ASSIGNMENT AS CORRECT INSTRUCTOR"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/assignments/$assignmentId/submissions" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING ALL SUBMISSIONS FOR AN ASSIGNMENT AS WRONG INSTRUCTOR IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/assignments/$assignmentId/submissions" -H "Content-Type: application/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi
status "DELETING AN ASSIGNMENT AS WRONG INSTRUCTOR IS FORBIDDEN"
response=$(curl -s -w "\n%{http_code}" -X DELETE "$url/assignments/$assignmentId" -H "Content-Type: application/json" -H "Authorization: Bearer $WRONG_INSTRUCTOR_TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "DELETING AN ASSIGNMENT AS CORRECT INSTRUCTOR"
response=$(curl -s -w "\n%{http_code}" -X DELETE "$url/assignments/$assignmentId" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi








