#!/bin/bash
for i in {1..30}
do
    for j in {1..3}
    do
        if [[ "$(openssl dgst -sha256 -verify public.pem -signature potpisi/potpis$j.txt lozinke/lozinka$i.txt)" =~ "OK" ]]
        then 
            echo "Match found: KEY $i <-> Signature $j -> key for decription is lozinka$i"
            break
        fi
    done
done
