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
    TOKEN=$( echo $responseBody | jq -r '.token')
else
    printf "ADMIN FAILED TO LOG IN: $responseCode\n"
    exit 1
fi
printf "POSTING A NEW INSTRUCTOR\n"
user='{
    "name": "new user",
    "email": "newInst@user.com",
    "password": "thenewguy",
    "role": "instructor"
}'
response=$(curl -s -w "\n%{http_code}" -X POST "$url/users" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$user")
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
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$course" "$url/courses" -H "Authorization: Bearer $TOKEN")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 201 ]; then 
    instructorCourseId=$(echo $responseBody | jq -r '._id')
else
    printf "COURSE NOT POSTED: $responseCode\n"
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
    TOKEN=$(echo $response | jq -r '.token')
fi

status "GETTING ALL COURSES"
response=$(curl -s -w "\n%{http_code}" -X GET "$url/courses" -H "Authorization: Bearer $TOKEN")
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
response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN"  -d "$course" "$url/courses" )
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
response=$(curl -s -w "\n%{http_code}" -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$course" "$url/courses/$courseId")
responseCode=$(echo "$response" | tail -n1)
if [ $responseCode -eq 403 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    exit 1
fi



status "LOGGING IN AS NEW INSTRUCTOR"
login='{
    "email": "newInst@user.com",
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


