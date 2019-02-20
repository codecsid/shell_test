nextGuess()
{
    gameId=$1
    roundId=$2
    secretLength=$3
    totalParticipants=$4
    aliveParticipants=$5
    maxGuess=5

    myGuesses="{\"guesses\":["

    if [ $totalParticipants -gt 0 ];
    then
        i=0
        while [ $i -lt $maxGuess ];
        do
            randomInt=`shuf -i 0-$(expr $totalParticipants - 1) -n 1`
            secretRange=`dc -e "10 $(expr $secretLength - 1) ^ p"`
            secret=`shuf -i $secretRange-$(expr $secretRange \* 10 - 1) -n 1`
            name=`<<< ${aliveParticipants[$randomInt]} jq '.name'`
            guess="{\"name\":$name,\"guess\":\"$secret\"}"
            if [ $i != $(expr $maxGuess - 1) ];
            then
                guess="$guess,"
            fi
            myGuesses=$myGuesses$guess
            i=`expr $i + 1`
        done
        myGuesses="$myGuesses]}"
        echo $myGuesses
    else
        echo "$myGuesses]}"
    fi
}
