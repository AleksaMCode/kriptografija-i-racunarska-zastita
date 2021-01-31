#!/bin/bash
mkdir lozinke && mv lozinka*.txt lozinke
#Dekodujemo sifrat.txt iz base64 formata.
mv sifrat.txt sifrat.base64
openssl enc -d -base64 -in sifrat.base64 -out sifrat.txt
#Enkriptovan fajl je salt-ovan.
#Izdvojimo sve catst5 algoritme dostupne u openssl-u.
openssl enc -ciphers | sed 1d | tr -s " " "\n" | cut -c2- | grep cast5-* > cast5.algos
#Napisimo skriptu koja ce vrsiti dekripciju sifrata sa svim mogucim siframa i svim mogucim algoritmima.
touch script.sh && chmod +x script.sh
./script.sh 2>/dev/null
