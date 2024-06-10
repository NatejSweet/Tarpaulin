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

response=$(curl -X POST -H "Content-Type: application/json" -d "$login" $url/users/login)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
    TOKEN=$(echo $response | jq -r '.token')
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
    "email": "new3@user.com",
    "password": "hunter2sadffff",
    "role": "admin"
}'

status "POSTING A USER"
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$url/users" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$user")
if [  $response -eq 201 ]; then
    printf "SUCCESS: $response\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi

status "GETTING ALL USERS"
response=$(get /users)

if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
    uid=$(echo $response | jq -r '.[0].id')
fi

status "GETTING A USER"
response=$(get /users/$uid)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi


status "GETTING ALL COURSES"
response=$(get /courses)
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
    printf "SUCCESS: $response\n"
fi

status "GETTING A COURSE"
response=$(get /courses/$cid)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "UPDATING A COURSE"
course='{
    "name": "updated course",
    "description": "updated course description"
}'
response=$(put "$course" /courses/$cid)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "DELETING A COURSE"
response=$(delete /courses/$cid)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "GETTING ALL STUDENTS IN A COURSE"
response=$(get /courses/$cid/students)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "POSTING AN UPDATE TO A COURSE'S ENROLLMENT"
status "FIX MEEEEEEE"

status "GETTING STUDEN ROSTER"
response=$(get /courses/$cid/students)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $reponse\n"
fi

status "GETTING ALL ASSIGNMENTS IN A COURSE"
response=$(get /courses/$cid/assignments)
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
response=$(post "$assignment" /courses/$cid/assignments)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "GETTING AN ASSIGNMENT"
response=$(get /assignments/$aid)
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
response=$(put "$assignment" /assignments/$aid)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "DELETING AN ASSIGNMENT"
response=$(delete /assignments/$aid)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "GETTING ALL SUBMISSIONS FOR AN ASSIGNMENT"
response=$(get /assignments/$aid/submissions)
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
response=$(post "$submission" /assignments/$aid/submissions)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi


