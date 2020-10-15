#!/bin/bash
for i in {1..100}
do
	DIFF=$(diff kljucevi/public/key$i.pem public.pem | awk 'NR==1')
	if [ "$DIFF" == "" ]
	then
		echo "key$i is in ca.pem."
		break
	fi
done
