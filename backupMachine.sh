#!/bin/bash

echo -e $(ls -pa | egrep -v '/$') "\nWhat file would you like to backup?"
read file
filevar="${file}"
filename="${filevar%.*}"

if [[ -f "$file" ]]
then
    cat $file > "backup"$filename".txt"
else
    echo "This file doesn't exist."
fi
