#!/bin/bash
#client.key je u DER formatu. Konvertujmo ga.
mv client.key client.der
openssl rsa -in client.der -inform DER -out client.key -outform PEM
#Poruke treba dekodovati iz base64 formata.
for i in {1..100}; do mv poruke/poruka$i.txt poruke/poruka$i.base64; done
for i in {1..100}; do openssl enc -d -base64 -in poruke/poruka$i.base64 -out poruke/poruka$i.txt; done
#Sve poruke su kriptovane sa salt-om. Kako da nadjemo koja je poruka namijenjena nama? Dekriptujemo sve sesijske kljuceve, ali cemo samo jednu uspjesno da dekriptujemo sa nasim asimetricnim RSA privatnim kljucem, tj. samo ce jedna datoteka imati smislen ulaz. To ce biti nas kljuc za dekripciju zajedno sa algoritmom koji je naveden u info.txt (simetrican algoritam). info.txt mogu dekriptovati samo korisnici sa kojima server komunicira. Znaci mi bi trebali moci sa nasim privatnim kljucem da to dekriptujemo.
openssl rsautl -decrypt -in info.txt -out info.decripted -inkey client.key 
#Unutar dekriptovane datoteke pise "aes-128-ecb" i to je nas simetricni algoritam.
mkdir sesijski\ kljucevi/decripted
#Sesijski kljucevi nisu base64 kodovani!
for i in {1..50}; do openssl rsautl -decrypt -in sesijski\ kljucevi/sess_key$i.txt -out sesijski\ kljucevi/decripted/ss-key$i.txt -inkey client.key; done 2>/dev/null
#Pronadjimo datoteku koja je veca od 0B.
find sesijski\ kljucevi/decripted/ -type f -size +1c
#Dobijamo "sesijski kljucevi/decripted/ss-key18.txt".

#Ili obrisimo sve datoteke koje su prazne.
find sesijski\ kljucevi/decripted/ -type f -size 0 -delete

#Procitajmo sadrzaj datoteke.
cat sesijski\ kljucevi/decripted/ss-key18.txt #Dobijamo "kriptografija".

#Dekriptujemo dalje poruke.
mkdir poruke/decripted
for i in {1..100}; do openssl aes-128-ecb -d -in poruke/poruka$i.txt -out poruke/decripted/ulaz$i.txt -k kriptografija; done 2>/dev/null
#Poruka koja je namijenjena nama ima smislen sadrzaj!
for i in {1..100}; do TEXT=$(cat poruke/decripted/ulaz$i.txt); echo "poruka$i -> $TEXT"; done 2>/dev/null
#Rezultat pretrage: "poruka38 -> Kako se zove predmet koji polažete danas?"
#Odgovaramo na pitanje, kriptujemo datoteku sa javnim kljucem servera i potpisujemo opentext datoteku sa nasim privatni kljucem koristeci sha1 algoritam.
echo Kriptografija i racunarska zastita > odgovor.txt
openssl x509 -in server.crt -pubkey -noout > server.pem
openssl rsautl -encrypt -in odgovor.txt -out odgovor.encrypted -inkey server.pem -pubin
#Za transport preko interneta je bolje poslati datoteku u base64 formatu.
openssl enc -base64 -in odgovor.encrypted -out odgovor.base64
#Dokaz da sam bas ja poslao poruku.
openssl dgst -sha1 -sign client.key -keyform pem -out odgovor.signature odgovor.txt

#Server zatim dekoduje datoteku iz base64 formata, dektriptuje datoteku koristeci svoj privatni kljuc a zatim verifikuje moj potpis sa dobijenom opentext datotekom koristeci moj javni kljuc.
