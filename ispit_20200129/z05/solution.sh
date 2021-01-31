#!/bin/bash
mkdir {certs,necerts,private,requests,crl}
touch index.txt crlnumber
echo 01 > serial
#Podesiti openssl.cnf datoteku (obratiti paznje na polja politike).
#Nedostaje privatni kljuc za ca.pem!

#Napravimo 4 nova RSA kljuca.
for i in {1..4}; do openssl genrsa -out private/key$i.pem 2048; done 

#Napravimo tri nova sertifikata za korisnicku autentikaciju, tj. extendedKeyUsage = clientAuth
for i in {1..3}; do openssl req -new -key private/key$i.pem -out requests/req$i.csr -config openssl.cnf; done
for i in {1..3}; do openssl ca -in requests/req$i.csr -out certs/c$i.pem -config openssl.cnf; done

#Napravimo certifikat za serversku autentikaciju, tj. extendedKeyUsage = serverAuth
openssl req -new -key private/key4.pem -out requests/req4.csr -config openssl.cnf
openssl ca -in requests/req4.csr -out certs/c4.pem -config openssl.cnf

#Generisimo .jks datoteku za serversku autentikaciju.
keytool -import -trustcacerts -alias rootCA -file ca.pem -keystore server.jks -storepass sigurnost
keytool -import -alias Sx -file certs/c4.pem -keystore server.jks -storepass sigurnost

#Generisimo .jks datoteku za klijentske sertifikate.
keytool -import -trustcacerts -alias rootCA -file ca.pem -keystore client.jks -storepass sigurnost
keytool -import -alias N1 -file certs/c1.pem -keystore client.jks -storepass sigurnost
keytool -import -alias N2 -file certs/c2.pem -keystore client.jks -storepass sigurnost
keytool -import -alias N3 -file certs/c3.pem -keystore client.jks -storepass sigurnost

#Generisimo jednu pkcs12 datoteku za klijentsku autentikaciju.
openssl pkcs12 -export -out client.p12 -inkey private/key1.pem -in certs/c1.pem -certfile ca.pem

#Dodamo sljedece u server.xml datoteku:
#    <Connector port="8443" protocol="HTTP/1.1"
#               scheme="https"
#               secure="true"
#               SSLEnabled="true"    
#               server="Apache"
#               maxThreads="500" acceptCount="500"
#               keystoreFile="conf/server.jks"
#               keystorePass="sigurnost"
#               clientAuth="true"
#               truststoreFile="conf/client.p12"
#               truststorePass="sigurnost" />
