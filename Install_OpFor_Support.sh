#!/bin/bash

# Sven Co-op support script for Valve games.

# Discord channel: https://discord.gg/y87qr6Y
# Forums: https://forums.svencoop.com/

init() {

	# Install location:
	# true: svencoop_addon, false: svencoop
	addondir=false

	# Don´t change anything below this line unless you know what are doing!!

	# Set root for the script.
	script_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# Safeguard¹: CD to the correct dir, no matter from where the script is ran.
	if [ "${PWD##*/}" != "svencoop" ];
	then
		cd "$script_root"
	fi

	# Safeguard²: prevent running this script outside svencoop folder if the above fails.
	if [ "${PWD##*/}" != "svencoop" ];
	then
		echo "Error: Script running outside \"svencoop\" folder! Exiting..."
		exit 1
	fi

	# Game name
	gamename="Opposing Force"

	# Get OS arch type
	osarch=$(getconf LONG_BIT)

	# Default ripent is 64-bit.
	# We have to use the right binary otherwise patching will fail...
	if [ "$osarch" == "64" ]
	then
		ripent=maps/ripent
	else
		ripent=maps/ripent_32
	fi
	
	# Destination path for maps
	if [[ "$addondir" == true ]]
	then
		# svencoop_addon folder
		instdir=svencoop_addon
	else
		# svencoop standard folder
		instdir=svencoop
	fi

	# Opposing Force relative dir
	op4dir="../../Half-Life/gearbox"

	# map list
	maplist="
		of0a0 of1a1 of1a2 of1a3 of1a4 of1a4b of1a5 of1a5b of1a6 \
		of2a1 of2a1b of2a4 of2a5 of2a6 \
		of3a1 of3a4 of3a5 of3a6 \
		of4a1 of4a2 of4a3 of4a4 of4a5 \
		of5a1 of5a2 of5a3 of5a4 \
		of6a1 of6a2 of6a3 of6a4 of6a4b of6a5"

}

messages () {

	echo ""
	echo "-= Half-Life: $gamename map support for Sven Co-op =-"
	echo ""
	echo "Warning: around 80MB is used after installation."

	echo ""
	echo "Installation may take a few minutes depending on"
	echo "your system performance. Please be patient."
	echo ""

	echo "----------------------------------------------------------------------------"
	echo "IMPORTANT: To install $gamename support, you must own 'Half-Life:"
	echo "$gamename' and have it fully downloaded and installed on Steam!"
	echo "----------------------------------------------------------------------------"
	echo ""
	
	
	
	# It's time to choose! - GMan
	for count in {5..1}; do echo -ne "Press CTRL+C to cancel or wait $count seconds..."'\r'; sleep 1; done; echo ""
	clear

	echo ""
	echo "OS architecture: $osarch-bit"
	echo "Install directory: $instdir"
	echo "ripent binary: $ripent"
	echo ""
	echo ""

}

validation() {

	command -v unzip >/dev/null 2>&1  || { 
		echo "Unzip not found."
		echo "You can install by using \"sudo apt-get install unzip\""
		echo "for Ubuntu and Debian, and \"yum install unzip\""
		echo "for RedHat or CentOS."
		exit 1
	}

	if [ ! -f "$ripent" ]
	then
		echo "Missing $ripent, cannot continue. Corrupted install?"
		exit 1
	else
		if [[ ! -x "$ripent" ]]
		then
			chmod +x $ripent
		fi
	fi

	# Check if Opposing Force game directory exists
	if [ -d "$op4dir" ];
	then
		echo "Found $gamename installation."
		copyop4
	fi

	for mcheck in $maplist; do

		# Extra check: let's make sure we have all map files!
		if [ -f "../$instdir/maps/$mcheck.bsp" ]
		then
			echo "Found $mcheck in maps folder!"
		else
			# Show message about missing file to user and exit script.
			echo ""
			echo "Oops! Map file $mcheck.bsp is missing. Please make sure you"
			echo "have a working $gamename installation and/or"
			echo "all map files in maps folder before running this script!"
			echo ""
			exit 1
		fi
	done
	echo ""

}

# Copy map files from original installation
copyop4(){

	# Create required folders if is a clean installation
	if [ ! -d "../$instdir/gfx/env" ];
	then
		echo "Creating gfx/env/ directory..."
		mkdir -p ../$instdir/gfx/env
	fi
	
	if [ ! -d "../$instdir/maps" ];
	then
		echo "Creating maps directory..."
		mkdir -p ../$instdir/maps
	fi

	for copy in $maplist; do
	echo "Copying $copy..."
	cp "$op4dir/maps/$copy.bsp" "../$instdir/maps/$copy.bsp"
	done

	echo "Copying sky textures..."
	cp $op4dir/gfx/env/* ../$instdir/gfx/env/
	echo ""

}

# Importing custom entities
patching() {

	echo "Unzipping support files..."
	unzip -o opfor_support.sven -d ../$instdir/maps >/dev/null 2>&1
	for target in $maplist; do
	echo "Patching $target..."
	./$ripent -import "../$instdir/maps/$target".bsp >/dev/null 2>&1
	done
	echo ""

}

cleanup(){

	echo "Cleaning up..."
	echo ""
	rm ../$instdir/maps/of*a*.ent

}

init
messages
validation
patching
cleanup

# Das ende

echo "All done! If you have any problems, ask"
echo "for help at https://forums.svencoop.com"

exit 0
