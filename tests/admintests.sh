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
else
    printf "FAILURE: Empty response\n"
    printf "FAILURE: $responseCode\n"

    exit 1
fi



status "POSTING A COURSE AS ADMIN "
course='{
    "title": "new course",
    "subject": "CS",
    "number": "101",
    "term": "Fall 2021",
    "instructorId": "6667374fc4a0c73614394733" 

}' #the instructor id is a fake id
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


printf "$courseId\n"
status "GETTING A COURSE BY ID AS ADMIN (ONLY TESTED HERE, ROLE DOES NOT MATTER)"
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
    "instructorId": "6667374fc4a0c73614394733" 

}' #the instructor id is a fake id

response=$(curl -s -w "\n%{http_code}" -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$course" "$url/courses/$courseId")
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
response=$(get /courses/1/students)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
    exit 1
fi

status "POSTING AN UPDATE TO A COURSE'S ENROLLMENT"
status "FIX MEEEEEEE"

status "GETTING STUDEN ROSTER"
response=$(get /courses/1/roster)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $reponse\n"
fi

status "GETTING ALL ASSIGNMENTS IN A COURSE"
response=$(get /courses/1/assignments)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

satus "POSTING AN ASSIGNMENT"
assignment='{
    "name": "new assignment",
    "description": "new assignment description",
    "due_date": "2021-12-31",
    "points": 100
}'
response=$(post "$assignment" /courses/1/assignments)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "GETTING AN ASSIGNMENT"
response=$(get /assignments/1)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "UPDATING AN ASSIGNMENT"
assignment='{
    "name": "updated assignment",
    "description": "updated assignment description",
    "due_date": "2021-12-31",
    "points": 100
}'
response=$(put "$assignment" /assignments/1)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "DELETING AN ASSIGNMENT"
response=$(delete /assignments/1)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "GETTING ALL SUBMISSIONS FOR AN ASSIGNMENT"
response=$(get /assignments/1/submissions)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi
status "POSTING A SUBMISSION"
submission='{
    "student_id": 1,
    "assignment_id": 1,
    "grade": 100,
    "feedback": "good job"
}'
response=$(post "$submission" /assignments/1/submissions)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

