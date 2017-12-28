#!/bin/bash

CERT_PATH="${WORKSPACE}/fastlane/signing/certificates"
encrypt() {
    CERTS=($(ls))
    for i in ${CERTS[@]}; do 
        /usr/bin/openssl aes-256-cbc -k {{ password }} -in ${i} -salt -d -a -out "${i%.p12.enc}.p12"
    done
}

cd ${CERT_PATH} && encrypt
