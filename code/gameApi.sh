apiJoin="$baseApi/api/ninja/join"
apiStatus="$baseApi/api/ninja/gamestatus"
apiGuess="$baseApi/api/ninja/guess"

joinGame()
{
    response=$(curl -is -X POST --user "$team:$password" $apiJoin | sed 's/\n//g')
    echo $response
}

getGameStatus()
{
    response=$(curl -is $apiStatus | sed 's/\n//g')
    echo $response
}

guess()
{
    data=$1
    header="Content-Type: application/json"
    response=$(curl -is -X POST --user "$team:$password" -H $header -d $data $apiJoin | sed 's/\n//g')
    echo $response
}
