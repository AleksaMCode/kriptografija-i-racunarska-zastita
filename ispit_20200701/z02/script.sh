#!/bin/bash
OTISCI=$(cat otisci.txt)
while IFS= read -r algo
do
    OTISAK=$(openssl passwd -salt lozinka -1 $algo)
    if [[ "$OTISCI" =~ "$OTISAK" ]]
    then
        echo "Match found: $algo password with algo -1 & salt 'lozinka' -> $OTISAK" && echo $algo >> decription-algos.list
    fi

    OTISAK=$(openssl passwd -salt 12 $algo)
    if [[ "$OTISCI" =~ "$OTISAK" ]]
    then
        echo "Match found: $algo password with algo -crypt & salt '12' -> $OTISAK" && echo $algo >> decription-algos.list
    fi
    
    OTISAK=$(openssl passwd -salt 123456 -1 $algo)
    if [[ "$OTISCI" =~ "$OTISAK" ]]
    then
        echo "Match found: $algo password with algo -1 & salt '123456' -> $OTISAK"  && echo $algo >> decription-algos.list
    fi
    
    OTISAK=$(openssl passwd -salt xy $algo)
    if [[ "$OTISCI" =~ "$OTISAK" ]]
    then
        echo "Match found: $algo password with algo -crypt & salt 'xy' -> $OTISAK" && echo $algo >> decription-algos.list
    fi

    OTISAK=$(openssl passwd -salt abcdefgh -1 $algo)
    if [[ "$OTISCI" =~ "$OTISAK" ]]
    then
        echo "Match found: $algo password with algo -1 & salt 'abcdefgh' -> $OTISAK" && echo $algo >> decription-algos.list
    fi

    OTISAK=$(openssl passwd -salt ab $algo)
    if [[ "$OTISCI" =~ "$OTISAK" ]]
    then
        echo "Match found: $algo password with algo -crypt & salt 'ab' -> $OTISAK" && echo $algo >> decription-algos.list
    fi
done < symmetric.algos
