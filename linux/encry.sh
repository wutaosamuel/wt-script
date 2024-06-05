#!/bin/bash
function encrypt() {
	local message=$1
	local keyid=$2
	local filename=$3

	if [[ -z "$filename" ]]; then
		echo "$message" | gpg --encrypt --armor --recipient $keyid
	else
		# check filename has extention
		local extention=$(sed 's/^\w\+.//' <<< "$filename")
		if [[ -z "$extention" ]]; then
			output="$filename".txt
		else
			output="$filename"
		fi

		echo "$message" | gpg --encrypt --armor --output ${output} -r $keyid
		echo "Encrypt, save to $output"
	fi
}

function getKeyID() {
	KEYID=$(gpg -k --with-colons "$IDENTITY" | awk -F: '/^pub:/ { print $5; exit }')
}

if [ "$#" -lt 1 ]; then
	echo "Usage: "
	echo "printf \"%s\" \"your message\" | encry.sh [KEYID] [filename]"
	echo "or from file"
	echo "cat your.file | encry.sh [KEYID] [filename]" # TODO: test cat
	exit 0
fi

content=$(cat)

encrypt "$content" "$1" "$2"