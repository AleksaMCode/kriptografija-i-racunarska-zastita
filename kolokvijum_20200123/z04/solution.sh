#!/bin/bash
#ca.pem datoteka je base64 kodovana.
mv ca.pem ca.base64
openssl enc -d -base64 -in ca.base64 -out ca.pem
#ca.pem je u der formatu, pa je potrebno ga je potrebno prebaciti u pem.
openssl x509 -in ca.pem -inform der -out ca.pem -outform pem

#lista.crl je isto base64 kodovana.
mv lista.crl lista.base64
openssl enc -d -base64 -in lista.base64 -out lista.crl
openssl crl -in lista.crl -noout -text -inform der
#Lista je u der formatu. Kovertujmo u pem.
openssl crl -in lista.crl -inform der -out lista.crl -outform pem

#private4096.key je enkriptovan. Uklonimo lozinku sa kljuca. Prvo provjerimo da li je kljuc RSA.
openssl rsa -in private4096.key -noout -text -passin pass:sigurnost
#Kljuc jeste RSA.
mv private4096.key private4096.enc
openssl rsa -in private4096.key -out private4096.key -passin pass:sigurnost

#Uklonimo datoteke koje su visak.
rm *.base64

mkdir {certs,crl,newcerts,requests,private}
touch crlnumber index.txt
echo 01 > serial
mv private4096.key private/
#Podesimo openssl.cnf datoteku. Izmjena politike nije zabranjena!

#Kreirajmo 5 kljuceva.
for i in {1..4}; do openssl genrsa -out private/key$i.pem 2048; done
openssl genrsa -out private/private4096-new.key 4096 # Koristi se za novo CA tijelo koje kasnije kreiramo.

#za s1.cer:
#basicConstraints=CA:FALSE
#keyUsage = cRLSign
echo cc > serial
openssl req -new -key private/key1.pem -out requests/req1.csr -config openssl.cnf 
openssl ca -in requests/req1.csr -out certs/s1.pem -config openssl.cnf -days 21

#za s2.cer:
#basicConstraints=CA:TRUE
#keyUsage = keyAgreement
#extendedKeyUsage = clientAuth
echo 2f > serial
openssl req -new -key private/key2.pem -out requests/req2.csr -config openssl.cnf 
openssl ca -in requests/req2.csr -out certs/s2.pem -config openssl.cnf -days 3650

#Kreirajmo novo root CA tijelo.
mv ca.pem ca_old.pem
#Podesimo openssl.cnf da odgovara zahtjevu zadatka.
mv private/private4096.key private/private4096-old.key
mv private/private4096-new.key private/private4096.key
openssl req -x509 -new -key private/private4096.key -out ca.pem -config openssl.cnf 

#s3 i s4 potpisuje novi ca.pem.
#za s3.cer:
#keyUsage = decipherOnly
#extendedKeyUsage = serverAuth
echo 66 > serial
#Sertifikat ne smije da sadrži informacije o oranizaciji! Ostavimo polje praznim kod popunjavanja zahtjeva.
openssl req -new -key private/key3.pem -out requests/req3.csr -config openssl.cnf 
openssl ca -in requests/req3.csr -out certs/s3.cer -config openssl.cnf -days 12

#za s4.cer:
#keyUsage = keyAgreement
echo 14 > serial
openssl req -new -key private/key4.pem -out requests/req4.csr -config openssl.cnf 
openssl ca -in requests/req4.csr -out certs/s4.cer -config openssl.cnf -days 36500

#Postojeca lista ne moze da se iskoristi za povlacenje sertifikata u openssl-u!
#Napravimo backup index.txt-a.
cp index.txt index-backup.txt
#Suspendujmo c2 i c3.
openssl ca -revoke certs/s2.pem -crl_reason certificateHold -config openssl.cnf 
openssl ca -revoke certs/s3.cer -crl_reason affiliationChanged -config openssl.cnf 
echo 06 > crlnumber
openssl ca -gencrl -out crl/lista1.crl -config openssl.cnf -days 59

#Kreiranje datoteke lista2.crl.
cp index-backup.txt index.txt
openssl ca -revoke certs/s3.cer -crl_reason affiliationChanged -config openssl.cnf 
echo ed > crlnumber 
openssl ca -gencrl -out crl/lista2.crl -config openssl.cnf -days 262 # 8x60+22=262, datum je generisan od datuma odrzavanja ispita.
