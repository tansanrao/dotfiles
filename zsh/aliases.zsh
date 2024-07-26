# For when tmux attach causes problems with old agent in envvars
function fixssh() {
	eval $(tmux show-env -s |grep '^SSH_')
}

# remove from known_hosts helper for when VMs are torn down and rebuilt regularly
function rmkeys() {
	ssh-keygen -f "$HOME/.ssh/known_hosts" -R $1
}

function jump() {
	if (( $# < 2 )); then
		echo "Usage: jump host1 [host2 ... hostN]"
		return 1
	fi

	local hosts=("$@")
	local last_host=${hosts[-1]}
	local jump_hosts=${hosts[1,-2]}

	local jump_string=""
	for host in $jump_hosts; do
		jump_string+="$host,"
	done

	jump_string=${jump_string%,}  # Remove trailing comma

	ssh -A -J $jump_string $last_host
}

# Helper to list full trust chain for https server.
function seecert () {
	nslookup $1
	(openssl s_client -showcerts -servername $1 -connect $1:443 <<< \
		"Q" | openssl x509 -text | grep -iA2 "Validity")
	}

# CS3754 helpers
function 3754_unzip_all () {
	find . -name "*.zip" -exec sh -c 'unzip -d "${1%/*}" "$1"' _ {} \;
}

function 3754_gather_xlsx () {
	if [ $# -eq 0 ]; then
		echo "Usage: gather_xlsx <destination_directory>"
		return 1
	fi

	dest_dir="$1"

    # Create the destination directory if it doesn't exist
    mkdir -p "$dest_dir"

    # Find and copy all .xlsx files to the specified destination directory
    find . -name "*.xlsx" -exec cp {} "$dest_dir" \;
}
