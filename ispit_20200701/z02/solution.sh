#!/bin/bash
#Dekodujmo prov otisci.txt.
mv otisci.txt otisci.base64
openssl enc -d -base64 -in otisci.base64 -out otisci.txt
#Dekodujmo izlaz.txt
mv izlaz.txt izlaz.base64
openssl enc -d -base64 -in izlaz.base64 -out izlaz.txt
#Dobili smo datoteku koja je enkriptovana i ima Salt.
#Napravimo listu simetricnih algoritama.
openssl enc -ciphers | sed "1d" | tr -s " " "\n" | cut -c2- > symmetric.algos
#Napravimo skriptu koja ce da kreira date otiske i da ih provjerava.
touch script.sh && chmod 777 script.sh
./script.sh 2>/dev/null > algoritam-otisak.list
#Unutar algoritam-otisak.list datoteke se nalazi kojem algoritmu pripada koji otisak. A unutar decription-algos.list imamo listu algoritama koji su potencijalni kandidati za dekripciju.
#Napisimo jos jednu skripti.
touch script-decipher.sh && chmod 777 script-decipher.sh
./script-decipher.sh 2>/dev/null
#Kao rezultat dobijamo "camellia-128-ecb + izlaz.txt 3x times = Svaka cast!". Znaci sadrzaj je "Svaka cast!".
