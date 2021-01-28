#!/bin/bash
mkdir ulazi && mv ulaz*.txt ulazi/
mkdir stores && mv store*.jks stores/
#Izdvojimo kljuceve iz .jks datoteka. Prvo konvertujemo .jks u .p12 pa onda izdvajamo kljuc. Nakon toga radimo verifikaciju sa datim kljucem.
for i in {1..100}; do keytool -importkeystore -srckeystore stores/store$i.jks -destkeystore stores/store$i.p12 -deststoretype pkcs12 -srcstorepass sigurnost -deststorepass sigurnost; openssl pkcs12 -in stores/store$i.p12 -nokeys -clcerts -out stores/cert$i.pem -passin pass:sigurnost; done; rm stores/*.p12
for i in {1..100}; do openssl x509 -in stores/cert$i.pem -pubkey -noout > keys/public$i.pem; done
rm stores/*.pem
#Napismo skriptu za provjeru.
touch script.sh && chmod +x script.sh
./script.sh
#Dobijamo da je odgovarajuci kljuc u store69 smjesten.
rm -r keys/
