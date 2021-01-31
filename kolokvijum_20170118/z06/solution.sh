#!/bin/bash
#Podesimo openssl.cnf datoteku prvo.
mkdir {private,crl,requests,certs,newcerts}
touch index.txt crlnumber serial
mv private.key private/
#Kreirajmo root CA.
openssl req -x509 -new -key private/private.key -out cacert.crt -config openssl.cnf
#Kreirajmo tri nova RSA kljuca.
for i in {1..3}; do openssl genrsa -out private/key$i.pem 2048; done

#Prvi sertifikat:
#Nije CA i keyUsage = cRLSign, digitalSignature.
echo 12 > serial
openssl req -new -key private/key1.pem -out requests/req1.csr -config openssl.cnf
#Na 2 mjeseca kreiran sertifikat.
openssl ca -in requests/req1.csr -out certs/c1.pem -config openssl.cnf -days 60

#Treci sertifikat:
#Isto nije CA kao i prvi, a keyUsage nije specifikovan pa cemo ostaviti isti kao i kod prvog.
echo 15 > serial
openssl req -new -key private/key3.pem -out requests/req3.csr -config openssl.cnf
#Na jednu godinu kreiran sertifikat.
openssl ca -in requests/req3.csr -out certs/c3.pem -config openssl.cnf -days 365

#Drugi sertifikat:
#Ovaj sertifikat mora biti CA i keyUsage = encipherOnly.
echo 14 > serial
openssl req -new -key private/key2.pem -out requests/req2.csr -config openssl.cnf
#Potpisan na 6 mjeseci.
openssl ca -in requests/req2.csr -out certs/c2.pem -config openssl.cnf -days 180
