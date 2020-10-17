#!/bin/bash
#kljuc.txt je base64 kodovan, pa ga prvo dekodujemo.
mv kljuc.txt kljuc.base64
openssl enc -d -base64 -in kljuc.txt -out kljuc.dec
#Takodje, sifra.txt je u base64 formatu kodovan.
openssl enc -d -base64 -in sifrat.txt -out sifra.dec #Vidimo da sifrat ima salt kada ga procitamo.

#Nakon provjere citanjem vidimo da je kljuc z04/client.key u DER formatu.
#"Kopirajmo" PEM format datog kljuca u folder 3. zadatka.
openssl rsa -in ../z05/client.key -inform DER -out client.key -outform PEM
#Sada trebamo dekriptovati kljuc.dec koristeci privatni kljuc client.key.
openssl rsautl -decrypt -in kljuc.dec -out kljuc.txt -inkey client.key
cat kljuc.txt #Ispisuje se "neporecivost". Znaci, za kriptovanje se koristi kljuc "neporecivost".

#Napravimo listu RC algoritama iz openssl-a.
openssl enc -ciphers | sed "1d" | tr -s " " "\n" | cut -c2- | grep -E "^rc*" > rc.list
#Napisimo skriptu koja ce da dekriptuje sifra.txt sa svim RC algoritmima koristeci isti kljuc, kljuc neporecivost.
touch script.sh && chmod 777 script.sh
mkdir ulaz
 ./script.sh 2>/dev/null
#Dobijemo da je odgovarajuci algoritam rc4-40 sa kojim dobijemo ulaznu datoteku sa sadrzajem "Rijesili ste zagonetku!"

