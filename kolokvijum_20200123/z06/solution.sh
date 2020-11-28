#!/bin/bash
mkdir keys && mv *.key keys/
mkdir store_keys
for i in {1..5}; do keytool -export -alias s$i -file s$i.pem -keystore store.jks -storepass sigurnost; done
keytool -export -alias root -file s0.pem -keystore store.jks -storepass sigurnost
#Izvlacenje javnih kljuceva:
for i in {0..5}; do openssl x509 -in s$i.pem -inform der -pubkey -noout > store_keys/jks_key$i.pem; done && rm s*.pem
#Izbacimo chain korisnickih sertifikata. Rucno izdvojimo pojedinicne sertifikate.
openssl pkcs12 -in store.p12 -info -passin pass:sigurnost -passout pass:sigurnost -nodes -chain  > clientcertchain.pem
for i in {0..5}; do touch s$i.pem; done
#Alternativan pristup je konverzija u jks datoteku i onda izvlacenje sertifikata.
keytool -importkeystore -srckeystore store.p12 -srcstorepass sigurnost -destkeystore p12-store.jks -deststorepass sigurnost -srcstoretype pkcs12 -deststoretype jks
#Uzvucimo javne kljuceve:
for i in {0..5}; do openssl x509 -in s$i.pem -pubkey -noout > store_keys/p12_key$i.pem; done && rm *.pem

#Izvucimo javne kljuceve iz datih 150 privatnih RSA kljuceva radi poredjenja.
mkdir keys/public
for i in {1..150}; do openssl rsa -in keys/key$i.key -pubout -out keys/public/public$i.pem; done
#Napisimo skriptu za poredjenje kljuceva.
touch keys-compare.sh && chmod +x keys-compare.sh
./keys-compare.sh
#Dobijamo ispis: "MATCH: key113.key - s5 from JKS & s2 from PKCS12"
#Znaci, kljuc113 se nalazi u s5 sertifikatu u jks datoteci i u s2 sertifikatu u pkcs12 datoteci.
