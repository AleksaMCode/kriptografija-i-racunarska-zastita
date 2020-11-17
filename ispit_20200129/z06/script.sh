#!/bin/bash
for i in {1..4} #for jks certs
do
    for j in {1..23}
    do
        if [ $j == 11 ]; then continue;
        elif [ $j == 13 ]; then continue; fi
        if [ "$(diff jks-certs/s$i.crt certs/cert$j.crt)" == "" ]
        then
            echo "MATCH: s$i.crt <-> cert$j.crt"
        fi
    done
done
