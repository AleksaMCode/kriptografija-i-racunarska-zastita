#!/bin/bash
mkdir keys && mv *.key keys/
#Prvo dekodujemo obe datoteke, .jks i .p12 iz base64 formata.
mv store.jks store-jks.base64
mv store.p12 store-p12.base64
openssl enc -d -base64 -in store-jks.base64 -out store.jks
openssl enc -d -base64 -in store-p12.base64 -out store.p12
mkdir store-{keys,certs}
#Procitajmo sadrzaj .p12 datoteke.
keytool -list -keystore store.p12
#Imamo 5 sertifikata + root sertifikat
for i in {1..5}; do keytool -export -alias ---->s1 -file store-certs/s$i.cer -keystore store.p12 -storepass sigurnost; done
#Izbacimo i root sertifikat. Nazovimo ga s0.cer.
keytool -export -alias root -file store-certs/s0.cer -keystore store.p12 -storepass sigurnost
#Ne moze ovako. Izbacimo ispis iz .p12 samo sertifikata u jednu datoteku pa onda rucno kopiramo sertifikate. Ne moze se koristiti keytool. Moze se koristiti keytool, gore ima greska u for petlji, koristio sam s1 umjesto s$i, pa sam zato dobio 5 identicnih sertifikata i kasnije kljuceva.
openssl pkcs12 -info -in store.p12 -nokeys > store-p12.info

#Konvertujmo sve sertifikate iz der u pem format.

#Izbacimo iz njih sve javne kljuceve.
for i in {0..5}; do openssl x509 -in store-certs/s$i.cer -pubkey -noout > store-keys/key-p12-$i.pem; done

#Odradimo slicno i za jks datoteku.
keytool -list -keystore store.jks
for i in {1..5}; do keytool -export -alias s$i -file store-certs/s$i-jks.cer -keystore store.jks -storepass sigurnost; done
keytool -export -alias root -file store-certs/s0-jks.cer -keystore store.jks -storepass sigurnost
#Izbacimo iz njih sve javne kljuceve.
for i in {0..5}; do openssl x509 -in store-certs/s$i-jks.cer -inform DER -pubkey -noout > store-keys/key-jks-$i.pem; done

#Pregledajmo kljuceve! Izgledaju kao RSA private kljucevi. Izdvojimo javne kljuceve koje cemo koristi za poredjenje.
mkdir keys/public
for i in {1..150}; do openssl rsa -in keys/key$i.key -pubout -out keys/public/key$i.pem; done
#Napisimo skriptu koja ce da radi poredjennja i ispis match-ova.
touch script.sh && chmod 777 script.sh
./script.sh
#Dobijemo izlaz "KEY 126 is in both files, jks and p12.". Znaci rjesenje je key126.key.
