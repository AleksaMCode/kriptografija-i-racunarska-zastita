#!/bin/bash
mkdir otisci && mv otisak* otisci/
#Preminujmo nazive datoteka iz npr. otisak01.txt u otisak1.txt
for i in {1..9}; do mv otisci/otisak0$i.txt otisci/otisak$i.txt; done
#Svi otisci su base64 kodovani. Dekodujmo ih.
for i in {1..11}; do mv otisci/otisak$i.txt otisci/otisak$i.base64; done
for i in {1..11}; do openssl enc -d -base64 -in otisci/otisak$i.base64 -out otisci/otisak$i.txt; done
#Dohvatimo sve algortime za hash-iranje.
openssl list --digest-commands | tr -s " " "\n" > algos.list
#Napisimo skriptu za provjeru.
touch script.sh && chmod +x script.sh
./script.sh 2>/dev/null
#Dobijamo: "MATCH: sha384 + ulaz.txt = otisak7.txt"
