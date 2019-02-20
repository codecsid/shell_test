#!/bin/bash
a="123"
b="123"
if [ $a = $b ];
then
    c=5
    echo "equal"
else
    echo "not equal"
fi
t=$c
echo $c
totalParticipants=10
i=0
secretLength=4
while [ $i -lt 4 ];
do
    randomInt=`shuf -i 0-$totalParticipants -n 1`
    secretRange=`dc -e "10 $(expr $secretLength - 1) ^ p"`
    secret=`shuf -i $secretRange-$(expr $secretRange \* 10 - 1) -n 1`
    name="\"TEAM\""
    guess="{\"name\":$name,\"guess\":\"$secret\"}"
    echo $guess
    i=`expr $i + 1`
done

a="hello"
b="world"
a="$a]}"
echo $a
status="300"
if [ $status -gt 200 ];
then
    echo "true"
fi

declare -A fullNames
fullNames=( ["lhunath"]="Maarten Billemont" ["greycat"]="Greg Wooledge" )

for user in "${!fullNames[@]}"
do
    echo "User: $user, fullname: ${fullNames[$user]}."
done
