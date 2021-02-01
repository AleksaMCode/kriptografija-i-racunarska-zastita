#!/bin/bash
mkdir ulazi && mv ulaz*.txt ulazi/
#Dekodujmo otisak.hash iz base64 formata.
openssl enc -d -base64 -in otisak.hash -out otisak.txt
#Napravimo listu svih algoritama koji se mogu koristiti sa dgst komandom u openssl-u.
openssl list --digest-commands | tr -s " " "\n" > dgst.algos
#Kreirajmo skriptu koja ce da kreirao otisak i da ga provjerava sa datim otiskom.
touch script.sh && chmod 777 script.sh
./script.sh 2>/dev/null
#Dobijamo : "Solution is ulaz15.txt (sha512) file with pa Myszkowski password 'NEPRIKLADNO'".
#Sada radimo drugi dio zadatka, dekpripciju sa Myszkowski Cipher Algoritmom, koristeci kljuc NEPRIKLADNO. Rjesenje je u excel datoteci.
