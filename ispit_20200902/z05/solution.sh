#!/bin/bash
#client.key je u DER formatu. Konvertujmo ga u PEM
openssl rsa -in client.key -inform DER -out client.pem -outform PEM
#info.txt izgleda kao da je kriptovan. Kako sam ja korisnik koji komunicira sa serverom pokusat cemo dekriptovati sa nasim privatnim kljucem client.pem-om.
openssl rsautl -decrypt -in info.txt -out info.dec -inkey client.pem 
#Tacno, nasa slutnja je ispala tacna. Nakon dekripcije mozemo da procitamo sadrzaj info.dec i unutar je napisano ime algoritma aes-128-ecb.
#U jednoj od 50 sesijskih kljuceva se nalazi kljuc (string) koji koristimo zajedno sa algoritmom iz info.dec da dekriptujemo nasu poruku medju 100 dostupnih poruka.
mkdir sesijski\ kljucevi/decripted
for i in {1..50}; do openssl rsautl -decrypt -in sesijski\ kljucevi/sess_key$i.txt -out sesijski\ kljucevi/decripted/key$i.txt -inkey client.pem ; done 2>/dev/null
for i in {1..50}; do RES=$(cat sesijski\ kljucevi/decripted/key$i.txt); if [[ "$RES" != "" ]]; then echo "session-key$i -> $RES"; break; fi; done
#Dobijamo "session-key41 -> kriptografija". Znaci nasa lozinka je kriptografija.
#Mozemo primjeti da su sve ulazne datoteke base64 kodovane. Pvo ih dekodujemo pa onda dekriptujemo.
mkdir poruke/decoded
for i in {1..100}; do openssl enc -d -base64 -in poruke/poruka$i.txt -out poruke/decoded/poruka$i.dec; done
#Dobijamo dekodovane poruke koje imaju salt.
mkdir poruke/decripted
for i in {1..100}; do openssl aes-128-ecb -d -in poruke/decoded/poruka$i.dec -out poruke/decripted/poruka$i.txt -k kriptografija; done 2>/dev/null
#Sada pogledajmo koja od njih ima smislen sadrzaj.
for i in {1..100}; do echo -n "File poruka$i with a message -> " && cat poruke/decripted/poruka$i.txt && echo; done
#Jedini smislen odgovor je "File poruka29 with a message -> Kako se zove predmet koji polažete danas?"
#Sada treba odgovoriti na tu pitanje i onda omoguciti da samo server moze tu poruku procitati. Napisemo odgovor u odgovor.txt pa onda tu datoteku kripujemo sa javnim kljucem od servera. Javni kljuc izvadimo iz server sertifikata.
echo "Kriptografija i racunarska zastita" > odgovor.txt
openssl x509 -in server.crt -pubkey -noout > server-public.pem
openssl rsautl -encrypt -in odgovor.txt -out odgovor.txt -inkey server-public.pem -pubin
#Zadatak jos zahtjeva da se odgovor potpise tako da server zna da smo to mi bas odgovorili. Koristili smo sha1 algoritam za potpis.
openssl dgst -sha1 -sign client.pem -keyform PEM -out odgovor.signature odgovor.txt
