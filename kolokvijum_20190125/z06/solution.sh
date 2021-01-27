#!/bin/bash
#Konvertujemo server.p12 u server.jks datoteku.
keytool -importkeystore -srckeystore server.p12 -srcstoretype pkcs12 -destkeystore server.jks -deststoretype jks -deststorepass sigurnost -srcstorepass sigurnost
#Konvertujemo zatim client.jks u client.p12 datoteku.
keytool -importkeystore -srckeystore client.jks -srcstoretype jks -destkeystore client.p12 -deststoretype pkcs12 -srcstorepass sigurnost -deststorepass sigurnost
#Izdvojimo sertifikat i privatni kljuc iz client.p12 datoteke.
openssl pkcs12 -in client.p12 -nokeys -clcerts -out client.pem
mv client.pem ca.pem
openssl pkcs12 -in client.p12 -nocerts -out private4096.encrypted -passin pass:sigurnost -passout pass:sigurnost
openssl rsa -in private4096.encrypted -inform pem -out private4096.key -outform pem -passin pass:sigurnost
rm private4096.encrypted 

mkdir {certs,newcerts,private,requests,crl}
touch index.txt crlnumber
echo 01 > serial
mv private4096.key private/
#Kreirajmo dva nova RSA kljuca.
for i in {1..2}; do openssl genrsa -out private/key$i.pem 2048; done
#Kreirajmo dva CSR-a koja cemo zatim potpisati.
for i in {1..2}; do openssl req -new -key private/key$i.pem -out requests/req$i.csr -config openssl.cnf; done
for i in {1..2}; do openssl ca -in requests/req$i.csr -out certs/c$i.pem -config openssl.cnf -days 365; done
#Iskoristimo c1.pem i njegov odgovarajuci kljuc da napravimo pkcs12 datoteku.
openssl pkcs12 -export -out client1.p12 -inkey private/key1.pem -in certs/c1.pem -certfile ca.pem -passin pass:sigurnost -passout pass:sigurnost
#U server.xml dodajemo sljedece:
#    <Connector port="8443" protocol="HTTP/1.1"
#               scheme="https"
#               secure="true"
#               SSLEnabled="true"    
#               server="Apache"
#               maxThreads="500" acceptCount="500"
#               keystoreFile="server.jks"
#               keystorePass="sigurnost"
#               clientAuth="true"
#               truststoreFile="client1.jks"
#               truststorePass="sigurnost" />
