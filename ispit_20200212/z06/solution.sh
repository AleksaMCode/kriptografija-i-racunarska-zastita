#!/bin/bash
mkdir keys && mv *.key keys/
#Svi kljucevi su privatni, RSA u PEM formatu.
keytool -list -keystore store.jks -storepass sigurnost
#Keystore ima 6 unosa, 5 sertifikata i jedan kljuc.
#Izbacimo sertifikate iz keystore, pa onda iz njih javne kljuceve.
mkdir certs
keytool -export -alias cer41 -file certs/cer1.crt -keystore store.jks -storepass sigurnost
keytool -export -alias cer85 -file certs/cer2.crt -keystore store.jks -storepass sigurnost
keytool -export -alias cer142 -file certs/cer3.crt -keystore store.jks -storepass sigurnost
keytool -export -alias cer63 -file certs/cer4.crt -keystore store.jks -storepass sigurnost
keytool -export -alias cer99 -file certs/cer5.crt -keystore store.jks -storepass sigurnost
#Svi sertifikati su u DER formatu!
mkdir public-keys
for i in {1..5}; do openssl x509 -in certs/cer$i.crt -inform der -pubkey -noout > public-keys/public$i.key; done

#Da bi smo dosli do privatnog kljuca moramo prvo jks konvertovati u p12 datoteku pa onda izbaciti kljuc.
keytool -importkeystore -srckeystore store.jks -destkeystore store.p12 -srcstoretype jks -deststoretype pkcs12 -srcstorepass sigurnost -deststorepass sigurnost
#Izbacivanje kljuca.
openssl pkcs12 -in store.p12 -nocerts -out private.key -passin pass:sigurnost -passout pass:sigurnost
#Konverotvanja privatnog enkriptovanog kljuca u privatni kljuc.
openssl rsa -in private.key -out private.pem -passin pass:sigurnost
openssl rsa -in private.pem -pubout -out public-keys/public0.key

mkdir keys/public
#Ekstraktujemo javne kljuceve iz datih privatnih radi poredjenja.
for i in {0..150}; do openssl rsa -in keys/key$i.key -pubout -out keys/public/pub$i.pem; done
#Napisemo skriptu za poredjenje.
touch script.sh && chmod +x script.sh
./script.sh
#Pronasli smo dva match-a.
#MATCH FOUND: key34.key
#MATCH FOUND: key100.key
