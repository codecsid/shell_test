#!/bin/bash
. ./config.sh
. ./gameApi.sh
. ./lib.sh
. ./mySmartAlgo.sh

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
    participants="$(<<< $data jq '.participants' | sed 's/ //g')"
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
            i=`expr $i + 1`
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
        if [ $haveIJoined ];
        then
            if [ "$amIalive" = "true" ];
            then
                declare -A aliveParticipants
                i=0
                j=0
                while [ $i -lt $num_participants ];
                do
                    query=".[$i]"
                    participant=`<<< $participants jq $query`
                    name=`<<< $participant jq '.name' | sed 's/"//g'`
                    isAlive=`<<< $participant jq '.isAlive'`
                    if [ $name != $teamname ] && [ $isAlive = "true" ];
                    then
                        aliveParticipants[$j]=$participant
                        j=`expr $j + 1`
                    fi
                    i=`expr $i + 1`
                done

                totalParticipants=$j
                mynextGuess="$(nextGuess $gameId $roundId $secretLength $totalParticipants "$aliveParticipants")"
                guesses=`<<< $mynextGuess jq '.guesses'`
                num_guesses=`<<< $guesses jq length`

                if [ $num_guesses -gt 0 ];
                then
                    echo "My Guess: $mynextGuess"
                    response=`guess $mynextGuess`
                    status=`status_code "$response"`
                    if [ $status -ge 200 ] && [ $status -lt 300 ];
                    then
                        responseData=`response "$response"`
                        err="$(err "$responseData")"
                        data=`data "$responseData"`
                        if [ "$(<<< $err awk '{print substr($0, "null")}')" == 0 ]
                        then
                            echo "Guess Failed" $status $err
                        else
                            totalScore=0
                            guesses=`<<< $data jq '.guesses'`
                            num_guesses=`<<< $data jq length`
                            i=0
                            while [ $i -lt $num_guesses ];
                            do
                                query=".[$i]"
                                guess=`<<< $guesses jq $query`
                                score=`<<< $guess jq '.score'`
                                totalScore=`expr $totalScore + $score`
                                i=`expr $i + 1`
                            done
                            echo "Guess Successful : Score $totalScore"
                            echo "Result : $responseData"

                            guessKey="$gameId-$roundId"
                            myGuessTracker[$guessKey]=$data
                        fi
                    else
                        echo "Guess Failed"
                    fi
                fi
            else
                echo "I am dead, waiting to respawn in next round ..... :("
            fi
        else
            echo "Oho, I have missed the joining phase, let me wait till the next round starts."
        fi

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
