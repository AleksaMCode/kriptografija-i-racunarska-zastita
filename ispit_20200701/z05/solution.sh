#!/bin/bash
#Dekodujmo ca.pem iz base64 formata.
mv ca.pem ca.base64
openssl enc -d -base64 -in ca.base64 -out ca.pem
#Zatim ga konvertujemo u pem.
openssl x509 -in ca.pem -inform DER -out ca.pem -outform PEM

mkdir {certs,newcerts,crl,requests,private}
touch index.txt crlnumber
echo 01 > serial
#Podesimo openssl.cnf da odgovara ca.pem datoteci.
mv private4096.key private/

for i in {1..2}; do openssl genrsa -out private/key$i.pem 2048; done
for i in {1..2}; do openssl req -new -key private/key$i.pem -out requests/req$i.csr -config openssl.cnf; done

#Prvi sertifikat:
#basicConstraints=CA:FALSE
#keyUsage = cRLSign
echo bb > serial
openssl ca -in requests/req1.csr -out certs/s1.cer -config openssl.cnf -days 25

#Drugi sertifikat:
#basicConstraints=CA:TRUE
#keyUsage = keyAgreement
#extendedKeyUsage = serverAuth
echo 2c > serial
openssl ca -in requests/req2.csr -out certs/s2.cer -config openssl.cnf -days 1825 # 5x365=1825, trajanje od 5 godina

#Novo CA tijelo.
mv ca.pem ca-old.pem
openssl req -x509 -new -key private/private4096.key -config openssl.cnf -out ca.pem

for i in {3..4}; do openssl genrsa -out private/key$i.pem 2048; done
#Kod unosa podataka treba ostaviti podatke o organizaciji prazno - organizationName i organizatioUnitName. To je moguce jer su oni optional politike sertifikata. Moramo da obrisemo default-ne vrijednosti za ta dva polja!
for i in {3..4}; do openssl req -new -key private/key$i.pem -out requests/req$i.csr -config openssl.cnf; done

#3. sertifikat:
#Moze, a ne mora da bude CA. Nije specifikovana tekstom zadatka.
#keyUsage = decipherOnly
#extendedKeyUsage = clientAuth
echo 18 > serial
openssl ca -in requests/req3.csr -out certs/s3.cer -config openssl.cnf -days 120 # 4 mjeseca x 30 dana = 120

#4. sertifikat:
echo 44 > serial
#Moze, a ne mora da bude CA. Nije specifikovana tekstom zadatka.
#keyUsage = keyAgreement
openssl ca -in requests/req4.csr -out certs/s4.cet -config openssl.cnf -days 3650

#Suspendujmo sertifikat s3, pa napravimo listu list2.crl
openssl ca -revoke certs/s3.cer -crl_reason CACompromise -config openssl.cnf 
echo ce > crlnumber
openssl ca -gencrl -out crl/lista2.crl -config openssl.cnf -days 365 # Datum izdavanje sljedece liste je za godinu dana!

#Dalje suspendujemo s2.cer, pa pravimo listu lista1.crl.
#Ovdje pise razlog suspendovan, tj. certificateHold.
openssl ca -revoke certs/s2.cer -crl_reason certificateHold -config openssl.cnf
openssl ca -gencrl -out crl/lista1.crl -config openssl.cnf
