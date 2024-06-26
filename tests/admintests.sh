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
    curl -X DELETE -H "Authorization: Bearer $TOKEN" $url/$1
}


status "GETTING AUTH"
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
    TOKEN=$(echo $response | jq -r '.token')
fi
status "GETTING ALL COURSES"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq  200 ]; then
    printf "SUCCESS: $responseBody\n"
    dataFilledCourse=$(echo "$responseBody" | jq -r '.courses[0]._id')
else
    printf "FAILURE: Empty response\n"
    printf "FAILURE: $responseCode\n"

    exit 1
fi

status "POSTING A USER"
user='{
    "name": "new user",
    "email": "sosleepy@tired.com",
    "password": "honkshooo",
    "role": "instructor"
}'
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$user" "$url/users" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 201 ]; then
    printf "SUCCESS: $responseCode\n"
    printf "$responseBody\n"
    instructorId=$(echo $responseBody | jq -r '._id')
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi



status "POSTING A COURSE AS ADMIN "
course='{
    "title": "new course",
    "subject": "CS",
    "number": "101",
    "term": "Fall 2021",
    "instructorId": "'$instructorId'" 

}'
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$course" "$url/courses" -H "Authorization: Bearer $TOKEN")
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



status "GETTING A COURSE BY ID AS ADMIN"
printf "$courseId\n"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$courseId" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseBody\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "UPDATING A COURSE AS ADMIN"
course='{
    "title": "new UPDATED course",
    "subject": "CS",
    "number": "101",
    "term": "Fall 2021",
    "instructorId": "'$instructorId'" 

}'

response=$(curl -s -w "\n%{http_code}" -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$course" "$url/courses/$dataFilledCourse")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "DELETING A COURSE"
response=$(curl -s -w "\n%{http_code}" -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" $url/courses/$courseId)
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING ALL STUDENTS IN A COURSE"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$dataFilledCourse/students" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "POSTING A NEW STUDENT USER TO ADD TO A COURSE"
student='{
    "name": "student",
    "email": "stuuuu@ent.com",
    "password": "hunter7",
    "role": "student"
    }'
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$student" "$url/users")
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

status "ADDING A STUDENT TO A COURSE"
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"adds": ["'"$studentId"'"]}' "$url/courses/$dataFilledCourse/students")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
    printf "enrollment: $responseBody\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "DELETING A STUDENT FROM A COURSE"
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"removes": ["'"$studentId"'"]}' "$url/courses/$dataFilledCourse/students")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseCode\n"
    printf "enrollment: $responseBody\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi
printf "_____________________________________________________\n"
printf "ADDING STUDENT BACK FOR ROSTER TEST\m"
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"adds": ["'"$studentId"'"]}' "$url/courses/$dataFilledCourse/students")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "STUDENT RE-ADD SUCCESS: $response\n"
else
    printf "STUDENT RE-ADD FAILURE: $response\n"
    exit 1
fi

status "GETTING STUDENT ROSTER"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$dataFilledCourse/roster" -H "Content-Type: applicaiton/json" -H "Authorization: Bearer $TOKEN" --output roster.csv)
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING ALL ASSIGNMENTS IN A COURSE"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses/$dataFilledCourse/assignments" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $responseCode\n"
    printf "SUCCESS: $responseBody\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "POSTING AN ASSIGNMENT"
printf "$dataFilledCourse\n"
assignment='{
    "courseId": "'$dataFilledCourse'",
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

status "GETTING AN ASSIGNMENT"
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

status "UPDATING AN ASSIGNMENT"
assignment='{
    "courseId": "'$dataFilledCourse'",
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

status "POSTING A SUBMISSION"
submission='{
    "student_id": "'$studentId'",
    "assignment_id": "'$assignmentId'",
    "timestamp": "2022-12-31",
    "grade": 10,
    "file": "file"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/assignments/$assignmentId/submissions" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$submission")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 201 ]; then
    printf "SUCCESS: $responseCode\n"
    printf "SUCCESS: $responseBody\n"
    submissionId=$(echo $responseBody | jq -r '._id')
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi

status "GETTING ALL SUBMISSIONS FOR AN ASSIGNMENT"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/assignments/$assignmentId/submissions" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "DELETING AN ASSIGNMENT"
response=$(curl -s -w "\n%{http_code}" -X DELETE "$url/assignments/$assignmentId" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 200 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi
