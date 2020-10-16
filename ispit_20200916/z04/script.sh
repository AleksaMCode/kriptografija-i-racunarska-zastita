#!/bin/bash
for i in {1..150} # for public keys from keys/public/
do
    for j in {0..6} # for p12 keys
    do
        DIFF=$(diff keystore-keys/p12-key-s$j.pem keys/public/key$i.pem | awk 'NR==1')
        if [ "$DIFF" == "" ]
        then
            for k in {0..6} # for jks keys
            do
                DIFF=$(diff keystore-keys/jks-key-s$k.pem keys/public/key$i.pem | awk 'NR==1')
                if [ "$DIFF" == "" ]
                then
                    echo "Winner is : key$i.key"
                    #break 3
                fi
            done
        fi
    done
done
