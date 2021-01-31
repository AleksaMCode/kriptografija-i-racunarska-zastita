#!/bin/bash
#Treba prvo otici na web adresu, skinuti sertifikat u folder.
#Izvadimo javni kljuc iz sertifikata.
openssl x509 -in cert.pem -inform pem -pubkey -noout > public.pem
#Zatim sa tim javnim kljucem enkriptujemo ulaz.txt datoteku.
openssl rsautl -encrypt -in ulaz.txt -out izlaz.enc -inkey public.pem -pubin
