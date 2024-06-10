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
# put() {
#     curl -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$1" $url$2
# }
patch() {
    curl -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$1" $url$2
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
response=$(post "$user" /users)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    echo "did u try to run multiple times without clearing the database?"
    exit 1
else
    printf "SUCCESS: $response\n"
    uid=$(echo $response | jq -r '._id')
    printf "uid: $uid\n"
fi

status "GETTING ALL USERS"
response=$(get /users)

if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

echo $uid

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
    "subject": "CS",
    "number": "101",
    "title": "new course",
    "term": "Fall 2021",
    "instructorId": "'$uid'"
}'
response=$(post "$course" /courses)
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
    cid=$(echo $response | jq -r '.courses[0]._id')
fi

printf "cid: $cid\n"

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
    "subject": "CS",
    "number": "101",
    "title": "updated course",
    "term": "Fall 2021",
    "instructorId": "'$uid'"
}'

response=$(patch "$course" /courses/$cid)
if [ -z "$response" ]; then
    printf "SUCCESS: patch does not return anything\n"
else
    printf "FAILURE: $response\n"
    exit 1
fi


status "GETTING ALL STUDENTS IN A COURSE"
response=$(get /courses/$cid/students)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

printf "cid: $cid\n"
status "POSTING AN ASSIGNMENT"
assignment='{
    "courseId": "'$cid'",
    "title": "new assignment",
    "points": 100,
    "due": "2021-12-31"
}'

response=$(post "$assignment" /courses/$cid/assignments)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "GETTING ALL ASSIGNMENTS IN A COURSE"
response=$(get /courses/$cid/assignments)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
    aid=$(echo $response | jq -r '.assignments[0]._id')
fi

printf "aid: $aid\n"


status "DELETING A COURSE"
response=$(delete /courses/$cid)
if [ -z "$response" ]; then
    printf "SUCCESS: delete does not return anything\n"
else
    printf "FAILURE: $response\n"
    exit 1
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
response=$(patch "$assignment" /assignments/$aid)
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

# try to get the deleted assignment
status "GETTING A DELETED ASSIGNMENT"
response=$(get /assignments/$aid)
if [ -z "$response" ]; then
    printf "SUCCESS: Empty response\n"
else
    printf "FAILURE: $response\n"
    exit 1
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


