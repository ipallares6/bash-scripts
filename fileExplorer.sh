#!/bin/bash
#Ian Pallares 05-03-2021

function toggle {	#autolist toggle function
    if [ "$auto" -eq "0" ]; then
	auto=1;
    else
	auto=0;
    fi
}

function lctoggle {	#learning curve toggle function
    if [ "$lc" -eq "0" ]; then
	lc=1;
    else
	lc=0;
    fi
}

echo -e " Commands: \n\n\ta - toggles whether explorer relists files in current directory after each command. Default is off. \n\tlc - toggles the bash learning curve assistant, displaying the real code used after each command. \n\tback - goes to previous directory if possible. \n\tdirectory - lists current directory. \n\titems - lists items available in current directory, numbered. \n\topen [file or directory name] - opens item specified. \n\topeni [i] - opens the ith item listed in the directory. \n\torganize - creates new directories for each XXXX 000 (CWRU class) formatted file and places all files for that class in there, then internally places all text files in a Notes folder and all pdf files in a Resources folder. \n\ttask manager (tm) - opens the task manager menu. (advanced commands) \n\tclose (exit, q) - closes the file explorer.\n"
echo "Enter command (or use help):"
close=0; #exits while loop when set to 1
tmclose=0; #task manager close
auto=0; #autolist toggle variable
lc=0; #learning curve variable
read line
while [ "$close" -eq "0" ]; do
    if [ "$line" = "help" ]; then	#help command
	echo -e " Commands: \n\n\ta - toggles whether explorer relists files in current directory after each command. Default is off. \n\tlc - toggles the bash learning curve assistant, displaying the real code used after each command. \n\tback - goes to previous directory if possible. \n\tdirectory - lists current directory. \n\titems - lists items available in current directory, numbered. \n\topen [file or directory name] - opens item specified. \n\topeni [i] - opens the ith item listed in the directory. \n\torganize - creates new directories for each XXXX 000 (CWRU class) formatted file and places all files for that class in there, then internally places all text files in a Notes folder and all pdf files in a Resources folder. \n\ttask manager (tm) - opens the task manager menu. (advanced commands) \n\tclose (exit, q) - closes the file explorer.\n"
	read line
    elif [ "$line" = "a" ]; then	#autolist toggle command
	toggle
	read line
    elif [ "$line" = "lc" ]; then	#learning curve toggle command
	lctoggle
	read line
    elif [ "$line" = "back" ] || [ "$line" = "cd .." ]; then	#back command
	cd ..
	echo "Current Directory:" $(pwd)
	if [ "$auto" -eq "1" ]; then
	    ls -AFgh | grep -v ^total | cat -n | sed 's/^[ \t]*//' #standard ls command plus ease of read | removes total from -g | enumerates items for openi ease
	fi
	if [ "$lc" -eq "1" ]; then
	    echo -e "\e[31mBash Code: cd ..\e[0m" 	
	fi
	read line
    elif [ "$line" = "directory" ] || [ "$line" = "pwd" ]; then	#pwd command
	echo "Current Directory:" $(pwd)
	if [ "$auto" -eq "1" ]; then
	    ls -AFgh | grep -v ^total | cat -n | sed 's/^[ \t]*//'
	fi
	if [ "$lc" -eq "1" ]; then
	    echo -e "\e[31mBash Code: pwd\e[0m" 	
	fi
	read line
    elif [ "$line" = "items" ] || [ "$line" = "ls" ]; then	#items command
	ls -AFgh | grep -v ^total | cat -n | sed 's/^[ \t]*//'
	if [ "$lc" -eq "1" ]; then
	    echo -e "\e[31mBash Code: ls\e[0m" 	
	fi
	read line
    elif [[ "$line" =~ ^open+[[:space:]].* ]] || [[ "$line" =~ ^xdg-open+[[:space:]].* ]] || [[ "$line" =~ ^cd+[[:space:]].* ]]; then	#open command
	item=`echo $line | awk '{print $2}'` #substring with item name
	cmd=`echo $line | awk '{print $1}'` #substring with command name
	if [[ -f "$item" ]]; then	#file selection
	    if [ "$cmd" = "open" ] || [ "$cmd" = "xdg-open" ]; then
	        xdg-open $item
		    if [ "$lc" -eq "1" ]; then
	    	        echo -e "\e[31mBash Code: xdg-open [name]\e[0m" 	
		    fi
	    else
		echo "Incorrect command for filetype"
	    fi
	elif [[ -d "$item" ]]; then	#directory selection
	    if [ "$cmd" = "open" ] || [ "$cmd" = "cd" ]; then
	        cd $item
	        echo "Current Directory:" $(pwd)
		    if [ "$lc" -eq "1" ]; then
	    	        echo -e "\e[31mBash Code: cd [name]\e[0m" 	
		    fi
	    else
		echo "Incorrect command for filetype"
	    fi
	else
	    echo "Not a valid item"
	fi
	if [ "$auto" -eq "1" ]; then
	    ls -AFgh | grep -v ^total | cat -n | sed 's/^[ \t]*//'
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
	    ls -AFgh | grep -v ^total | cat -n | sed 's/^[ \t]*//'
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
	    ls -AFgh | grep -v ^total | cat -n | sed 's/^[ \t]*//'
	fi
    read line
    elif [ "$line" = "task manager" ] || [ "$line" = "tm" ]; then	#task manager submenu
	echo -e " Task Manager Commands: \n\n\tforce quit - exits all non-essential programs on laptop. \n\tview tasks - shows info on all tasks currently using CPU on computer. \n\tlock - locks the screen. \n\tshutdown - logs out user and shuts down machine. \n\texit - exits task manager, returns to file explorer"
    read line
	while [ "$tmclose" -eq "0" ]; do
	    if [ "$line" = "force quit" ]; then	#task force quit
		top -in1 -U $USER | awk '!/top/ {if (NR>6) print $0}'
		echo "Type a program to force quit"
		read line
		pkill $line
		if [ "$lc" -eq "1" ]; then
	    	    echo -e "\e[31mBash Code: pkill [i]\e[0m" 	
		fi
	    	read line
	    elif [ "$line" = "view tasks" ]; then	#lists tasks
		top -in1 -U $USER | awk '!/top/ {if (NR>6) print $0}'
		if [ "$lc" -eq "1" ]; then
	    	    echo -e "\e[31mBash Code: top\e[0m" 	
		fi
	    read line
	    elif [ "$line" = "lock" ]; then	#screenlock
		gnome-screensaver-command -l
		if [ "$lc" -eq "1" ]; then
	    	    echo -e "\e[31mBash Code: gnome-screensaver-command -l\e[0m" 	
		fi
		read line
	    elif [ "$line" = "shutdown" ]; then	#shutdown
		shutdown
		break
	    elif [ "$line" = "help" ]; then	#tm help
		echo -e " Task Manager Commands: \n\n\tforce quit - exits all non-essential programs on laptop. \n\tview tasks - shows info on all tasks currently using CPU on computer. \n\tlock - locks the screen. \n\texit - exits task manager, returns to file explorer.\n"
		read line
	    elif [ "$line" = "exit" ]; then	#tm exit
		break
	    else
		echo "Please enter a valid command"	#tm error
		read line
	    fi
	done
	read line
    elif [ "$line" = "close" ] || [ "$line" = "q" ] || [ "$line" = "exit" ]; then	#close command
	break
    else
	echo "Please enter a valid command (i.e. help):"	#error message
	if [ "$auto" -eq "1" ]; then
	    ls -AFgh | grep -v ^total | cat -n | sed 's/^[ \t]*//'
	fi
	read line
    fi
done
