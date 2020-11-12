#!/bin/bash
mkdir keys && mv *.key keys/
mkdir keystore && mv *.jks keystore/

#Potpis je base64 kodovan.
mv potpis.txt potpis.base64
openssl enc -d -base64 -in potpis.base64 -out potpis.txt

#Potrebno je odrediti verifikaciju potpisa koristeci sha algoritme, date kljuceve i date keystore-ove.
#Svi kljucevi su private, RSA u PEM formatu.

#Izdvojimo sve sha algoritme u jednu listu.
openssl list --digest-commands | tr -s " " "\n" |grep -e "^sha[0-9-]*$" > sha.list

#Za provjeru nam trebaju javni kljucevi, ne privatni.
mkdir keys/public
for i in {1..50}; do openssl rsa -in keys/kljuc$i.key -pubout -out keys/public/public$i.pem; done  

#Napisimo skriptu za provjeru potpisa.
touch script.sh && chmod +x script.sh
./script.sh 2>/dev/null
#Dobijamo: "Match found: key31 + sha256 + keystore4 = potpis.txt"

#Za serversku implementaciju koristimo keystore4. Izbacimo privatni kljuc iz keystore-a.
#Prvo moramo .jks datoteku konvertovati u .p12 datoteku nakon cega radimo ekstrakciju privatnog kljuca.
keytool -importkeystore -srckeystore keystore/keystore4.jks -srcstoretype jks -destkeystore keystore.p12 -deststoretype pkcs12 -srcstorepass sigurnost -deststorepass sigurnost
#Izbacivanje kljuca
openssl pkcs12 -in keystore.p12 -nocerts -out private-pass_protected.key -passin pass:sigurnost -passout pass:sigurnost
#Konvertujmo kljuc koji nije password protected.
openssl rsa -in private-pass_protected.key -out private.key -passin pass:sigurnost

mkdir {certs,newcerts,crl,requests,private}
touch index.txt crlnumber
echo 01 > serial
mv private.key private/server.key
#Novo CA tijelo.
openssl req -x509 -new -key private/private.key -out root.pem -config openssl.cnf 
#Kreirajmo novi zahjev koji cemo potpisati. Bitno je da ima extendedKeyUsage = serverAuth.
openssl req -new -key private/server.key -out requests/server.crl -config openssl.cnf
openssl ca -in requests/server.crl -config openssl.cnf -out certs/server.cer

#Kreiramo pkcs12 datoteku koristeci server.cer i server.key.
openssl pkcs12 -export -out server.p12 -inkey private/server.key -in certs/server.cer -certfile root.pem 
#Konvertujemo pkcs12 u jks datoteku. server.jks koristimo za serversku autentikaciju na Tomcat serveru.
keytool -importkeystore -srckeystore server.p12 -destkeystore server.jks -srcstorepass sigurnost -deststorepass sigurnost -srcstoretype pkcs12 -deststoretype jks


