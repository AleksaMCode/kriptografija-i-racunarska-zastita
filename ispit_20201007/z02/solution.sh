#!/bin/bash
mkdir {otisci,lozinke}
mv lozinka*.txt lozinke/
mv lozinka*.txt lozinke/
#Sifrat je base64 kodovan, treba ga dekodovati
mv sifrat.txt sifrat.base64
openssl enc -d -base64 -in sifrat.base64 -out sifrat.txt #Datoteka je enkriptovana i sadrzi salt.

#Otisci su takodje base64 kodovani. Dekodujmo ih.
for i in {1..3}; do mv otisci/otisak$i.txt otisci/otisak$i.base64; done

#Izdvojimo sve aes algoritme u jednu listu.
openssl enc -ciphers | sed "1d" | tr -s " " "\n" | cut -c2- | grep-E "^aes*" > aes.algos
#Ovo nije proslo zbog verzije, pa sam rucno moramo da ih iz help-a kopiram.

#Napisimo skriput za pronalazenje otisaka.
touch script-otisci.sh && chmod 777 script-otisci.sh
./script-otisci.sh 
#Izlaz je:
#lozinka3 + -apr1 algo + salt lozinka7 -> EneC7HhVrfMd5p6KWT8VT.
#lozinka18 + -apr1 algo + salt lozinka1 -> NayNtGqjZ5FzvSulsQvaa.
#lozinka30 + -apr1 algo + salt wAgnh5WA -> CyPYmkLRTzbSN1fIQROnu1

#Koristimo 3, 18 i 30 lozinke za dekrpiciju. Napisimo skriptu za to.
touch script.sh && chmod 777 script.sh
./script.sh lozinka3 lozinka18 lozinka30 2>/dev/null
./script.sh lozinka3 lozinka30 lozinka18 2>/dev/null
./script.sh lozinka18 lozinka3 lozinka30 2>/dev/null
./script.sh lozinka18 lozinka30 lozinka3 2>/dev/null
./script.sh lozinka30 lozinka3 lozinka18 2>/dev/null #Rjesenje!
./script.sh lozinka30 lozinka18 lozinka30 2>/dev/null
#Dobijemo ispis: "aes-192-cfb + lozinka30-lozinka3-lozinka18 -> Idemo dalje :)!"
#Kljucevi su u redoslijedu njihoog koristenja za dekripciju lozinka30, lozinka3, lozinka18, koristenjem aes-192-cfb algoritma dobija se smilsen sadrzaj "Idemo dalje :)!"
