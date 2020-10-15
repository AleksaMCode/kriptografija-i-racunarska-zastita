#!/bin/bash
for i in {1..30}
do
	OTISAK=$(openssl passwd -apr1 -salt lozinka1 lozinka$i)
	if [[ "$OTISAK" =~ "NayNtGqjZ5FzvSulsQvaa." ]]
	then
		echo "lozinka$i + -apr1 algo + salt lozinka1 -> NayNtGqjZ5FzvSulsQvaa."
	fi

	OTISAK=$(openssl passwd -apr1 -salt lozinka7 lozinka$i)
	if [[ "$OTISAK" =~ "EneC7HhVrfMd5p6KWT8VT." ]]
	then
		echo "lozinka$i + -apr1 algo + salt lozinka7 -> EneC7HhVrfMd5p6KWT8VT."
	fi

	OTISAK=$(openssl passwd -apr1 -salt wAgnh5WA lozinka$i)
	if [[ "$OTISAK" =~ "CyPYmkLRTzbSN1fIQROnu1" ]]
	then
		echo "lozinka$i + -apr1 algo + salt wAgnh5WA -> CyPYmkLRTzbSN1fIQROnu1"
	fi
done
