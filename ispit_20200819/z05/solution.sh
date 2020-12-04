#!/bin/bash
#Trebamo da napravimo pkcs12 datoteku za klijentsku autentikaciju.
#Imamo ca.pem, client.pem, jos nam samo trebaju odgovarajuci kljucevi.
mkdir -p keys/public && mv *.key keys/
#Pogledajmo kakve sve kljuceve imamo date zadatkom.
for i in {1..100}; do openssl rsa -in keys/kljuc$i.key -inform PEM -noout -text ; done
#Izgleda da su svi RSA PEM formata kljucevi. "Izvucimo javni kljuc iz client.pem, javni iz ostalih kljuceva, pa onda radimo match-ing.
for i in {1..100}; do openssl rsa -in keys/kljuc$i.key -pubout -out keys/public/key$i.pem; done 2>/dev/null
openssl x509 -in client.pem -pubkey -noout > client-pub.pem
for i in {1..100}; do DIFF=$(diff client-pub.pem keys/public/key$i.pem); if [ "$DIFF" == "" ]; then echo "Solution is key $i" && mv keys/kljuc$i.key client-key.pem; break; fi; done
#Kreirajmo sada pkcs12 datoteku.
openssl pkcs12 -export -out client.p12 -inkey client-key.pem -certfile ca.pem -in client.pem
#Sada trebamo importovati client.p12 u browser, a zatim treba da posjetimo datu adresu, gdje cemo dobiti tekst zadatka.
#Prefernces/Privacy & Security/Certificates/View Certificates.../Import...
