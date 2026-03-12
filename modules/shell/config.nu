# tere
def --wrapped --env tere [...args] : {
    let result = ( ^tere ...$args )
    if $result != "" {
        cd $result
    }
}
