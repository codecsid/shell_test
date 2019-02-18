#!/bin/bash
curl -is "localhost:3000" > tmp
status=`awk '/^H/{print $2}' tmp`
response=`awk '/^{/' tmp`
err=`echo $response | jq '.err'`
data=`echo $response | jq '.data'`

if [ "$err" != "null" ]; then
    echo "$err"
fi

gameId=`echo $data | jq '.gameId'`
roundId=`echo $data | jq '.roundId'`
participants=`echo $data | jq '.participants'`
num_participants=`echo $participants | jq length`

declare -A participantArray

if [ $num_participants == 0 ]; then
    echo "No participants"
else
    i=0
    while [ "$i" -lt "$num_participants" ];
    do
        query=".[$i]"
        participant=`echo $participants | jq $query`
        participantArray[$i]=$participant
        echo ${participantArray[$i]}
        let i+=1
    done
fi
