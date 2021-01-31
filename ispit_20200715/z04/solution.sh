#!/bin/bash
mkdir {otisci,ulazi} && mv otisak*.txt otisci/ && mv ulaz*.txt ulazi
#Kreirajmo listu algotirama za kreiranje otisaka.
openssl list --digest-commands | tr -s " " "\n" > digest.list

#Otisci 2 i 3 su base64 kodovani. Dekodujmo ih.
for i in {2..3}; do mv otisci/otisak$i.txt otisci/otisak$i.base64; done
for i in {2..3}; do openssl enc -d -base64 -in otisci/otisak$i.base64 -out otisci/otisak$i.txt; done

#Kreirajmo skriptu koja provjera otiske.
touch script.sh && chmod 777 script.sh
./script.sh 2>/dev/null
#Rjesenje:
#ulaz21.txt + whirlpool = otisak1.txt
#ulaz13.txt + md5 = otisak2.txt
#ulaz44.txt + sha224 = otisak3.txt
#ulaz6.txt + sha512 = otisak4.txt
