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
    "email": "new2@user.com",
    "password": "hunter2sadffff",
    "role": "student"
}'
status "POSTING A USER"
response=$(curl -s -w "\n%{http_code}" -X POST "$url/users" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$user")
responseCode=$(echo "$response" | tail -n1)
responseBody=$(echo "$response" | head -n-1)
if [ $responseCode -eq 201 ]; then
    printf "SUCCESS: $responseCode\n"
else
    printf "FAILURE: $responseCode\n"
    # exit 1
fi
userId=$(echo $responseBody | jq -r '._id')
newLogin='{
        "email": "new2@user.com",
        "password": "hunter2sadffff"
        }'
status "LOGGING IN AS NEW USER"
response=$(curl -X POST -H "Content-Type: application/json" -d "$newLogin" $url/users/login)
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
    TOKEN=$(echo $response | jq -r '.token')
fi
printf "$userId\n"
status "GETTING NEW USER"
response=$(curl -s -X GET "$url/users/$userId" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN") 
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
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

status "GETTING INSTRUCTOR"
response=$(curl -s -X GET "$url/users/1" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

status "LOGGING IN AS STUDENT"
login='{
    "email": "example3@example.com",
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

status "GETTING STUDENT"
response=$(curl -s -X GET "$url/users/2" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN")
if [ -z "$response" ]; then
    printf "FAILURE: Empty response\n"
    exit 1
else
    printf "SUCCESS: $response\n"
fi

