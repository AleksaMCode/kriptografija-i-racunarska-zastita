#!/bin/bash
mkdir keys && mv *.key keys/
#Izvucimo klijentski sertifikat iz .p12 datoteke.
openssl pkcs12 -in cert.p12 -nocerts -out private.enc -passin pass:sigurnost -passout pass:sigurnost
openssl rsa -in private.enc -out private.pem -passin pass:sigurnost
#Kljucevi su u der formatu pa ih prebacujemo u pem.
for i in {1..100}; do openssl rsa -in keys/kljuc$i.key -inform der -out keys/key$i.pem -outform pem && rm keys/kljuc$i.key; done 2>/dev/null
#Uporedimo kljuceve.
for i in {1..100}; do if [[ "$(diff keys/key$i.pem private.pem)" == "" ]]; then echo "MATCH: key$i"; break; fi; done 2>/dev/null
#Dobijamo "MATCH: key80".
cp ../z06/openssl.cnf .
mkdir {private,crl,certs,newcerts,requests}
touch index.txt crlnumber
echo 01 > serial
openssl req -x509 -new -out ca.pem -key private.pem -config openssl.cnf 
mv private.pem private/
for i in {1..2}; do openssl genrsa -out private/key$i.pem 2048; done
for i in {1..2}; do openssl req -new -key private/key$i.pem -out requests/req$i.csr -config openssl.cnf; done
#Potpisimo oba sertfikata.
for i in {1..2}; do openssl ca -in requests/req$i.csr -out certs/c$i.pem -config openssl.cnf; done

#Povucimo samo drugi sertifikat pa napravimo list2.
echo af > crlnumber
openssl ca -revoke certs/c2.pem -crl_reason cessationOfOperation -config openssl.cnf
openssl ca -gencrl -out crl/list2.pem -config openssl.cnf 

#Povucimo i treci sertifikat pa napravimo list1.
openssl ca -revoke certs/c1.pem -crl_reason certificateHold -config openssl.cnf
openssl ca -gencrl -out crl/list1.pem -config openssl.cnf 
