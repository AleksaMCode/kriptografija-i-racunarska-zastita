#!/bin/bash
#Konvertujmo server.p12 u server.jks za serversku autentikaciju.
keytool -importkeystore -srckeystore server.p12 -srcstoretype pkcs12 -destkeystore server.jks -deststoretype jks -srcstorepass sigurnost -deststorepass sigurnost
#Izbacimo private RSA kljuc iz klijent.p12.
openssl pkcs12 -in klijent.p12 -nocerts -out priv.pem -passin pass:sigurnost -passout pass:sigurnost

#Podesimo okruzenje.
mkdir {certs,newcerts,crl,requests,private}
touch index.txt crlnumber
echo 01 > serial
mv priv.pem private/
#Dodajemo extendedKeyUsage = clientAuth unutar openssl.cnf.
#Napravimo novi root CA.
openssl req -x509 -new -key private/priv.pem -out cacert.pem -config openssl.cnf

#Generisemo dva nova kljuca.
for i in {1..2}; do openssl genrsa -out private/key$i.pem 2048; done
#Generisemo dva nova csr-a.
for i in {1..2}; do openssl req -new -key private/key$i.pem -out requests/req$i.csr -config openssl.cnf; done
#Potpisimo oba zahtjeva.
openssl ca -in requests/req1.csr -out certs/c1.pem -config openssl.cnf 
openssl ca -in requests/req2.csr -out certs/c2.pem -config openssl.cnf

#Napravimo jednu pkcs12 datoteku koja ce se koristi za korisnicku autentikaciju.
openssl pkcs12 -export -out client1.p12 -inkey private/key1.pem -in certs/c1.pem -certfile cacert.pem -passout pass:sigurnost
#Mozemo i oba sertifikata staviti u jedan .p12 fajl. Kreirajmo prvo lanac.
cat certs/c1.pem certs/c2.pem >> clientcertchain.pem
openssl pkcs12 -export -out client.p12 -in clientcertchain.pem -inkey private/key1.pem -certfile cacert.pem -passout pass:sigurnost
