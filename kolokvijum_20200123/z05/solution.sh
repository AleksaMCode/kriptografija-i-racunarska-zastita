#!/bin/bash
#Konvertujmo s.p12 u s.jks koji cemo koristit za serversku autentikaciju.
keytool -importkeystore -srckeystore s.p12 -srcstoretype pkcs12 -destkeystore s.jsk -deststoretype jks -srcstorepass sigurnost -deststorepass sigurnost

#Konvertujemo k.jks u k.p12, pa zatim vrsimo ekstrakciju sertifikata i kljuca. k.jks ima samo jedan entry!
keytool -importkeystore -srckeystore k.jks -srcstoretype jks -destkeystore k.p12 -deststoretype pkcs12 -srcstorepass sigurnost -deststorepass sigurnost
openssl pkcs12 -in k.p12 -nocerts -passin pass:sigurnost -out private.pem
#Uklonimo pass protection iz kljuca.
openssl rsa -in private.pem -inform pem -out private.pem -outform pem
openssl pkcs12 -in k.p12 -nokeys -clcerts -out ca.pem -passin pass:sigurnost
cp ../z04/openssl.cnf . #kopiramo opnessl.cnf datoteku iz prethodnog zadatka (potrebno obrisati polje email ili ga setovati da bude optional)
#Podesimo okruzenje i openssl.cnf datoteku.
mv private.pem private/private4096.key
mkdir {requests,crl,newcerts,certs,private}
touch index.txt crlnumber
echo 01 > serial
#Kreirajmo dva RSA kljuca.
for i in {0..1}; do openssl genrsa -out private/key2$i.pem 2048; done
#podesimo u openssl.cnf sljedece:
#extendedKeyUsage = clientAuth, ostali parametri nisu od znacaja za ovaj zadatak
#Dalje kreiramo dva nova zahtjeva za sertifikatima.
openssl req -new -key private/key20.pem -out requests/req20.csr -config openssl.cnf
openssl req -new -key private/key21.pem -out requests/req21.csr -config openssl.cnf
for i in {0..1}; do openssl ca -in requests/req2$i.csr -out certs/krip2$i.pem -config openssl.cnf; done
#Importujemo dva nova sertifikata u s.jks datoteku.
for i in {0..1}; do keytool -import -alias kript2$i -file certs/krip2$i.pem -keystore s.jks -storepass sigurnost; done
#Kreirajmo jednu pkcs12 datoteku za testiranje klijentske autentikacije.
openssl pkcs12 -export -out krip20.p12 -inkey private/key20.pem -in certs/krip20.pem -certfile ca.pem
#Na kraju samo podesimo server.xml datoteku za 8443 port.
