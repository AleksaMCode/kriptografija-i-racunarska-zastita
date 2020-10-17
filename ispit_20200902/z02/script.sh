#!/bin/bash
while IFS= read -r sha
do
    for i in {1..10}
    do
        openssl dgst -$sha -out otisak-temp.txt ulaz/ulaz$i.txt
        OTISAK=$(cat otisak-temp.txt)
        if [[ "$OTISAK" =~ "88c84e5e8c8dd603d638109f0a7ab61381e3cb1bcd080895cf65cdfae64dac3260e2ed77c4b9f317d52978280cd433c6" ]]
        then
            echo "Solution is ulaz.$i.txt with $sha algorithm"
            break
        fi
    done
done < sha.algos
rm otisak-temp.txt
