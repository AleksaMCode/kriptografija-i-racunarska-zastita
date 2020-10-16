#!/bin/bash
mkdir {keys,signatures}
mv *.key keys/
mv potpis* signatures/
#Kljuc 73 ima '_' u nazivu koju cemo da obrisemo
mv keys/key73_.key keys/key73.key
#Dohvatimo prvo sve sha algoritme
openssl list --digest-commands | tr -s " " "\n" | grep -E "sha[0-9]+" > sha.algos

#Moramo provjeriti sve kljuceve. Oni koji su vec public cemo samo premjesti i iz ostalih, potencijalno RSA i DSA moramo izvaditi public kljuceve za verifikaciju potpisa.
#Napravimo skriptu koja ce da cita sadrzaj kljuceva i da ih na osnovu toga smjesta u odgovrajuce direktorijume.
mkdir keys/{public,rsa,dsa}
touch script-4-keys.sh && chmod 777 script-4-keys.sh
./script-4-keys.sh

#Potpisi izgledaju kao da su svi kodovani u base64. Dekodujmo ih.
mkdir signatures/decoded
for i in {1..32}; do openssl enc -d -base64 -in signatures/potpis$i.sign -out signatures/decoded/potpis$i.sign; done

#Kreirajmo skriptu koja ce vrsi verifikaciju potpisa datoteke ulaz.txt sa svim mogucim kljucevima prolazeci kroz sve moguce sha algoritme.
#Pokusajmo skriptu pokrenuti nad vec postojecim javnim kljucevima. Mozda nam se posreci pa dobijemo rjesenje.
touch script.sh && chmod 777 script.sh
./script.sh 2>/dev/null
#Nismo dobili rezultat. Znamo da rjesnje nije sigurno jedan od kljuceva koji su vec bili public.

#Provjerimo da li su DER formata RSA kljucevi
for i in {1..33}; do openssl rsa -in keys/rsa/keys$i.key -noout -text -inform DER; done 
#Nisu. Svi su PEM.
#Izdvojimo public kljuceve dalje.
for i in {1..33}; do openssl rsa -in keys/rsa/keys$i.key -inform PEM -pubout -out keys/public/keys$i.key; done 2>/dev/null
#Provjerimo DSA kljuceve i izbacimo public kljuceve iz njih.
for i in {42..78}; do openssl dsa -in keys/dsa/keys$i.key -inform DER -noout -text ; done 2>/dev/null
#Nismo dobili nikakv ispis, pa zakljucujemo da su svi PEM formata. Izbacimo sada public kljuceve.
for i in {42..78}; do openssl dsa -in keys/dsa/keys$i.key -inform PEM -pubout -out keys/public/keys$i.key; done 2>/dev/null

#Sada imamo ukupno 80 javnih kljuceva. Pokrenimo opet skriptu script.sh da bi dobili rjesenje zadatka.
./script.sh 2>/dev/null
#Dobijemo sljedece -> Solution: Key70 + ulaz.txt = potpis23.sign
#Rjesenje je potpis 23.
