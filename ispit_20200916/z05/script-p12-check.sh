#!/bin/bash

for i in {1..10}
do
    OTISAK=$(openssl passwd -1 -salt ________ store$i.p12)
    if [[ "$OTISAK" =~ "thXLGgfGaW2ar6Gq5WaZV." ]]
    then
        echo "Correct p12 file is store$i.p12."
    fi
done
