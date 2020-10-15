#!/bin/bash
while IFS= read -r dgst
do
	for i in {1..50} #za ulaze
	do
		openssl dgst -$dgst -out otisak.txt ulazi/ulaz$i.txt
		VAR1=$(cat otisak.txt)
		rm otisak.txt

		for j in {1..10} #za otiske
		do
			VAR2=$(cat otisci/otisak$j.txt)
			if [[ "$VAR1" =~ "$VAR2" ]]
			then
				echo "ulaz$i.txt + $dgst = otisak$j.txt"
				break
			fi
		done
	done
done < dgst.algos
