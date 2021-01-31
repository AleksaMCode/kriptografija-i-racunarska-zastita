#!/bin/bash
mkdir sifrati && mv sifrat*.txt sifrati/
#Poznat je enkripcioni algoritam: aes-192-cbc.

#Datoteke sifrati su base64 kodovani.
for i in {1..250}; do mv sifrati/sifrat$i.txt sifrati/sifrat$i.base64; openssl enc -d -base64 -in sifrati/sifrat$i.base64 -out sifrati/sifrat$i.txt; done; rm sifrati/*.base64
#Svi imaju salt.
#Napravimo listu sha algoritama.
openssl list --digest-commands | tr -s " " "\n" | grep -E "^sha[0-9]+" > sha.list

#Dekriptujmo sve sifrate i provjeravamo otiske.
mkdir ulazi
for i in {1..250}; do openssl aes-192-cbc -d -in sifrati/sifrat$i.txt -out ulazi/ulaz$i.txt -k sigurnost -md md5; done
#Kreirajmo sve potpise.
for i in {1..250}; do while IFS= read -r sha; do openssl dgst -$sha ulazi/ulaz$i.txt; done < sha.list; done 1>>otisci.txt
cat otisci.txt | grep 7f92432dc4ea8a2588393a861d410820f295822c4fbadecfcce76d40
#Dobijamo:
#SHA224(ulazi/ulaz124.txt)= 7f92432dc4ea8a2588393a861d410820f295822c4fbadecfcce76d40
#Sadrzaj datoteke ulaz124.txt smo dobili komandom:
cat ulazi/ulaz124.txt
#Sadrzaj: "Ulazni sadrzaj"
