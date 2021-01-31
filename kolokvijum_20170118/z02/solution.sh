#!/bin/bash
mkdir keys && mv *.key keys/
#sifrat.txt je base64 kodovan.
mv sifrat.txt sifrat.base64
openssl enc -d -base64 -in sifrat.base64 -out sifrat.txt
#Svi dati kljucevi su DER formatu. Medju njima vjerovatno ima i RSA i DSA kljuceva.
#DSA kljucevi nam ne trebaju, tako da cemo petljom proci kroz sve kljuceve i konvertovacemo kljuceve iz der u pem format. Error poruke koje ce se javiti usljed pokusaja konverzije dsa kljuca koristenjem komande za rsa kljuc cemo ignorisati.
mkdir keys/rsa
for i in {1..200}; do openssl rsa -in keys/kljuc$i.key -inform der -out keys/rsa/key$i.pem -outform pem; done 2>/dev/null
#Dobili smo ukupno 75 kljuceva.
ls keys/rsa/ -1 | wc -l
#Preostaje nam da pokusamo dekriptovati sifrat.txt koristenjem rsa privatnih kljuceva.
for i in {1..200}; do openssl rsautl -decrypt -in sifrat.txt -out ulaz$i.txt -inkey keys/rsa/key$i.pem; done 2>/dev/null
#Obrisimo sve prazne fajlove tako da nam ostane samo nase rjesenje, tj. ulazna datoteka.
find . -size 0 -delete
#Ostala je datoteka ulaz139.txt sto znaci da je kljuc139.key odgovarajuci kljuc.
cat ulaz139.txt
#Sadrzaj datoteke je: "Vazduh treperi kao da nebo gori"
