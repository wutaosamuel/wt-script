#!/bin/bash

function dirExist() {
	if [ ! -d $1 ]; then
		return 0
	fi
	return 1
}

function heic2jpg() {
	# check if dir exist
	dirExist $1
	local isExist=$?
	if [ $isExist != 1 ]; then
		echo "$1 is not exist or not a directory"
		exit 1
	fi

	# check cmd if it's exist
	if ! magick --version > /dev/null; then
		echo "magick is not install"
		exit 1
	fi

	# if jpg dir is not exist, create it
	local jpgDir=$1/jpg
	dirExist $jpgDir
	if [ $? == 0 ]; then
		mkdir $jpgDir
	fi

	# read directory files
	for file in "$1"/*; do
		echo "$file"
		local extention=${file##*.}
		if [ "$extention" != "heic" ]; then
			continue
		fi
		dirExist $file
		local isDir=$?
		if [ $isDir == 1 ]; then
			continue
		fi
		echo "$extention"

		local jpgFile=$jpgDir/$(basename ${file%.*}).jpg
		echo "$jpgFile"
		magick "$file" "$jpgFile"
	done
}

heic2jpg $1
echo "done"
