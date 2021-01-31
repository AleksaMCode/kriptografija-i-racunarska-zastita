#!/bin/bash
mkdir keys/ && mv *.key keys/
#Svi kljucevi su u DER formatu.
for i in {1..100}; do openssl rsa -in keys/kljuc$i.key -inform der -out keys/kljuc$i.pem -outform pem && rm keys/kljuc$i.key; done
#Izdvojimo privatni kljuc iz cert.p12 datoteke.
openssl pkcs12 -in cert.p12 -nocerts -out private.key -passin pass:sigurnost -passout pass:sigurnost
#Dobili smo enkriptovan rsa private key. Dekriptujmo ga prije poredjenja.
openssl rsa -in private.key -out private.pem -passin pass:sigurnost
#Pronadjimo match.
for i in {1..100}; do if [[ "$(diff keys/kljuc$i.pem private.pem | awk 'NR==1')" == "" ]]; then echo "MATCH: key$i" && break; fi; done
#Dobijamo: "MATCH: key58"
