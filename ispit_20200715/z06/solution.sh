#!/bin/bash
mkdir sertifikati && mv *.crt sertifikati/
#Procitajmo prvo sadrzaj store.jks-a.
keytool -list -keystore store.jks 
#Sadrzi dva sertifikata.
#Izvucimo sertifikate iz store.jks datoteke.
keytool -export -alias a -file s1.crt -keystore store.jks 
keytool -export -alias b -file s2.crt -keystore store.jks 
keytool -export -alias root -file s0.crt -keystore store.jks #root CA sertifikat
#Dobijeni sertifikati su u DER formatu. Prebacimo ih u PEM.
for i in {0..2}; do openssl x509 -in s$i.crt -inform DER -out s$i.crt -outform PEM; done

#Dati sertifikati izgledaju kao da su u DER formatu. Konvertujmo ih prvo u PEM format.
for i in {1..20}; do openssl x509 -in sertifikati/cert$i.crt -inform DER -out sertifikati/cert$i.crt -outform PEM; done
#Sada radimo poredjenje.
for i in {1..20}; do for j in {0..2}; if [ "$(diff s$j.crt sertifikati/cert$i.crt)" == "" ]; then echo "cert$i.crt == s$j.crt"; break; fi; done; done
#Dobijemo:
#cert7.crt == s1.crt
#cert16.crt == s2.crt

cp ../z05/openssl.cnf .
mkdir {certs,newcerts,requests,crl,private}
touch index.txt crlnumber
echo 01 > serial
#Sada nam treba privatni kljuc koji odgovara ca.pem-u. Kako ne mozemo direktno iz jks da izvucemo privatni kljuc, moramo prvo JKS konvertovati u P12 datoteku iz koje onda mozemo izvuci kljuc.
keytool -importkeystore -srckeystore store.jks -srcstoretype JKS -destkeystore store.p12 -deststoretype PKCS12 -srcstorepass sigurnost -deststorepass sigurnost
#Eksportujmo privatni kljuc.
openssl pkcs12 -in store.p12 -nocerts -out private/private.key
#Za klijentske sertifikate u openss.cnf -> extendedKeyUsage = clientAuth
#Za serverski sertifikat -> extendedKeyUsage = serverAuth
#Kreirajmo CA tijelo koristeci kljuc private.key iz store.jks datoteke.
openssl req -x509 -new -out ca.pem -key private/private.key -config openssl.cnf 

for i in {1..3}; do openssl genrsa -out private/key$i.pem 2048; done
for i in {1..3}; do openssl req -new -out requests/req$i.csr -config openssl.cnf -key private/key$i.pem; done
for i in {1..2}; do openssl ca -in requests/req$i.csr -config openssl.cnf -out certs/s$i.pem; done
openssl ca -in requests/req3.csr -config openssl.cnf -out certs/root.pem;
 
#Kreirajmo pkcs12 datoteku koju cemo konvertovati u JKS datoteku koristeci root.pem i njegov kljuc key3.pem.
openssl pkcs12 -export -out keystore.jks -inkey private/key3.pem -in certs/root.pem -certfile ca.pem 
keytool -importkeystore -srckeystore keystore.p12 -srcstoretype pkcs12 -destkeystore keystore.jks -deststoretype jks -srcstorepass sigurnost -deststorepass sigurnost

#Kako se trazi jedan fajl za serversku i klijentsku autentikaciju, importujmo klijentske sertifikate u keystore.jks.
keytool -import -alias s1 -file certs/s1.pem -keystore keystore.jks 
keytool -import -alias s2 -file certs/s2.pem -keystore keystore.jks

#Kreirajmo jos jednu pkcs12 datoteku za klijentski sertifikat jer tako trazi zadatak.
openssl pkcs12 -export -out client1.p12 -inkey private/key1.pem -in certs/s1.pem -certfile ca.pem 

mkdir solution-files
mv client1.p12 solution-files/
mv keystore.jks solution-files/
mv server.xml solution-files/
#Jos samo treba podesiti server.xml.
#    <Connector port="8443" protocol="HTTP/1.1"
#               scheme="https"
#               secure="true"
#               SSLEnabled="true"    
#               server="Apache"
#               maxThreads="500" acceptCount="500"
#               keystoreFile="conf/keystore.jks"
#               keystorePass="sigurnost"
#               clientAuth="true"
#               truststoreFile="conf/client1.p12"
#               truststorePass="sigurnost" />
