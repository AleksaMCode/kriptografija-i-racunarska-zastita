#!/bin/bash
mkdir izlazi && mv *.crypt izlazi/
#otisak.hash je base64 kodovana datoteka.
mv otisak.hash otisak.base64
openssl enc -d -base64 -in otisak.base64 -out otisak.hash
#Napravimo listu sha algoritama.
openssl list --digest-commands | tr -s " " "\n" | grep -E "^sha[0-9]+" > sha.list
for i in {1..100}; do while IFS= read -r sha; do openssl dgst -$sha -out otisak$i.txt izlazi/izlaz$i.crypt; if [[ "$(cat otisak$i.txt)" =~ "6d34d42a467d80499606fbeaea7427869053e9640277bf4b9435c26c" ]]; then echo "MATCH: izlaz$i.crypt"; mv izlazi/izlaz$i.crypt .; rm otisak$i.txt; break 2; fi; rm otisak$i.txt; done < sha.list; done
#Dobili smo kao rjesenje: "MATCH: izlaz71.crypt".
#Sada je samo ostalo da dekriptujemo datoteku.
openssl aes-256-cbc -d -in izlaz71.crypt -out ulaz71.txt -k sigurnost -md md5
#Dobijena datoteka ima sadrzaj: "Ulazna datoteka za prvi zadatak_"
