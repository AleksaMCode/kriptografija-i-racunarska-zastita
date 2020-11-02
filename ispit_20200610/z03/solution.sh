#!/bin/bash
mkdir ulaz && mv ulaz*.txt ulaz/
#Otisak je base64 kodovan pa ga je potrebno prvo dekodovati.
mv otisak.txt otisak.base64
openssl enc -d -base64 -in otisak.base64 -out otisak.txt
#Izdvojimo sve destupne hash algoritme u listu.
openssl list --digest-commands | tr -s " " "\n" > hash_algos.list
#Kreirajmo skriptu koja ce kreirati otiske i raditi poredjenja sa datim otiskom.
touch script.sh && chmod +x script.sh
./script.sh
#Dobijamo: Match found: ulaz25.txt + sha384 = otisak.txt
#Zakljucak: Koristena je datoteka ulaz25.txt sa sha384 algoritmom da se dobije trazeni otisak.
