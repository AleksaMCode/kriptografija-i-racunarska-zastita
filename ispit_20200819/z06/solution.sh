#!/bin/bash
mkdir sertifikati && mv *.crt sertifikati/
#Ekportujmo prvo RSA privatne kljuceve iz pkcs12 datoteka pa onda iz njih "izvadimo" javne kljuceve sa kojima radimo matching sa nasim datim kljuc.key javnim RSA kljucem.
mkdir sertifikati/{private,public}
for i in {1..21}; do openssl pkcs12 -in sertifikati/cert$i.crt -nocerts -out sertifikati/private/key$i.pem; done
#Nismo dobili kljuceve. Kada bolje pogledamo to nisu pkcs12 datoteke vec sertifikati.
rm -rf sertifikati/private
#Izdvojimo iz sertifikata javne kljuceve.
for i in {1..21}; do openssl x509 -in sertifikati/cert$i.crt -pubkey -noout > sertifikati/public/key$i.pem; done
#Komdanda nije prosla. Vjerovatno zato sto su DER formatu. Pokusajmo ponovo
for i in {1..21}; do openssl x509 -in sertifikati/cert$i.crt -inform DER -pubkey -noout > sertifikati/public/key$i.pem; done
#Dobili smo RSA kljuceve.
for i in {1..21}; do DIFF=$(diff sertifikati/public/key$i.pem kljuc.key); if [ "$DIFF" == "" ]; then echo "Solution is key $i" && cp sertifikati/cert$i.crt .; break; fi; done
#Ispis je "Solution is key 15". Meni nije jasno sta da radimo sa tim sertifikatom. Ja nisam dobio 21 pkcs12 datoteku vec 21 sertifikat iz kojeg samo mogu izvaditi javni kljuc koji mi nije od mnogo koristi. Dobio sam jednu pkcs12 datoteku iz koje mogu da izvucem private kljuc.
openssl pkcs12 -info -in cert.p12 -nocerts -passin pass:sigurnost -passout pass:sigurnost > private.key
openssl rsa -in private.key -pubout -out public.key
diff public.key kljuc.key #Da to je taj kljuc!
rm public.key
mkdir {certs,newcerts,requests,private,crl}
touch index.txt crlnumber
echo a1 > serial #2. sertifikat treba da ima 0xA1 serijski broj
mv private.key private/
#Podesimo openssl.cnf. Nedostaje default-na vrijednost kao i mogucnost unosa polja organizationName. Dodajmo to! Napomena: Nije dozvoljena izmjena politike sertifikacije!
#Kreirajmo CA tijelo.
openssl req -x509 -new -out root.pem -config openssl.cnf -key private/private.key
#Kreirajmo 3 kljuca, pa 3 zahtjeva s tim da cemo prvi zahtjev napraviti takav da se ne moze potpisati (commonName ostaviti praznim, a ono je obavezno polje).
for i in {1..3}; do openssl genrsa -out private/key$i.pem 2048; done
for i in {1..3}; do openssl req -new -out requests/req$i.pem -config openssl.cnf -key private/key$i.pem; done
#Pokusajmo potpisati 1. zahtjev.
openssl ca -in requests/req1.pem -out cert/s1.srt -config openssl.cnf 
#Nije proslo potpisivanje. Kao razlog smo dobili: "The commonName field needed to be supplied and was missing"

#2. sertifikat:
#basicConstraints=CA:FALSE
#Nemam nikakvih drugi restrikcija, pa ostavljamo ono sto je vec bilo u openssl.cnf datoteci. U serial datoteku smo vec unijeli serial broj za 2. sertifikat.
openssl ca -in requests/req2.pem -out certs/s2.srt -config openssl.cnf -days 1460 #Potpis na 4 godine

#3. sertifikat:
#basicConstraints=CA:TRUE
echo c1 > serial
openssl ca -in requests/req3.pem -out certs/s3.srt -config openssl.cnf -days 3650 #Potpis na 10 godina

#Suspendujmo CA sertifikat, tj. s3.srt.
openssl ca -revoke certs/s3.srt -crl_reason unspecified -config openssl.cnf 
#Napravimo crl listu.
echo 01 > crlnumber
openssl ca -gencrl -out crl/list1.pem -config openssl.cnf 
