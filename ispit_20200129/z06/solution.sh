#!/bin/bash
mkdir certs && mv cert*.crt certs/
#Sertifikati su u der formatu. Konvertujemo ih u pem format.
#store.jks datoteka je base64 kodovana. Dekodujmo ju provo, pa onda izbacimo sve dosupne sertifikate.
mv store.jks store.base64
openssl enc -d -base64 -in store.base64 -out store.jks
mkdir jks-certs
keytool -export -alias a -file jks-certs/s1.crt -keystore store.jks -storepass sigurnost
keytool -export -aliaexirs b -file jks-certs/s2.crt -keystore store.jks -storepass sigurnost
keytool -export -alias c -file jks-certs/s3.crt -keystore store.jks -storepass sigurnost
keytool -export -alias root -file jks-certs/s4.crt -keystore store.jks -storepass sigurnost
#Napisimo skriptu za poredjenje
touch script.sh && chmod +x script.sh
#Dobijamo:
#MATCH: s1.crt <-> cert4.crt
#MATCH: s1.crt <-> cert16.crt
#MATCH: s2.crt <-> cert12.crt
#MATCH: s2.crt <-> cert21.crt
#Sertiifkati cert4 i cert16 su jednaki i nalaze se unutar jks datoteke pod alias-om, a cert12 i cert21 su jednaki i zavedeni pod alias-om b.
