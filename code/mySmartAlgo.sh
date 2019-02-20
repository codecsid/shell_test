nextGuess()
{
    gameId=$1
    roundId=$2
    secretLength=$3
    participants=$4
    myGuessTracker=$5

    num_participants=`<<< $participants jq length`

    myGuesses="{\"guesses\":["

    declare -A aliveParticipants

    echo $team

    if [ $num_participants == 0 ]; then
        echo "$myGuesses]}"
    else
        i=0
        j=0
        while [ $i -lt $num_participants ];
        do
            query=".[$i]"
            participant=`<<< $participants jq $query`
            name=`<<< $participant jq '.name' | sed 's/"//g'`
            isAlive=`<<< $participant jq '.isAlive'`
            if [ $name -ne $teamname ] && [ $isAlive = "true" ];
            then
                aliveParticipants[$j]=$participant
                echo ${aliveParticipants[$j]}
                j=`expr $j + 1`
            fi
            i=`expr $i + 1`
        done

        totalParticipants=$j

        if [ $totalParticipants -gt 0 ];
        then
            i=0
            while [ $i -lt 5 ];
            do
                randomInt=`shuf -i 0-$totalParticipants -n 1`
                secretRange=`dc -e "10 $(expr $secretLength - 1) ^ p"`
                secret=`shuf -i $secretRange-$(expr $secretRange \* 10 - 1) -n 1`
                name=`<<< ${aliveParticipants[$randomInt]} jq '.name'`
                guess="{\"name\":$name,\"guess\":\"$secret\"}"
                myGuesses=$myGuesses$guess
            done
            myGuesses="$myGuesses]}"
            echo $myGuesses
        else
            echo "$myGuesses]}"
        fi
    fi
}
