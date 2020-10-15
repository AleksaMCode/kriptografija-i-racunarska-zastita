#!/bin/bash
while IFS= read -r aes
do
	openssl $aes -d -in sifrat.txt -out ulaz1.txt -k $1 -md md5
	openssl $aes -d -in ulaz1.txt -out ulaz2.txt -k $2 -md md5
	openssl $aes -d -in ulaz2.txt -out ulaz.txt -k $3 -md md5
	TEXT=$(cat ulaz.txt)
	rm ulaz*.txt
	if [ "$TEXT" != "" ]
	then
		echo "$aes + $1-$2-$3 -> $TEXT"
		break
	fi
done < aes.algos
