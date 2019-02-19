#!/bin/bash
. ./config.sh
. ./gameApi.sh
. ./lib.sh

declare -A myGuessTracker

if [ "$team" == "DEFAULT" ] || [ "$password" == "DEFAULT" ];
then
    echo "Set team name and password"
    exit 1
fi

echo "=============="
echo " Game Started "
echo "=============="
echo "---------------------- "
echo "I am playing as $team"
echo "---------------------- "

gameStatusRecieved()
{
    data=$1
    gameId=`<<< $data jq '.gameId' | sed 's/"//g'`
    roundId=`<<< $data jq '.roundId'`
    secretLength=`<<< $data jq '.secretLength'`
    participants=`<<< $data jq '.participants'`
    state=`<<< $data jq '.state' | sed 's/"//g'`
    num_participants=`<<< $participants jq length`
    key="$gameId-$roundId"
    haveIJoined=""
    amIalive=""
    teamname="${team^^}"
    if [ $num_participants = 0 ] ;
    then
        echo "No participants"
    else
        i=0
        while [ $i -lt $num_participants ]
        do
            query=".[$i]"
            participant=`<<< $participants jq $query`
            name=`<<< $participant jq '.name' | sed 's/"//g'`
            isAlive=`<<< $participant jq '.isAlive'`
            if [ $name = $teamname ];
            then
                haveIJoined="true"
                amIalive="$isAlive"
            fi
            let i+=1
        done
    fi

    if [ "$state" = "joining" ];
    then
        if [ $haveIJoined ];
        then
            echo "Already Joined, waiting to play..."
        else
            response="$(joinGame)"
            status=`status_code "$response"`
            responseData=`response "$response"`
            err="$(err "$responseData")"
            data=`data "$responseData"`
            if [ "$(<<< $err awk '{print substr($0, "null")}')" == 0 ]
            then
                echo "Join Failed" $status $err
            else
                echo "Join Successful"
            fi
        fi

    elif [ "$state" = "running" ];
    then
        echo " "

    elif [ "$state" = "finished" ];
    then
        echo "Round $roundId is finished. Wait until next round begins."
        
    fi
}

while [ 1 == 1 ]
do
    response="$(getGameStatus)"
    status=`status_code "$response"`
    if [ $status -ge 200 ] && [ $status -lt 300 ];
    then
        responseData=`response "$response"`
        err="$(err "$responseData")"
        data=`data "$responseData"`
        if [ "$(<<< $err awk '{print substr($0, "null")}')" == 0 ]
        then
            echo "Get Game Status Failed" $status $err
        else
            gameStatusRecieved "$data"
        fi
    else
        echo "Get Game Status Failed"
    fi
    sleep 5s
done
