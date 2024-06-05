#!/bin/bash

KEYID=F278A3CCB6C173BD3660D173564D16856D20F3FC
THISDIR="$(dirname $0)"
ENCRYPT_SH="$THISDIR"/encry.sh
DECRYPT_SH="$THISDIR"/decry.sh
MESSAGE="This is a message test
This is a message line 2"

function stdout_test {
	local encryptedMessage=$(echo "$MESSAGE" | bash "$THISDIR"/encry.sh "$KEYID")
	local decryptedMessage=$(echo "$encryptedMessage" | bash "$THISDIR"/decry.sh)
	#echo "Start en_decrypt test by outputing on screen"
	#echo "original message: $MESSAGE"
	echo "decrypted message: $decryptedMessage"

	if [ "$MESSAGE" == "$decryptedMessage" ]; then
		echo "Encrypt and decrypt test pass"
	else
		echo "Encrypt and decrypt test fail"
	fi
	echo ""
}

function file_test {
	local encryptedFile="$THISDIR"/encrypted.txt
	local decryptedFile="$THISDIR"/plaintxt.txt

	echo "$MESSAGE" | bash "$THISDIR"/encry.sh "$KEYID" "$encryptedFile"
	cat "$encryptedFile" | bash "$THISDIR"/decry.sh "$decryptedFile"

	#echo "Start en_decrypt test by writing to file"
	#echo "original message: $MESSAGE"
	echo "decrypted message: $(cat "$decryptedFile")"

	if [ "$MESSAGE" == "$(cat "$decryptedFile")" ]; then
		echo "Encrypt and decrypt to file test pass"
	else
		echo "Encrypt and decrypt to file test fail"
	fi
	echo ""
}

stdout_test

file_test