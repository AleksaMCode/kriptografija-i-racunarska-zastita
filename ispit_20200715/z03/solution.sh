#!/bin/bash
mkdir lozinke && mv lozinka*.txt lozinke/
mkdir potpisi && mv potpis*.txt potpisi/
#sifrat.txt datoteka je base64 kodovana. Dekodujmo ju je.
mv sifra.txt sifrat.base64
openssl enc -d -base64 -in sifrat.base64 -out sifrat.txt
#sifrat.txt je enriptovana datoteka sa salt-om.

#Kreirajmo listu camellia algoritama.
openssl enc -ciphers | sed "1d" | tr -s " " "\n" | cut -c2- | grep -E "^camel" > camellia.algos
#Kakav je to host.key? Provjerimo. Kada ga otvorimo nista nije citljivo pa mozemo zakljuciti da je u DER formatu. Da li je RSA i DSA?
openssl rsa -in host.key -inform DER -noout -text
#RSA DER kljuc je u pitanju i to privatan kljuc. Nama za provjeru potpisa treba javan kljuc!
openssl rsa -in host.key -inform DER -pubout -out public.pem
#Koristimo public.pem za provjeru potpisa.
#Kreirajmo skriptu koja ce da pronadje odgovarajuci match za kljuc i potpis. 3 kljuca i 3 potpisa.
touch script-keyfind.sh && chmod 777 script-keyfind.sh
./script-keyfind.sh 
#Kao rezultat dobijamo:
#Match found: KEY 1 <-> Signature 2 -> key for decription is lozinka1
#Match found: KEY 17 <-> Signature 3 -> key for decription is lozinka17
#Match found: KEY 22 <-> Signature 1 -> key for decription is lozinka22
#Kljucevi se koriste redom: lozinka22, lozinka17 i lozinka1.

#Napisimo skriptu za dekripciju sifrat.txt datoteke. Pokusajmo sve moguce kombinacije.
touch script.sh && chmod 777 script.sh
./script.sh lozinka1 lozinka17 lozinka22 2>/dev/null # NISTA.
./script.sh lozinka1 lozinka22 lozinka17 2>/dev/null # NISTA.
./script.sh lozinka22 lozinka1 lozinka17 2>/dev/null # NISTA.
./script.sh lozinka22 lozinka17 lozinka1 2>/dev/null # NISTA.
./script.sh lozinka17 lozinka22 lozinka1 2>/dev/null # NISTA.
./script.sh lozinka17 lozinka1 lozinka22 2>/dev/null # Tacna kombinacija.
#Dobijemo:
#camellia-256-cbc with key combo lozinka17 + lozinka1 + lozinka22 -> Bravooooo ;)
#camellia256 with key combo lozinka17 + lozinka1 + lozinka22 -> Bravooooo ;)
#Dakle smislen sadrzaj je "Bravooooo ;)"
