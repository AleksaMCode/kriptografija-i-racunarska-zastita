#!/bin/bash
mkdir keys && mv *.key keys/
mkdir tasks && mv tekst* tasks/
#Potpis je base64 kodovan. Dekodujmo ga.
mv potpis.txt potpis.base64
#Kljuceva ima razlicitih, javnih, privatnih, RSA, DSA, u PEM i u DER formatu. Potrebno ih je razvrstati.
mkdir keys/{public,privateRSA,privateDSA}
for i in {1..8}; do firstLine=$(cat keys/kljuc$i.key | awk 'NR==1'); if [[ "$firstLine" =~ "RSA" ]]; then mv keys/kljuc$i.key keys/privateRSA/; elif [[ "$firstLine" =~ "DSA" ]]; then mv keys/kljuc$i.key keys/privateDSA/; elif [[ "$firstLine" =~ "PUBLIC" ]]; then mv keys/kljuc$i.key keys/public/; fi; done
#Uspjesno je izvrseno razdvajanje. Ostala su dva kljuca, kljuc4 i kljuc5. Oni su u DER formatu, pa cemo ih rucno provjeriti i razvrstati.
openssl rsa -in keys/kljuc4.key -inform der -noout -text
#Komanda iznad nije prosla, sto znaci da je rijec o DSA kljucu.
openssl dsa -in keys/kljuc4.key -inform der -noout -text #Kljuc4 je DSA u DER formatu.
openssl rsa -in keys/kljuc5.key -inform der -noout -text #Kljuc5 je RSA u DER formatu.

#Izdvojimo iz svih privatnih kljuceva javni, jer cemo javni kljuc koristiti za validaciju potpisa koji nam je dat.
#Premenujmo kljuc1.key u public1.key jer je on javan kljuc.
for i in {3..7..4}; do openssl rsa -in keys/privateRSA/kljuc$i.key -pubout -out keys/public/public$i.key; done
for i in {2..8..2}; do openssl dsa -in keys/privateDSA/kljuc$i.key -pubout -out keys/public/public$i.key; done 2>/dev/null
openssl rsa -in keys/kljuc5.key -inform der -pubout -out keys/public/public5.key
openssl dsa -in keys/kljuc4.key -inform der -pubout -out keys/public/public4.key

#Napisimo skriptu koja provjerava potpis i tekst*.txt datoteke koristeci sve moguce hash algoritme.
openssl list --digest-commands | tr -s " " "\n" > hash.algos
touch script.sh && chmod +x script.sh
./script.sh
