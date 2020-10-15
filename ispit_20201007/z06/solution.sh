#!/bin/bash
#Bobov kljuc je u der formatu.
openssl rsa -in Bob/bob.key -inform der -out Bob/bob.pem -outform pem
rm Bob/bob.key
#Kljuc od Alice je u pem formatu.
mv Alice/alice.key Alice/alice.pem

#Poruke su base64 kodovane.
for i in {1..50}; do mv Bob/poruka$i.txt Bob/poruka$i.base64; done
for i in {1..50}; do openssl enc -d -base64 -in Bob/poruka$i.base64 -out Bob/poruka$i.txt; done

for i in {1..50}; do mv Alice/poruka$i.txt Alice/poruka$i.base64; done
for i in {1..50}; do openssl enc -d -base64 -in Alice/poruka$i.base64 -out Alice/poruka$i.txt; done

mkdir Sesijski\ kljucevi/decrypted
#Kako je sesijski kljuc kreairala Alice za Bob, on moze da procita taj sesijski kljuc Tako sto ce izvrsiti dekripciju sa svojim privatnim kljucem.
for i in {1..50}; do openssl rsautl -decrypt -in Sesijski\ kljucevi/sess_key$i.txt -out Sesijski\ kljucevi/decrypted/sess-$i.txt -inkey Bob/bob.pem; done
#Sve datoteke bi trebale biti prazne osim jedne.
find Sesijski\ kljucevi/decrypted/ -type f -size +1c
#Kao rezultat dobijamo "Sesijski kljucevi/decrypted/sess-26.txt".

#Sadrzaj datoteke sess-26.txt:
#Algoritam: AES-256-OFB
#Kljuc: fakultet
#NAPOMENA: u nastavku zadatka (ako bude potrebno), koristiti SHA-1 hash funkciju.

#Pronadjimo poruke.
for i in {1..50}; do openssl aes-256-ofb -d -in Bob/poruka$i.txt -out Bob/msg/poruka$i.txt -k fakultet; done
for i in {1..50}; do openssl aes-256-ofb -d -in Alice/poruka$i.txt -out Alice/msg/poruka$i.txt -k fakultet; done

#Napravimo novi sesijski kljuc za Alisu od Boba. To radimo tako sto Bob Alisinim javnim kljucem enkriptuje sess key.
echo prozvoljna_rijec > sess-new.txt
#Izdvojimo Alice-in javni kljuc.
openssl rsa -in Alice/alice.pem -pubout -out alice-public.key
openssl rsautl -encrypt -in sess-new.txt -out sess-new.sess -inkey alice-public.key -pubin

#Jos napravimo potpis koristeci sha1 algoritam i Bobov privatan kljuc, radi sigurnosti sess kljuca. Ovo nije moralo.
openssl dgst -sha1 -sign Bob/bob.pem -keyform PEM -out sess-new.sign sess-new.sess

#Alisa trazi verifikaciju Bobovog javnog kljuca. Moramo ga potpisati.
openssl rsa -in Bob/bob.pem -pubout -out bob-public.key
openssl dgst -sha1 -sign Bob/bob.pem -keyform PEM -out bob.sign bob-public.key
#bob.sign Alice koristi za provjeru Bobovog javnog kljuca.
