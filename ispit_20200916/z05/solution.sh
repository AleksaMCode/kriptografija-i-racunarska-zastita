#!/bin/bash
mkdir stores ; mv *.p12 stores/
#Napisimo skriptu za provjeru otiska sa p12 datotekama.
touch script-p12-check.sh && chmod 777 script-p12-check.sh
./script-p12-check.sh
#Dobijamo sljedeci ispis: "Correct p12 file is store8.p12."
#Izbacimo kljuc iz store8.p12 datoteke.
openssl pkcs12 -in stores/store8.p12 -nocerts -out private.key

#Podesimo okruzenje da odgovara openssl.cnf datoteci kao i samu openssl.cnf datoteku.
mkdir {certs,newcerts,requests,private,crl}
touch index.txt crlnumber
echo 01 > serial
mv private.key private/
#Napravimo samopotpisujuci sertifikat koristeci kljuc iz pkcs12 datoteke.
openssl req -x509 -new -key private/private.key -out rootCA.pem -config openssl.cnf 

#Trebaju nam tri klijentska sertifikata. extendedKeyUsage = clientAuth
for i in {1..4}; do openssl genrsa -out private/key$i.pem 2048; done
for i in {1..3}; do openssl req -new -key private/key$i.pem -out requests/req$i.csr -config openssl.cnf; done
#Potpisimo tri zahtjeva.
for i in {1..3}; do openssl ca -in requests/req$i.csr -config openssl.cnf -out certs/c$i.pem; done
mkdir -p solution/{server,client}
cp certs/c{1..3}.pem solution/client/
cp certs/c4.pem solution/server/
#Treba nam jedan serverski sertifikat. extendedKeyUsage = serverAuth
openssl req -new -key private/key4.pem -out requests/req4.csr -config openssl.cnf
openssl ca -in requests/req4.csr -config openssl.cnf -out certs/c4.pem

#Napravimo jks datoteku od serverskog sertifikata i privatnog kljuca key4.pem. Kreirajmo prvo p12 datoteku koju cemo zatim konvertovati u jks datoteku.
openssl pkcs12 -export -out solution/server/server.p12 -inkey private/key4.pem -in solution/server/c4.pem -certfile rootCA.pem
keytool -importkeystore -srckeystore solution/server/server.p12 -srcstoretype pkcs12 -destkeystore solution/server/server.jks -deststoretype jks -srcstorepass sigurnost -deststorepass sigurnost

#Za klijentsku autentikaciju napravimo jednu client.p12 datoteku.
openssl pkcs12 -export -out solution/client/client.p12 -inkey private/key1.pem -in solution/client/c1.pem -certfile rootCA.pem

#Dodamo u server.xml unutar <Connector port="8443"
#keystoreFile="conf/server.jks" 
#keystorePass="sigurnost" 
#truststoreFile="conf/client.p12" 
#truststorePass="sigurnost" 
