status() {
    printf "\n=====================================================\n"
    printf "%s\n" "$1"
    printf -- "-----------------------------------------------------\n"
}

# url is
url="http://localhost:8000"

#get auth
status "GETTING AUTH"
login='{
    "email": "example@example.com",
    "password": "hunter2"
}'
response=$(curl -i -X POST -H "Content-Type: application/json" -d "$login" $url/users/login | grep Authorization)

if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    TOKEN=$(echo $response | cut -d ' ' -f 2)
    printf "SUCCESS: Auth retrieved\n"
fi

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

status "GETTING A USER WITHOUT AUTH"
response=$(curl -X GET $url/users/1)
if [ "$response" = "Access denied" ]; then
    printf "SUCCESS: 401 Access denied\n"
else
    echo "FAILURE: $response"
    exit 1
fi

user='{
    "name": "new user",
    "password": "hunter2",
    "role": "admin"
}'

status "POSTING A USER"
printf "$TOKEN\n"
response=$(curl -X POST "$url/users" -H "Content-Type: application/json" -H "Authorization Bearer $TOKEN" -d "$user")
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "$response\n"
    printf "SUCCESS: User posted\n"
fi

status "GETTING A USER"
response=$(curl -v -X GET "$url/users/1" -H "Content-Type: application/json" -H "Authorization Bearer $TOKEN") 
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi


status "GETTING ALL COURSES"
response=$(curl -s -X GET "$url/courses" -H "Authorization Bearer $TOKEN")
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else

    printf "SUCCESS: $response\n"
fi

status "POSTING A COURSE"
course='{
    "name": "new course",
    "description": "new course description"
}'
response=$(curl -s -X POST -H "Content-Type: application json" -d "$course" "$url/courses" "Authorization Bearer $TOKEN")
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: Course posted\n"
fi

status "GETTING A COURSE"
response=$(get /courses/1)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: Course retrieved\n"
fi

status "UPDATING A COURSE"
course='{
    "name": "updated course",
    "description": "updated course description"
}'
response=$(put "$course" /courses/1)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: Course updated\n"
fi

status "DELETING A COURSE"
response=$(delete /courses/1)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: Course deleted\n"
fi

status "GETTING ALL STUDENTS IN A COURSE"
response=$(get /courses/1/students)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: Students retrieved\n"
fi

status "POSTING AN UPDATE TO A COURSE'S ENROLLMENT"
status "FIX MEEEEEEE"

status "GETTING STUDEN ROSTER"
response=$(get /courses/1/roster)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: Roster retrieved\n"
fi

status "GETTING ALL ASSIGNMENTS IN A COURSE"
response=$(get /courses/1/assignments)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: Assignments retrieved\n"
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
    printf "SUCCESS: Assignment posted\n"
fi

status "GETTING AN ASSIGNMENT"
response=$(get /assignments/1)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: Assignment retrieved\n"
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
    printf "SUCCESS: Assignment updated\n"
fi

status "DELETING AN ASSIGNMENT"
response=$(delete /assignments/1)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: Assignment deleted\n"
fi

status "GETTING ALL SUBMISSIONS FOR AN ASSIGNMENT"
response=$(get /assignments/1/submissions)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: Submissions retrieved\n"
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
    printf "SUCCESS: Submission posted\n"
fi


