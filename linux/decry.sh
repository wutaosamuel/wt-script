reveal () {
  output=$(echo "${1}" | rev | cut -c16- | rev)
  gpg --decrypt --output ${output} "${1}" && \
    echo "${1} -> ${output}"

  printf "%s" "$(cat encrypted.txt)" | gpg --decrypt --armor 2>/dev/null
}

function decrypt() {
	local message=$1
	local filename=$2

	if [[ -z "$filename" ]]; then
		echo "$message" | gpg --decrypt --armor 2>/dev/null
	else
		echo "$message" | gpg --decrypt --output "$filename" --armor
		echo "Decrypt, save to $filename"
	fi
}

function help() {
	if [ "$#" -le 1 ]; then
		echo "Usage: "
		echo "echo "your message" | decry.sh [filename]"
		echo "or from file"
		echo "cat your.file | decry.sh [filename]"
		exit 0
	fi
}

content=$(cat)

decrypt "$content" $1