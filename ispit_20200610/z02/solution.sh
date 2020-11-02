#!/bin/bash
mkdir keys && mv *.key keys/
mkdir env && mv env*.txt env/
#sifrat.txt je base64 kodovan, pa ga je potrebno dekodovati.
mv sifrat.txt sifrat.base64
openssl enc -d -base64 -in sifrat.base64 -out sifrat.txt
#Vidimo da je enkriptovan tekst Salt-ovan.
#Sve envelope su base64 kodovane. Prvo ih dekodujemo.
for i in {1..20}; do mv env/env$i.txt env/env$i.base64; openssl enc -d -base64 -in env/env$i.base64 -out env/env$i.txt; done
#Svi kljucevi su RSA u PEM formatu.
mkdir env/aes-key
#Odradimo dekripciju svih envelopa koristeci sve kljuceve. Kreiramo 20x20 datoteka, gdje ce vecina biti prazne.
for i in {1..20}; do for j in {1..20}; do openssl rsautl -decrypt -in env/env$i.txt -out env/aes-key/env$i-key$j.txt -inkey keys/kljuc$j.key; done; done 2>/dev/null
#Obrisimo sve datoteke velicine 0b
find env/aes-key/* -size 0 -print -delete
#Ispisimo sadrazaj preostalih datoteka, tj. datoteka cija je vilicina > 0b.
for file in $(ls env/aes-key); do echo -n "$file: " && cat env/aes-key/$file; done
#Dobijamo:
#env11-key20.txt: lozinka6
#env15-key7.txt: lozinka19
#env19-key17.txt: lozinka15
#env4-key12.txt: lozinka9
#env7-key3.txt: lozinka2
#Imamo ukupno 5 lozinki koje moramo testirati prilikom dekripcije sifrat.txt datoteke koristeci aes-256-ecb.
cat env/aes-key/* > aes-keys.txt
#Napisimo skriptu za dekripciju.
touch aes-decrypt.sh && chmod +x aes-decrypt.sh
./aes-decrypt.sh
#Pronadjimo otvoreni tekst. Samo jedna datoteka od ukupno 5 kreiranih ce imati smislen sadrzaj.
for opentext in $(ls *loz*); do echo -n "$opentext: " && cat $opentext && echo; done
#sifrat-lozinka19.txt: Bravo, nasli ste rjesenje :).
#Zakljucak: sifrat.txt smo dekriptovali koristeci aes-256-cbc sifrom lozinka19. Sadrzaj otvorenog teksta: " Bravo, nasli ste rjesenje :)"
