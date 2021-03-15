#!/bin/bash

echo "What directory would you like to enter?"
echo $(ls -la | egrep '^d' | awk '{print $9}')
read input
cd $input
echo $(pwd)
echo "Files Changed:"
files=`ls -pa | egrep -v '/$'`
for file in "${files[@]}"
do
chmod 777 $file
echo $file
done
