#!/bin/bash
while IFS= read -r algo
do
    for i in {1..20}
    do
        openssl dgst -$algo -out ulaz-otisak.txt ulazi/ulaz$i.txt
        VAR1=$(cat ulaz-otisak.txt)
        VAR2=$(cat otisak.txt)
        rm ulaz-otisak.txt
        if [[ "$VAR1" =~ "$VAR2" ]]
        then
            echo -n "Solution is ulaz$i.txt ($algo) file with pa Myszkowski password '" && cat ulazi/ulaz$i.txt && echo "'"
            break 2
        fi
    done
done < dgst.algos
