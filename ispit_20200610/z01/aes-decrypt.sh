#!/bin/bash
while IFS= read -r password
do
    openssl aes-256-ecb -d -in sifrat.txt -out sifrat-$password.txt -k $password
done < aes-keys.txt
