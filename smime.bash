#!/usr/bin/env bash

USAGE="$0 {encrypt/decrypt} {cert/pem/key file} {input file} {output file}"

function encrypt() {

    # 1 the location of the certificate
    # 2 the input file that will be encrypted
    # 3 the output file that will have the encrypted content flushed upon

    openssl smime -encrypt -binary -aes-256-cbc -outform DER -in "$2" -out "$3" "$1"

}

function decrypt() {

    # 1 the location of the private key
    # 2 the encrypted file that will be decrypted
    # 3 the location for the decrypted file

    openssl smime -decrypt -binary -inform DER -in "$2" -out "$3" -inkey "$1"

}

function main() {

    if [ "$#" -ne 4 ]; then
        echo "Illegal number of parameters"
        echo "$USAGE"
        exit
    fi

    "$1" "${@:2}"

}

# run the feckin main function
main "$@"
