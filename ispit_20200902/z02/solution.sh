#!/bin/bash
mkdir ulaz && mv ulaz*.txt ulaz/
#Otisak treba dekodovati iz base64 formata.
openssl enc -d -base64 -in otisak.txt -out otisak.dec
#Izvodjimo nazive sha algoritama u datoteku sha.algos
openssl list --digest-commands | tr -s " " "\n" | grep -E "sha[0-9]+" > sha.algos
#Pronadjimo ulaz*.txt datoteku koja ima hash isti kao hash u otisak.dec. Napravimo skriptu.
touch script.sh && chmod 777 script.sh
./script.sh
#Dobijmamo ispis "Solution is ulaz.5.txt with sha384 algorithm". Znaci nasi parametri su unutar ulaz5.txt datoteke.
#Ostatak zadatka se radi na papiru.
