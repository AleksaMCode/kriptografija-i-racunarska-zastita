#!/bin/bash
mkdir -p kljucevi/public && mv *.key kljucevi/

#ca.pem datoteka je base64 kodovana. Dekodujmo ju je prvo.
mv ca.pem ca.base64
openssl enc -d -base64 -in ca.base64 -out ca.pem

#envelopa.enc datoteka je takodje base64 kodovana.
openssl enc -d -base64 -in envelopa.env -out envelopa.txt

mkdir junk
mv ca.base64 junk/
mv *.env junk

#Izdvojimo public key iz ca.pem datoteke.
openssl x509 -in ca.pem -inform DER -pubkey -noout > public.pem

#Pregledajmo kakve kljuceve imamo. Nama trebaju RSA kljucevi u PEM ili DER formatu.
for i in {1..50}; do openssl rsa -in kljucevi/kljuc$i.key -inform PEM -noout -text; done
#Svi su RSA PEM, a kljuc 36 je kriptovan (sifra je standardno sigurnost).
#Izdvojimo public kljuceve.
for i in {1..50}; do openssl rsa -in kljucevi/kljuc$i.key -inform PEM -pubout -out kljucevi/public/kljuc$i.pem -passin pass:sigurnost; done 2>/dev/null

#Poredjenje: 
for i in {1..50}; do if [[ "$(diff public.pem kljucevi/public/kljuc$i.pem)" == "" ]]; then echo "Match is key $i"; fi; done
#Rezultat: "Match is key 36". Naravno, rezultat je kljuc koji je jedini drugaciji od ostalih.
#Dekriptujmo datoteku envelopa.txt sa kljucem kljuc36.key
openssl rsautl -decrypt -in envelopa.txt -out envelopa.decripted -inkey kljucevi/kljuc36.key
#Rjesenje prvog dijela zadatka je envelopa.decripted u kojoj pise "Bravo".
mkdir 1st-part
mv junk/ 1st-part/
mv kljucevi/ 1st-part/
mv envelopa.* 1st-part/s
mv envelopa.* 1st-part/
mv public.pem 1st-part/

mkdir {certs,newcerts,requests,crl,private}
touch index.txt crlnumber
echo 01 > serial
cp 1st-part/kljucevi/kljuc36.key private/private.key
#Podesimo openssl.cnf da match-uje ca.pem!
for i in {1..3}; do openssl genrsa -out private/key$i.pem 2048; done
for i in {1..3}; do openssl req -new -out requests/req$i.csr -key private/key$i.pem -config openssl.cnf; done

#1. sertifikat
echo 12 > serial
#basicConstraints=CA:FALSE
#keyUsage = nonRepudiation
#extendedKeyUsage = serverAuth
openssl ca -in requests/req1.csr -out certs/s1.cer -config openssl.cnf -days 90
#Potpis nije prosao? Zasto? Vjerovatno zato sto ca.pem nije u PEM formatu. Ispravimo to!
openssl x509 -in ca.pem -inform DER -out ca.pem -outform PEM
openssl ca -in requests/req1.csr -out certs/s1.cer -config openssl.cnf -days 90 #Proslo.

#2. sertifikat
echo cb > serial
#basicConstraints=CA:TRUE
#keyUsage = decipherOnly
openssl ca -in requests/req2.csr -out certs/s2.cer -config openssl.cnf -days 3650

#3. sertifikat
echo a5 > serial
#basicConstraints=CA:TRUE <- nije precizirano pa ostavljam kao i za prethodni
#keyUsage = keyAgreement
openssl ca -in requests/req3.csr -out certs/s3.cer -config openssl.cnf -days 3650

#Napravimo backup od index.txt.
cp index.txt index-backup.txt

#Suspendovati s2 i s3 sertifikate.
openssl ca -revoke certs/s2.cer -crl_reason certificateHold -config openssl.cnf 
openssl ca -revoke certs/s3.cer -crl_reason certificateHold -config openssl.cnf 
echo 44 > crlnumber #Serijski broj liste lista1.crl Automatski se poveca za jedan, pa ce za lista2.crl biti 45 kao sto trazi zadatak.
openssl ca -gencrl -out crl/lista1.crl -config openssl.cnf
#Reaktivirajmo sve sertifikate.
mv index-backup.txt index.txt
openssl ca -gencrl -out crl/lista2.crl -config openssl.cnf -days 730 # 365x2=730 od 15.07.20. - 15.07.22. <- crl lista bez sertifikata!
