#!/bin/bash
mkdir kljucevi && mv *.key kljucevi/
#client.pem nije u pem formatu!
openssl x509 -in client.pem -inform DER -out client.pem -outform PEM
#Svi kljucevi su der formatu!
for i in {1..100}; do openssl rsa -in kljucevi/kljuc$i.key -inform DER -out kljucevi/kljuc$i.pem -outform PEM; done
rm kljucevi/*.key
#Izbacimo javne kljuceve iz njih.
mkdir kljucevi/public
for i in {1..100}; do openssl rsa -in kljucevi/kljuc$i.pem -pubout -out kljucevi/public/key$i.pem; done

#Izbacimo iz client.pem-a javni kljuc.
openssl x509 -in client.pem -noout -pubkey > public.pem
#Napisimo skriptu za poredjenje kljuceva
touch script-key.sh && chmod 777 script-key.sh 
./script-key.sh
#Dobijamo: "key71 is in ca.pem."
#Dalje kreiramo pkcs12 daoteku od ca.pem + client.pem + key71.pem.
openssl pkcs12 -export -out client.p12 -inkey kljucevi/kljuc71.pem -in client.pem -certfile ca.pem -passin pass:sigurnost -passout pass:sigurnos
#Importujemo sertifikat u browser i odemo na adresu iz adresa.txt po nas zadatak.
