#!/bin/bash
#Ian Pallares 03-24-2021

function toggle {	#autolist toggle function
    if [ "$auto" -eq "0" ]; then
	auto=1;
    else
	auto=0;
    fi
}

echo "Enter command (or use help):"
close=0; #exits while loop when set to 1
auto=0; #autolist toggle variable
read line
while [ "$close" -eq "0" ]; do
    if [ "$line" = "help" ]; then	#help command
	echo -e " Commands: \n\n\ta - toggles whether explorer relists files in current directory after each command. Default is off. \n\tback (..) - goes to previous directory if possible. \n\tpwd - lists present working directory. \n\titems (ls) - lists items available in current directory, numbered. \n\topen [file or directory name] - opens item specified. \n\topeni [i] - opens the ith item listed in the directory. \n\torganize - creates new directories for each XXXX 000 (CWRU class) formatted file and places all files for that class in there, then internally places all text files in a Notes folder and all pdf files in a Resources folder. \n\tclose (exit, q) - closes the file explorer.\n"
	read line
    elif [ "$line" = "a" ]; then	#autolist toggle command
	toggle
	read line
    elif [ "$line" = "back" ] || [ "$line" = ".." ]; then	#back command
	cd ..
	echo "Current Directory:" $(pwd)
	if [ "$auto" -eq "1" ]; then
	    ls -AFgh | grep -v ^total | cat -n #standard ls command plus ease of read | removes total from -g | enumerates items for openi ease
	fi
	read line
    elif [ "$line" = "pwd" ]; then	#pwd command
	echo "Current Directory:" $(pwd)
	if [ "$auto" -eq "1" ]; then
	    ls -AFgh | grep -v ^total | cat -n
	fi
	read line
    elif [ "$line" = "items" ] || [ "$line" = "ls" ]; then	#items command
	ls -AFgh | grep -v ^total | cat -n
	read line
    elif [[ "$line" =~ ^open+[[:space:]].* ]]; then	#open command
	item=`echo $line | awk '{print $2}'` #substring with item name
	if [[ -f "$item" ]]; then	#file selection
	    xdg-open $item
	elif [[ -d "$item" ]]; then	#directory selection
	    cd $item
	    echo "Current Directory:" $(pwd)
	else
	    echo "Not a valid file/directory"
	fi
	if [ "$auto" -eq "1" ]; then
	    ls -AFgh | grep -v ^total | cat -n
	fi
	read line
    elif [[ "$line" =~ ^open+i.* ]]; then	#openi command
	itemno=`echo $line | awk '{print $2}'`	#gets item number
	item=`ls | awk 'NR=='$itemno''`	#gets relevant item
	if [[ -f "$item" ]]; then	#file section
	    xdg-open $item
	elif [[ -d "$item" ]]; then	#directory section
	    cd $item
	else
	    echo "Not a valid index"
	fi
	if [ "$auto" -eq "1" ]; then
	    ls -AFgh | grep -v ^total | cat -n
	fi
	read line
    elif [[ "$line" = "organize" ]]; then	#organize command
	for file in *; do
	    if [[ $file =~ ^([A-Z]{4})+[[:space:]]+([0-9]{3})+[[:space:]].* ]]; then	#check if relevant file (i.e. properly formatted)
	    dirname=`echo $file | awk '{print $1$2}'` #grabs XXXX000 section to make directory
		if [[ ! -d "$dirname" ]]; then	#check if directory for class exists yet 
		    mkdir "$dirname" 
	    	fi
	    mv "$file" "$dirname"
	    fi
	done
	for dir in */ ; do	#moves items to proper subdirectory
	    cd "$dir"
	    mkdir Notes
	    mkdir Resources	
	    for file in *; do
 	        if [[ "$file" == *.txt ]]; then
		    mv "$file" Notes
		elif [[ "$file" == *.pdf ]]; then
		    mv "$file" Resources
		fi		
	    done
	    cd ..
	done
	echo "Files Organized!"
	if [ "$auto" -eq "1" ]; then
	    ls -AFgh | grep -v ^total | cat -n
	fi
    read line
    elif [ "$line" = "close" ] || [ "$line" = "q" ] || [ "$line" = "exit" ]; then	#close command
	close=1;
    else
	echo "Please enter a valid command (i.e. help):"	#error message
	if [ "$auto" -eq "1" ]; then
	    ls -AFgh | grep -v ^total | cat -n
	fi
	read line
    fi
done
