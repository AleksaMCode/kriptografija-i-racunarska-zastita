#!/bin/bash
#ca.pem je base64 kodovan pa ga treba prvo dekodovati.
mv ca.pem ca.base64
openssl enc -d -base64 -in ca.base64 -out ca.pem
#Konvertujmo u ovaj DER u PEM sertifikat
openssl x509 -in ca.pem -inform DER -out ca.pem -outform PEM
mkdir keys/ ; mv *.key keys/

#Otisak je takodje base64 kodovan pa ga je potrebno dekodovati.
mv otisak.txt otisak.base64
openssl enc -d -base64 -in otisak.base64 -out otisak.txt
#Nadjimo sve sha algoritme i stavimo ih u listu sha.algos
openssl list --digest-commands | tr -s " " "\n" | grep -E "sha[0-9]+" > sha.algos

#Napisimo skriptu za koja ce za svaki kljuc da izracuna otisak koristeci sve sha algoritama i onda ce da pokusa da nadje match sa zadanim otiskom iz otisak.txt.
touch script-keyotisak.sh && chmod 777 script-keyotisak.sh
./script-keyotisak.sh 2>/dev/null
#Dobijamo "Solution: SHA256(keys/kljuc40.key)= 77bd8a5bb31a09a59d6de138525dfc675d9105d48867b9d312761171c124dc9e"
#Ovoliko racunanje nije bilo potrebno, jer smo na osnovu duzine otiska iz otisak.txt mogli da zakljucimo da se koristio sha256 algoritam.

#Da li smo do kljuca mogli doci i na drugi nacin? Izbacimo public kljuc iz ca.pem datoteke i iz svih privatnih kljuceva i onda radimo poredjenje dok ne dobijemo match. Pokusajmo match-ovati public kljuc od kljuc40.key.
cp keys/kljuc40.key private.key
openssl rsa -in private.key -pubout -out public.pem
#Izvlacimo public key iz ca.pem datoteke.
openssl x509 -in ca.pem -pubkey -noout > publicCA.pem
diff public.pem publicCA.pem
#Nista nije ispisano sto znaci da je doslo do match-ovanja. Znaci mogli smo i ovako uraditi ovaj dio zadatka.
rm public.pem publicCA.pem

mkdir {certs,newcerts,requests,crl,private}
touch index.txt crlnumber ; echo 01 > seria1l
mv private.key private
#Obratiti paznju na [ policy_match ] unutar openssl.cnf datoteke jer nema sva polja koja sadrzi ca.pem! Neka polja treba obrisati a nek dodati.

#Kreiramo dva sertifikata. Prvo kreiramo kljuceve.
for i in {1..2}; do openssl genrsa -out private/key$i.pem 2048; done
#Za prvi sertifikat trebamo imati:
#basicConstraints=CA:FALSE
#keyUsage = keyAgreement
#extendedKeyUsage = serverAuth

#Napravimo request za prvi sertifikat:
openssl req -new -out requests/req1.csr -config openssl.cnf -key private/key1.pem -days 180
#Potpisimo zahtjev:
openssl ca -in requests/req1.csr -config openssl.cnf -out certs/s1.pem -days 180

#Za drugi sertifikat trebamo imati:
#basicConstraints=CA:TRUE
#keyUsage = cRLSign
#extendedKeyUsage = clientAuth
openssl req -new -out requests/req2.csr -key private/key2.pem -config openssl.cnf -days 36500
openssl ca -in requests/req2.csr -out certs/s2.pem -config openssl.cnf -days 36500

#Napravimo backup od index.txt radi kasnije reaktivacije sertifikata. Nismo ovo morali raditi, ali bi smo onda morali rucno aktivirati sertifikate tako sto bi smo R promijenili u V na pocetku linije za svaki sertifikat i morali bi smo obrisati razlog povlacenja.
cp index.txt index-backup.txt

#Suspendujmo sertifikate. Razlog nije specifikovan pa cemo uzeti unspecified.
openssl ca -revoke certs/s1.pem -crl_reason unspecified -config openssl.cnf
openssl ca -revoke certs/s2.pem -crl_reason unspecified -config openssl.cnf

echo 22 > crlnumber #Broj 1. liste, 0x22=34 - kad se otvori crl lista pisace 34 jer je prikaz u dekadskom sistemu
#Revocation date (datum ukidanja) je 16.10.2020. sto je 30 dana razlike od datuma ispita 16.10.2020.
openssl ca -gencrl -out crl/lista1.crl -config openssl.cnf -days 30

#Reaktivirajmo sertifikate. Ako sad kreiramo lista2.crl ona ce biti prazna - "No Revoked Certificates" ce biti napisano.
cp index-backup.txt index.txt

echo 24 > crlnumber #Broj 2. liste
openssl ca -gencrl -out crl/lista2.crl -config openssl.cnf -days 60
