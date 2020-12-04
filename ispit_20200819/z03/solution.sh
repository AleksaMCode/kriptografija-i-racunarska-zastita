#!/bin/bash
mkdir lozinke && mv lozinka*.txt lozinke/
#Sifrat izgleda kao da je base64 kodovan. Dekodujmo ga prvo.
mv sifrat.txt sifrat.base64
openssl enc -d -base64 -in sifrat.base64 -out sifrat.txt
#Vidimo da je sifrat kriptovan i da imas Salt.

#"Skupimo" sve aes algortime koji postoje u openssl-u.
openssl enc -ciphers | sed "1d" | tr -s " " "\n" | cut -c2- | grep -E "^aes" > aes.algos
#Napisimo skriptu koja ce koristeci sve algoritme i sve kljuceve tri puta da dekriptuje sifra.txt datoteku, a zatim ce da ispise njihov sadrzaj kao i algoritam i kljuc koji je taja sadrzaj kreirao. Rjesenje cemo prepoznati jer datoteka koja je dekriptovana uspjesno ima smislen sadrzaj.
touch script.sh && chmod 777 script.sh
./script.sh 2>/dev/null
#Dobijemo sljedeci ispis: "aes-256-cbc + lozinka22 -> Bravooooo ;)".
#Zakljucak: koristen je kljuc "lozinka22" iz lozinka22.txt datoteke, a sadrzaj ulazne datoteke je "Bravooooo ;)" koji se nalazi unutar datoteke ulaz.txt
