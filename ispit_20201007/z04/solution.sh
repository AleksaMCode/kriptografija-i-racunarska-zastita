#!/bin/bash
mkdir ulazi/ && mv ulaz*.txt ulazi/
mkdir otisci/ && mv otisak* otisci.txt
#Otisci su base64 kodovani
for i in {1..9}; do mv otisci/otisak0$i.txt otisci/otisak$i.base64; done
mv otisci/otisak10.txt otisci/otisak10.base64
#'Izvadimo' sve hash algoritme.
openssl list --digest-commands | tr -s " " "\n" > dgst.algos #Ne radi na ovoj verziji openssl, rucno sam ih pronasao u help-u.
#Napisimo skriptu za provjeru otisaka.
touch script.sh && chmod 777 script.sh
./script.sh 2>/dev/null
#Dobijamo:
#ulaz41.txt + md4 = otisak8.txt
#ulaz22.txt + sha512 = otisak7.txt
