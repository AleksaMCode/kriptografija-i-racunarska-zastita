#!/bin/bash
mkdir keys && mv *.key keys/
#Svi kljucevi su RSA u PEM formatu.
#Izdvojimo privatni kljuc iz cert.pfx datoteke.
openssl pkcs12 -in cert.pfx -nocerts -out priv-pass_protected.key -passin pass:sigurnost -passout pass:sigurnost
#Potrebno je preimenovati prvih 9 kljuceva iz klju0n u kljucn radi lakseg rada prilikom koristenja for petlje.
for i in {1..9}; do mv keys/kljuc0$i.key keys/kljuc$i.key; done
for i in {1..20}; do if [[ "$(diff priv-pass_protected.key keys/kljuc$i.key)" == "" ]]; then echo "Match: kljuc$i"; fi; done;
#Nema match-a. Zato sto je priv-pass_protected.key zasticen lozinkom pa je datoteka drugacija od onih koje nisu zasticene lozinkom. Konvertujmo kljuc sa lozinkom u kljuc bez lozinke i pokusajmo ponovo.
openssl rsa -in priv-pass_protected.key -out priv.key -passin pass:sigurnost
for i in {1..20}; do if [[ "$(diff priv.key keys/kljuc$i.key)" == "" ]]; then echo "Match: kljuc$i" && mv keys/kljuc9.key private/private.key; fi; done;
#Dobijamo: "Match: kljuc9"

mkdir {certs,newcerts,crl,private,requests}
touch index.txt crlnumber
echo 01 > serial

#Kreirajmo CA tijelo koji ce se zvati root.pem.
openssl req -x509 -new -key private/private.key -out root.pem -config openssl.cnf 

#Generisemo tri rsa kljuca, tri zahtjeva, gdje za prvi zahtjev ostavimo commonName praznim da kasnije ne bi mogli potpisati taj zahtjev jer je to obavezno polje definisano u openssl.cnf datoteci.
for i in {1..3}; do openssl genrsa -out private/key$i.pem 2048; done

#Potpis ne smije proci; ostavljamo obavezno polje commonName praznim kod popunjavanja zahtjeva.
openssl req -new -key private/key1.pem -out requests/req1.csr -config openssl.cnf
openssl ca -in requests/req1.csr -config openssl.cnf -out certs/c1.pem

#Za c2.cer:
#basicConstraints=CA:FALSE
openssl req -new -key private/key2.pem -out requests/req2.csr -config openssl.cnf
openssl ca -in requests/req2.csr -config openssl.cnf -out certs/c2.pem -days 730

#Za c3.cer:
#basicConstraints=CA:TRUE
openssl req -new -key private/key3.pem -out requests/req3.csr -config openssl.cnf
openssl ca -in requests/req3.csr -config openssl.cnf -out certs/c3.pem -days 3650

#Potrebno je povuci c2.cer.
openssl ca -revoke certs/c2.pem -crl_reason unspecified -config openssl.cnf 
#Kreiramo crl listu.
echo 01 > crlnumber
openssl ca -gencrl -out crl/list.pem -config openssl.cnf
