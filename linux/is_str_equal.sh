#/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Usage:"
	echo "is_str_equal.sh [string 1] [string 2]"
	exit 0
fi

if [ "$1" == "$2" ]; then
	echo "$1"
	echo ""
	echo "Result: strings are matched"
else
	echo "String 1: $1"
	echo ""
	echo "String 2: $2"
	echo ""
  echo "Result: strings does not match"
fi