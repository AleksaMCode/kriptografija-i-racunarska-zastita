#!/bin/bash
for i in {1..150}
do
    for j in {0..5} # za jks kljuceve
    do
        if [[ "$(diff keys/public/public$i.pem store_keys/jks_key$j.pem)" == "" ]]
        then
            for k in {0..5}
            do
                if [[ "$(diff keys/public/public$i.pem store_keys/p12_key$k.pem)" == "" ]]
                then
                    echo "MATCH: key$i.key - s$j from JKS & s$k from PKCS12"
                    break 3
                fi
            done
        fi
    done
done
