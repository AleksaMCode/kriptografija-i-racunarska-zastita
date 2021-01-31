#!/bin/bash
#izlaz.txt je base64 kodovana datoteka. Dekodujmo ju je.
mv izlaz.txt izlaz.base64
openssl enc -d -base64 -in izlaz.base64 -out izlaz.txt
#Mozemo vidjeti da je datoteka enkriptovana koristenjem salt-a.
#Datoteku otisci.enc može pročitati samo vlasnik sertifikata koji je korišten za serversku autentikaciju u 6. zadatku. Ovo znaci da sa odgovarajucim RSA kljucem mozemo dekriptovati datoteku otisci.enc.
openssl pkcs12 -in ../server.p12 -nocerts -out private.key
openssl rsautl -decrypt -in otisci.enc -out otisci.txt -inkey ../06/private/private4096.key
#Izdvojimo samo otisak, tj. odbacimo naziv algoritma i salt.
while IFS= read -r digest; do echo "$digest" | awk -F"$" '{print $4}' >> otisci-digests.txt; done < otisci.txt
#Napravimo listu simetricnih algoritama u openssl-u. Postoji jos nekoliko algoritama koja ova komanda nece ispisati usljed verzije openssl, pa zbog toga ovaj zadatak nece biti moguce rijesti. npr. idea je izacen algoritam koji je ovdje koristen.
openssl enc -ciphers | sed "1d" | tr -s " " "\n" | cut -c2- > list.algos
#Napisimo skriptu koja pronalazi match izmedju algoritama i hash-eva.
touch script.sh && chmod +x script.sh
./script.sh 2>/dev/null
#Dobili smo listu odgovarajucih algoritama - algos.txt
#Napisimo skriptu koja ce pokusati dekriptovati izlaz.txt
mkdir ulazi/
touch script-decrypt.sh && chmod +x script-decrypt.sh
./script-decrypt.sh 2>/dev/null
#Rjesenje je dobijeno sa aes-256-cbc. U dekriptovanoj datoteci stoji "Uspjesno ste dekriptovali sifrat."
