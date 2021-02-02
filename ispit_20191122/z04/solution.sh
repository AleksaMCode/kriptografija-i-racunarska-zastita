#!/bin/bash
#Napravimo datoteku koja ce sadrzati sve otiske i salt-ove.
touch digest.list
#Napravimo tri liste za salt.
touch salt-{crypt,apr1,1}.list
#Napisimo skriptu za provjeru otisaka.
touch script.sh && chmod +x script.sh
./script.sh crypt salt-crypt.list
#MATCH: lozinka1 -> /xFhLMtByO6L.
#MATCH: lozinka2 -> sU8A30CROnL8g
#MATCH: lozinka3 -> 5vr2YauhmOX5w
./script.sh 1 salt-1.list
#MATCH: lozinka4 -> $1$kripto$RT7SFbNY9aRlRcjfK5lCy1
#MATCH: lozinka5 -> $1$lozinka1$TKGaS2jMi70gzV36eTA3E.
#MATCH: lozinka8 -> $1$u51B98Yf$grrpPHY33B6AWXrQOZien0
./script.sh apr1 salt-apr1.list
#MATCH: lozinka6 -> $apr1$xyzopqr1$6mEsgSDtbA7SmgU1qWZue1
#MATCH: lozinka7 -> $apr1$dzdgPGea$ernIlRpjNUXmduY.NsQP31

