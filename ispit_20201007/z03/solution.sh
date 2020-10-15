#!/bin/bash
mkdir pkcs12/ && mv *.p12 pkcs12
mkdir ulazi
#Napisimo skriptu za dekripciju datoteke. Dekripcija se radi privatnim kljucevima.
touch script.sh && chmod 777 script.sh
./script.sh
#Pogledajmo koja je to datoteka.
find ulazi/ -type f -size +1c
#Dobijamo: "ulazi/ulaz45.key"
#Ispisimo sadrzaj.
cat ulazi/ulaz45.key #Dobijamo "Ajmo sad četvrti :)." kao sadraj. Jasno je da je ovo dobijeno kljucem iz 45 pkcs12 datoteke.
