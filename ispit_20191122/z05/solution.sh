#!/bin/bash
mkdir keys && mv *.key keys/
#izlaz.enc je base64 kodovan.
mv izlaz.enc izlaz.enc.base64
openssl enc -d -base64 -in izlaz.enc.base64 -out izlaz.enc
#Podesimo prvih 9 kljuceva tako da je lakse raditi sa njima u petlji.
for i in {1..9}; do mv keys/kljuc0$i.key keys/kljuc$i.key; done
#Medju kljucevima ima svacega i RSA i DSA, PEM i DER kljuceva. Nama trebaju samo RSA kljucevi.
mkdir keys/{rsa,dsa}
for i in {1..27}; do if [[ "$(cat keys/kljuc$i.key | awk 'NR==1')" =~ "DSA" ]]; then mv keys/kljuc$i.key keys/dsa/kljuc$i.pem; elif [[ "$(cat keys/kljuc$i.key | awk 'NR==1')" =~ "RSA" ]]; then mv keys/kljuc$i.key keys/rsa/kljuc$i.pem; fi; done 2>/dev/null
#Pokusajmo preostale kljuceve da prebacimo iz der u pem format za RSA.
for i in {1..27}; do openssl rsa -in keys/kljuc$i.key -inform der -out keys/rsa/kljuc$i.pem -outform pem && rm keys/kljuc$i.key; done 2>/dev/null
#Odradimo isto samo za DSA.
for i in {1..27}; do openssl dsa -in keys/kljuc$i.key -inform der -out keys/dsa/kljuc$i.pem -outform pem && rm keys/kljuc$i.key; done 2>/dev/null
#Ostala su nam tri kljuca u base64.
for i in {23..27..2}; do mv keys/kljuc$i.key keys/kljuc$i.key.base64 && openssl enc -d -base64 -in keys/kljuc$i.key.base64 -out keys/kljuc$i.key; done; rm keys/*.base64
#Ostali su nam kljucevi u DER formatu. Mozda RSA, ali mozda i DSA.
for i in {23..27..2}; do openssl rsa -in keys/kljuc$i.key -inform der -out keys/rsa/kljuc$i.pem -outform pem && rm keys/kljuc$i.key; done 2>/dev/null
for i in {23..27..2}; do openssl dsa -in keys/kljuc$i.key -inform der -out keys/dsa/kljuc$i.pem -outform pem && rm keys/kljuc$i.key; done 2>/dev/null
#Svi kljucevi su razvrstani.
for i in {8..26}; do openssl rsautl -decrypt -in izlaz.enc -out ulaz$i.txt -inkey keys/rsa/kljuc$i.pem; done 2>/dev/null
#Obrisimo prazne fajlove koji su nastali usljed dekripcije pogresnim kljucem.
find . -type f -size 0 -delete
#Rjesenje je datoteke ulaz23.txt koja sadrzi tekst "Ulazna datoteka sadrzi smislen tekst."
#Mogli smo i ovako uraditi:
for i in {8..26}; do openssl rsautl -decrypt -in izlaz.enc -out ulaz$i.txt -inkey keys/rsa/kljuc$i.pem; [[ -s ulaz$i.txt ]] || rm ulaz$i.txt; done 2>/dev/null
