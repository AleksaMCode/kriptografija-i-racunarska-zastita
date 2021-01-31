#!/bin/bash
mkdir potpisi/ && mv *.sign potpisi/
#Dato nam je 5 RSA kljuceva u pem formatu. Za validaciju potpisa nam trebaju javni kljucevi.
mkdir public-keys
#Premjestimo sve javne kljuceve.
for i in {1..5}; do if [[ "$(cat kljuc$i.key | awk 'NR==1')" =~ "PUBLIC" ]]; then mv kljuc$i.key public-keys/public$i.pem; fi; done 2>/dev/null
#Preostali kljucevi su private.
for i in {1..5..2}; do openssl rsa -in kljuc$i.key -pubout -out public-keys/public$i.pem && rm kljuc$i.key; done
#Svi potpisi su base64 kodovani.
for i in {1..30}; do openssl enc -d -base64 -in potpisi/potpis$i.sign -out potpisi/potpis$i.txt && rm potpisi/potpis$i.sign; done
#Provjera potpisa.
for i in {1..5}; do for j in {1..30}; do if [[ "$(openssl dgst -sha224 -verify public-keys/public$i.pem -signature potpisi/potpis$j.txt ulaz.txt)" =~ "OK" ]]; then echo "MATCH: SHA224 + KEY$i = potpis$j.sign" && break 2; fi; done; done
#Dobijamo: "MATCH: SHA224 + KEY5 = potpis18.sign".
