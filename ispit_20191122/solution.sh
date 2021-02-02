#!/bin/bash
mkdir keys && mv *.key keys/
#Izvucimo klijentski sertifikat iz .p12 datoteke.
openssl pkcs12 -in cert.p12 -nocerts -out private.enc -passin pass:sigurnost -passout pass:sigurnost
openssl rsa -in private.enc -out private.pem -passin pass:sigurnost
#Kljucevi su u der formatu pa ih prebacujemo u pem.
for i in {1..100}; do openssl rsa -in keys/kljuc$i.key -inform der -out keys/key$i.pem -outform pem && rm keys/kljuc$i.key; done 2>/dev/null
#Uporedimo kljuceve.
for i in {1..100}; do if [[ "$(diff keys/key$i.pem private.pem)" == "" ]]; then echo "MATCH: key$i"; break; fi; done 2>/dev/null
#Dobijamo "MATCH: key80".
