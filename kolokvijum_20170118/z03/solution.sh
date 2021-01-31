#!/bin/bash
mkdir opisi && mv opis*.txt opisi/
#sifrat.txt je base64 kodovan.
mv sifrat.txt sifrat.base64
openssl enc -d -base64 -in sifrat.base64 -out sifrat.txt
#Sifrat je salt-ovan.
#Odredimo odgovarajuci opis ciji naziv datoteke ima isti hash kao i trazeni.
for i in {1..720}; do if [[ "$(openssl passwd -apr1 -salt 5xYExKym opis$i.txt | awk -F"$" '{print $4}')" =~ "Bkfh/waMOSHfYgY1SNY3j0" ]]; then echo "MATCH: opis$i.txt" && mv opisi/opis$i.txt .; break; fi; done 2>/dev/null 
#Dobijamo: "MATCH: opis516.txt"
#U datoteci pise sljedece: "Algoritam: DES, nacin rada za SIMETRICNI ALGORITAM: OFB, lozinka: 6siglozinka"
openssl des-ofb -d -in sifrat.txt -out ulaz.txt -k 6siglozinka -md md5
#U dobijenoj datoteci pise: "Odrediti SHA-512 otisak datoteke u kojoj su se nalazili ispravni podaci za dekripciju ove datoteke"
#Trebamo odrediti otisak datoteke opis516.txt koristeci sha512 algoritam.
openssl dgst -sha512 -out otisak.hash opis516.txt 
#Otisak je "512f631f79f6b976fb30ea9810f08bf687bab033fcc92789c94b4d5f8efdecdfb78a4ec72c19ff0093db4389d89068b64351c8af4d85891a74c273df86e3d6fd"
