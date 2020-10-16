#!/bin/bash
mkdir keys ; mv *.key keys/
#Provjerimo sa kakvim kljucevima radimo.
for i in {1..150}; do openssl rsa -in keys/key$i.key -noout -text -inform DER; done 2>/dev/null
#Kako nista nije ispisano na ekran mozemo da pretpostavimo da su kljucevi RSA PEM formata.
#Da li su svi private? Nismo sigurno, pokusajmo izdvojiti public iz svih kljuceva, iz onih koji ne uspije znaci da su vec bili public.
mkdir keys/public
for i in {1..150}; do openssl rsa -in keys/key$i.key -inform PEM -pubout -out keys/public/key$i.pem; done 2>/dev/null
#Provjerimo koliko smo dobili kljuceva.
ls -l keys/public/ | sed "1d" | wc -l
#Dobili smo ukupno 150.

#Dalje trebamo da procitamo sadrzaj jks i p12 datoteke, jer mogu da sadrze vise kljuceva sa razl. alias-ima koje zatim trebamo da izbacimo van. Svaki certifikat unutar sadrzi javni kljuc!
openssl pkcs12 -in store.p12 -info
#Unutra ima ukupno 7 sertifikata, s1-6 + root. Rucno kopirajmo sertifikate iz konzole u fajlove.
mkdir certs
touch certs/p12-s{0..6}.pem #p12-s0.pem ce biti root sertifikat iz p12 datoteke!
openssl pkcs12 -in store.p12 -info > p12.info
#Sada iz svih tih sertifikata izvucemo public kljuceve.
mkdir keystore-keys
for i in {0..6}; do openssl x509 -in certs/p12-s$i.pem -pubkey -noout > keystore-keys/p12-key-s$i.pem; done

#Slican postupak uradimo i za jks datoteku.
keytool -list -keystore store.jks
#JKS datoteka ima s1-6 + root sertifikat. Slicna situacija kao i u p12.
keytool -export -alias s1 -file certs/jks-s1.pem -keystore store.jks -storepass sigurnost
keytool -export -alias s2 -file certs/jks-s2.pem -keystore store.jks -storepass sigurnost
keytool -export -alias s3 -file certs/jks-s3.pem -keystore store.jks -storepass sigurnost
keytool -export -alias s4 -file certs/jks-s4.pem -keystore store.jks -storepass sigurnost
keytool -export -alias s5 -file certs/jks-s5.pem -keystore store.jks -storepass sigurnost
keytool -export -alias s6 -file certs/jks-s6.pem -keystore store.jks -storepass sigurnost
keytool -export -alias root -file certs/jks-s0.pem -keystore store.jks -storepass sigurnost

#Dalje izbacujemo kljceve iz sertifikata. Sertifikati su bili u DER formatu.
for i in {0..6}; do openssl x509 -in certs/jks-s$i.pem -inform DER -pubkey -noout > keystore-keys/jks-key-s$i.pem ; done

#Napisimo skriptu za pronalazk kljuca u oba keystore-a
touch script.sh && chmod 777 script.sh
./script.sh
#Kljuc 86 i 98 - key86.key i key98.key su rjesenja zadatka, tj. to su kljuc koji se nalazi u obje datoteke, jks i pkcs12.
