#!/bin/bash
mkdir jks && mv *.jks jks/
#kljuc.key ima problem?
#Konvertujmo prvo .jks u .p12 datoteke pa onda izbacimo privatni kljuc.
mkdir p12
for i in {1..100}; do keytool -importkeystore -srckeystore jks/store$i.jks -srcstoretype jks -destkeystore p12/store$i.p12 -deststoretype pkcs12 -srcstorepass sigurnost -deststorepass sigurnost; done; rm -rf jks/ 2>/dev/null
#Izdvojimo kljuceve.
mkdir keys
for i in {1..50}; do openssl pkcs12 -in p12/store$i.p12 -nocerts -out keys/key$i.enc -passin pass:sigurnost -passout pass:sigurnost; done 2>/dev/null &
for i in {51..100}; do openssl pkcs12 -in p12/store$i.p12 -nocerts -out keys/key$i.enc -passin pass:sigurnost -passout pass:sigurnost; done 2>/dev/null &
#Dekriptujmo enkriptovane RSA kljuceve.
for i in {1..100}; do openssl rsa -in keys/key$i.enc -out keys/key$i.der -outform der -passin pass:sigurnost && rm keys/key$i.enc; done 2>/dev/null
#Pronadjimo match.
for i in {1..100}; do if [[ "$(diff keys/key$i.der kljuc.key | awk 'NR=1')" == "" ]]; then echo "MATCH: key$i" && break; fi; done
