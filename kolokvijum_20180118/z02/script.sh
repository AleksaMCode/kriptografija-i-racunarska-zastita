#!/bin/bash
for i in {1..100}
do    
    for j in {1..100}
    do
        VERIFY=$(openssl dgst -sha1 -verify keys/public$i.pem -signature signature.bin ulazi/ulaz$j.txt)
        echo "$VERIFY"
        if [[ "$VERIFY" =~ "OK" ]]
        then
            echo "MATCH: store$i.jks"
            break 2
        fi
    done
done

