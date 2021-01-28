#!/bin/bash
mkdir pass && mv pass*.txt pass/
#Datoteka sadrzaj.crypt sadrzi salt.
#Potreban nam je privatni RSA kljuc iz 4. zadatka za dekripciju uputstva.
cp ../04/kljuc52.key private.pem
#Dekripcija uputstvo.txt.
mv uputstvo.txt uputstvo.enc
openssl rsautl -decrypt -in uputstvo.enc -out uputstvo.txt -inkey private.pem 
#Prvo trazimo odgovarajucu datoteku sa lozinkom. Provjera potpisa se mora izvrsiti.
for i in {1..100}; do if [[ "$(openssl passwd -apr1 -salt JwjiWEEs pass$i.txt | awk -F"$" '{print $4}')" =~ "X8VsT.87XC8qkVaa8MrYM/" ]]; then echo -e "MATCH: pass$i.txt\nPassword: $(cat pass/pass$i.txt)"; break; fi; done
#Dobijamo:
#MATCH: pass67.txt
#Password: lozinka67
#Dekriptujemo sadrzaj.crypt na sljedeci nacin:
openssl des-ede-cfb -d -in sadrzaj.crypt -out sadrzaj.txt -k lozinka67 -md md5
#Rjesenje zadatka je sadrzaj.txt datoteka.
