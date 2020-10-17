#!/bin/bash
mkdir ulaz ; mv ulaz*.txt ulaz
#Otisak je u base64 formatu, pa ga je potrebno dekodovati.
openssl enc -d -base64 -in otisak.txt -out otisak.dec

#Napisimo skriptu koja ce da kreira i ujedno provjera otiske sa otisak.txt datotekom.
touch script.sh && chmod 777 script.sh
#Kljuc je LAPTOP.
#Ostatak rjesenja je unutar myszkowski.xlsx
