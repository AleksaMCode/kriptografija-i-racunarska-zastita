#!/bin/bash
#Kopirajmo potrebne datoteke iz 6. zadatka.
cp ../06/{openssl.cnf,cacert.crt,private/private.key} .
mkdir {private,crl,certs,newcerts,requests}
touch index.txt crlnumber
echo 01 > serial
mv private.key private/
#Kreirajmo tri kljuca.
for i in {1..3}; do openssl genrsa -out private/key$i.pem 2048; done
#Kreirajmo tri nova csr-a.
for i in {1..3}; do openssl req -new -key private/key$i.pem -out requests/req$i.csr -config openssl.cnf ; done
#Kreirajmo tri nova sertifikata.
for i in {1..3}; do openssl ca -in requests/req$i.csr -out certs/c$i.pem -config openssl.cnf -days 30; done

#Druga CRL lista:
openssl ca -revoke certs/c1.pem -crl_reason keyCompromise -config openssl.cnf 
echo 1d > crlnumber
openssl ca -gencrl -out crl/list2.pem -config openssl.cnf -days 465

#Napraviomo kopiju index.txt datoteke.
cp index.txt index-backup.txt

#Prva CRL lista:
openssl ca -revoke certs/c3.pem -crl_reason certificateHold -config openssl.cnf
echo 1b > crlnumber
openssl ca -gencrl -out crl/list1.pem -config openssl.cnf -days 465

#Treca CRL lista:
cp index-backup.txt index.txt
openssl ca -revoke certs/c2.pem -crl_reason affiliationChanged -config openssl.cnf
openssl ca -revoke certs/c3.pem -crl_reason affiliationChanged -config openssl.cnf
echo 1e > crlnumber
openssl ca -gencrl -out crl/list3.pem -config openssl.cnf
