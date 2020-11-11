#!/bin/bash
mkdir keys && mv *.key keys
#Svi kljucevi su base64 kodovani.
for i in {1..100}; do openssl enc -d -base64 -in keys/kljuc$i.key -out keys/kljuc$i.der && rm keys/kljuc$i.key; done
#Svu kjucevi su u DER formatu! Konvertujmo ih u PEM format (ovaj korak nije potreban).
for i in {1..100}; do openssl rsa -in keys/kljuc$i.der -inform der -out keys/kljuc$i.pem -outform pem && rm keys/kljuc$i.der; done
#Izdvojimo klijentski sertifikat iz cert.p12 datoteke.
openssl pkcs12 -in cert.p12 -nokeys -clcerts -out client.pem -passin pass:sigurnost
#Izdvojimo javni kljuc iz client.pem.
openssl x509 -in client.pem -pubkey -noout > public.pem
#Izdvojimo javne kljuceve iz 100 privatnih RSA kljuceva.
for i in {1..100}; do openssl rsa -in keys/kljuc$i.pem -pubout -out keys/public$i.pem; done
#Napisimo skriptu za poredjenje.
touch script.sh && chmod +x script.sh
./script.sh
#Dobijamo: "Match found: kljuc66.key"
