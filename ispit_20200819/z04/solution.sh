#!/bin/bash
mkdir kljucevi && mv *.key kljucevi/
#Ako je datoteka sifrovana asimetricnim algoritmom, to mora biti RSA, ne moze DSA (samo potpis). Za dekripciju nam trebaju privatni kljucevi, tako da ako medju datim kljucevima ima javnih njih odbacujemo.
#Datoteka izlaz.txt je u base64 formatu. Dekodujmo ju je.
mv izlaz.txt izlaz.base64
openssl enc -d -base64 -in izlaz.base64 -out izlaz.txt
#Pokusajmo procitati kljuceve da vidimo u kakvom su formatu, pem, der ili da nisu mozda base64 kodovani.
ls -l kljucevi/ | sed "1d" | wc -l #27 kljuceva ukupno
#Prvo preimenujemo prvih 9 kljuceva jer njihove ime predstavlja poteskocu prilikom rada sa for petljom.
for i in {1..9}; do mv kljucevi/kljuc0$i.key kljucevi/kljuc$i.key; done
#Sada pokusajmo da ih procitamo kao da su svi u PEM formatu.
for i in {1..27}; do openssl rsa -in kljucevi/kljuc$i.key -inform PEM -noout -text ; done
#Niti jedan nije uspjesno procitan. Pokusajmo sa DER.
for i in {1..27}; do openssl rsa -in kljucevi/kljuc$i.key -inform DER -noout -text ; done
#Nisu opet svi procitani. Mozda imamo DSA uljeza. Pokusajmo procitati DSA PEM kljuceve.
for i in {1..27}; do openssl dsa -in kljucevi/kljuc$i.key -inform PEM -noout -text ; done
#Uspjesno su procitani neki kljucevi. Pokusajmo sada DSA DER.
for i in {1..27}; do openssl dsa -in kljucevi/kljuc$i.key -inform DER -noout -text ; done
#I takvi kljucevi postoje.
#PEM DSA kljucevi imaju lijepo citljiv zapis kada se odradi cat funkcija nad datotekom. Mozemo filtrirati kljuceve na taj nacin
mkdir kljucevi/bad
for i in {1..27}; do TEXT=$(cat kljucevi/kljuc$i.key | awk 'NR==1'); if [[ "$TEXT" =~ "DSA" ]]; then mv kljucevi/kljuc$i.key kljucevi/bad/kljuc$i.key; fi; done 2>/dev/null
#Sada smo se uspjesno rijesili DSA PEM kljuceva! Rijesimo se i DSA DER kljuceva.
for i in {1..27}; do TEXT=$(openssl dsa -in kljucevi/kljuc$i.key -inform DER -noout -text | awk 'NR==1'); if [[ "$TEXT" =~ "Private" ]]; then mv kljucevi/kljuc$i.key kljucevi/bad/kljuc$i.key; fi; done 2>/dev/null
#Sada su nam ostali samo RSA kljucevi u DER formatu i moguci base64 kodovani kljucevi. Prebacimo RSA u kljuceve u podfolder RSA.
mkdir kljucevi/RSA
for i in {1..27}; do TEXT=$(openssl rsa -in kljucevi/kljuc$i.key -inform DER -noout -text | awk 'NR==1'); if [[ "$TEXT" =~ "Private" ]]; then mv kljucevi/kljuc$i.key kljucevi/rsa/kljuc$i.key; fi; done 2>/dev/null
#Ostala su tri kljuca, 18, 25 i 27. Rucno ih provjeravamo tako sto cemo procitati njihov sadrzaj.
#Svi izgledaju da su base64 kodovani. Kljucevi 25 i 27 izgledaju identicno. Provjerimo.
diff kljucevi/kljuc25.key kljucevi/kljuc27.key 
#Jeste, identicni su, pa brisemo kljuc 25, jer je tako lakse zbog for petlje (1..27).
rm kljucevi/kljuc25.key
#Dekodujmo kljuc 18 i 27.
openssl enc -d -base64 -in kljucevi/kljuc18.key -out kljucevi/kljuc18-dec.key
openssl enc -d -base64 -in kljucevi/kljuc27.key -out kljucevi/kljuc27-dec.key
#Oba nisu u citljivom formatu pa su oni sigurno u DER formatu. Pitanje je da li su RSA ili DSA. Provjerimo.
openssl rsa -in kljucevi/kljuc18-dec.key -inform DER -noout -text #Kljuc 18 je RSA u DER formatu!
openssl rsa -in kljucevi/kljuc27-dec.key -inform DER -noout -text #Kljuc 27 nije uspjesno procita, sto znaci da je DSA u DER formatu.
mv kljucevi/kljuc27* kljucevi/bad
rm kljucevi/kljuc18.key && mv kljucevi/kljuc18-dec.key kljucevi/RSA/kljuc18.key
#Sve sto je ostalo jeste da RSA kljuceve konvertujemo u PEM iz DER formata.
for i in {8..26}; do openssl rsa -in kljucevi/RSA/kljuc$i.key -inform DER -out kljucevi/kljuc$i.key -outform PEM; done 2>/dev/null
#Dekriptujmo izlaz.txt datoteku sa pronadjenim kljucevima.
mkdir ulazi
for i in {8..26}; do openssl rsautl -decrypt -in izlaz.txt -out ulazi/ulaz$i.txt -inkey kljucevi/kljuc$i.key; done 2>/dev/null
#Kada pokrenemo sljedecu komandu vidimo da su sve datoteke prazne osim jedne, a to je ulaz18.txt koju je dekriptovao kljuc18.key
ls -l ulazi/
cat ulazi/ulaz18.txt #Sadrzaj: "Ulazna datoteka sadrzi smislen tekst."
#Rjesenje je kljuc18.key
