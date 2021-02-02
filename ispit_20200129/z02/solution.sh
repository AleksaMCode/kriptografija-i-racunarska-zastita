#!/bin/bash
#otisak datoteku treba dekodovati iz base64 formata.
mv otisak otisak.base64
openssl enc -d -base64 -in otisak.base64 -out otisak.txt
touch script.sh && chmod +x script.sh
./script.sh 2>/dev/null

