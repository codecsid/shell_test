status_code()
{
    code=`<<< $1 awk '{size=split($0, array, " "); print array[2];}'`
    echo $code
}

response()
{
    responseData=`<<< $1 awk '{i=index($0, "{"); refinedString=substr($0, i); print refinedString}'`
    echo $responseData
}

err()
{
    echo $(<<< $1 jq '.err')
}

data()
{
    echo $(<<< $1 jq '.data')
}
