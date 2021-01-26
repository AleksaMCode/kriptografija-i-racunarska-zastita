#!/bin/bash
openssl dsaparam -out dsa.param 2048
openssl gendsa -des3 -out private.pem dsa.param
#Potpisivanje ulaz.txt datoteke.
openssl dgst -sha1 -sign private.pem -keyform pem -out signature.sign ulaz.txt
#Kodovanje potpisa u base64 format.
openssl enc -base64 -in signature.sign -out signature.base64

mkdir solution
#Ekstrakcija public kljuca.
openssl dsa -in private.pem -pubout -out public.pem
#Konvertovanje u der format kljuca.
openssl dsa -in private.pem -inform PEM -out private.der -outform DER
mv public.pem private.der signature.base64 solution/

#Verifikacija potpisa
openssl dgst -sha1 -verify solution/public.pem -signature signature.sign ulaz.txt
#ili
openssl dgst -sha1 -prverify private.pem -signature signature.sign ulaz.txt
