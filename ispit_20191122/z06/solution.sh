#!/bin/bash
#Konvertujmo cert1.p12 u server.jks datoteku.
keytool -importkeystore -srckeystore cert1.p12 -srcstoretype pkcs12 -destkeystore server.jks -deststoretype jks -srcstorepass sigurnost -deststorepass sigurnost
#Izvucimo kljuc iz cert2.p12 datoteke.
openssl pkcs12 -in cert2.p12 -nocerts -out private.enc -passin pass:sigurnost -passout pass:sigurnost
openssl rsa -in private.enc -out private.key -passin pass:sigurnost && rm *.enc
#Podesimo okruzenje za openssl.cnf.
mkdir {certs,newcerts,crl,requests,private}
touch index.txt crlnumber
echo 01 > serial
mv private.key private/
#Kreirajmo novo root CA tijelo.
openssl req -x509 -new -out ca.pem -key private/private.key -config openssl.cnf 
for i in {1..2}; do openssl genrsa -out private/key$i.pem 2048; done
for i in {1..2}; do openssl req -new -out requests/req$i.csr -key private/key$i.pem -config openssl.cnf; done
for i in {1..2}; do openssl ca -in requests/req$i.csr -out certs/c$i.pem -config openssl.cnf; done

#Importujemo oba sertifata u server.jks.
for i in {1..2}; do keytool -import -alias K$i -file certs/c$i.pem -keystore server.jks -trustcacerts -storepass sigurnost; done

#Napravimo jedanu .p12 datoteku sa jednim korisnickom sertifikatom.
openssl pkcs12 -export -out client.p12 -inkey private/key1.pem -in certs/c1.pem -certfile ca.pem -passin pass:sigurnost -passout pass:sigurnost
#Podesimo server.xml.
#    <Connector port="8443" protocol="HTTP/1.1"
#               scheme="https"
#               secure="true"
#               SSLEnabled="true"    
#               server="Apache"
#               maxThreads="500" acceptCount="500"
#               keystoreFile="conf/server.jks"
#               keystorePass="sigurnost"
#               clientAuth="true"
#               truststoreFile="conf/server.jks"
#               truststorePass="sigurnost" />
