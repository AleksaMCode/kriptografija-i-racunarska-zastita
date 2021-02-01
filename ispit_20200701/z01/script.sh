#!/bin/bash
while IFS= read -r algo
do
    for i in {1..20}
    do             
        if [[ "$(openssl dgst -$algo ulazi/ulaz$i.txt)" =~ "$(cat otisak.txt)" ]]
        then
            echo -n "Solution is ulaz$i.txt ($algo) file with pa Myszkowski password '" && cat ulazi/ulaz$i.txt && echo "'"
            break 2
        fi
    done
done < dgst.algos
