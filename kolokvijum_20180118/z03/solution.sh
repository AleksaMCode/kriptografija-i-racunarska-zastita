#!/bin/bash
#izlaz.crypt je base64 kodovan.
mv izlaz.crypt izlaz.base64
openssl enc -d -base64 -in izlaz.base64 -out izlaz.encrypt
#Izdvojimo listu dostupni algoritama.
openssl enc -ciphers | sed "1d" | tr -s " " "\n" | cut -c2- > algos.list
#Pronadjimo odgovarajuci algoritam poredeci otiske.
while IFS= read -r algo; do if [[ "$(openssl passwd -apr1 -salt 1OnpSdQI $algo)" =~ "UMOW0X3RLcR06Goe4UBV30" ]]; then echo "MATCH: $algo"; openssl $algo -d -in izlaz.encrypt -out ulaz.txt -k $algo -md md5; break; fi; done < algos.list
#Dobijamo: "MATCH: camellia-192-cbc" i ulaz.txt sa sadrzajem "Cleartext".
