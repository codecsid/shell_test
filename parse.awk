BEGIN{FS=":"}
{
    getline < text
    response = $0
    i = index(response, ":")
    ns = substr(response, i+1)
}
{
    FS =","
}{
    getline s < response
    print s
}
