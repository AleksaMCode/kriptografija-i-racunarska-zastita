#!/bin/bash
for i in {1..50}
do
	openssl rsautl -decrypt -in envelopa.txt -out ulazi/ulaz$i.key -inkey keys/key$i.pem
done
