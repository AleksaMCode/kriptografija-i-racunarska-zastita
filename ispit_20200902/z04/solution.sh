 cp ../z06/openssl.cnf .
mkdir {certs,newcerts,request,crl,private}
touch index.txt crlnumber
echo 01 > serial
#Podesimo openssl.cnf datoteku.
#Napravimo kljuca sa ca sertifikat, tj. za s.cer.
openssl genrsa -out private/private.key 4096
#Napravimo s.cer CA.
openssl req -x509 -new -key private/private.key -out s.cer -config openssl.cnf 
#Napravimo 2 kljuca za klijentske sertifikate.
for i in {1..2}; do openssl genrsa -out private/key$i.pem 2048; done
#Napravimo 2 zahtjeva.
for i in {1..2}; do openssl req -new -out request/req$i.csr -key private/key$i.pem -config openssl.cnf ; done
#Potpisimo oba zahjeva koristeci s.cer, vodeci racuna da se njihovi brojevi sertifikata razliku za 3.
openssl ca -in request/req1.csr -out certs/k1.cer -config openssl.cnf 
echo 04 > serial
openssl ca -in request/req2.csr -out certs/k2.cer -config openssl.cnf

mkdir solution
#Kreirajmo jks za serversku sertifikaciju. Prvo kreiramo pksc12 datoteku koju onda konvertujemo u jsk.
openssl pkcs12 -export -out solution/server.p12 -inkey private/private.key -in s.cer 
keytool -list -keystore solution/server.p12 #Ovo je trazeni keystore iz zadatka.
#Napravimo dve pkcs12 datoteke iz klijentskih sertifikata
openssl pkcs12 -export -out solution/client1.p12 -inkey private/key1.pem -in certs/k1.cer -certfile s.cer
openssl pkcs12 -export -out solution/client2.p12 -in certs/k2.cer -inkey private/key2.pem -certfile s.cer
#Podesimo jos samo server.xml datoteku.
mv server.xml solution/
