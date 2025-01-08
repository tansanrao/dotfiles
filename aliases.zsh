# For when tmux attach causes problems with old agent in envvars
function fixssh() {
	eval $(tmux show-env -s |grep '^SSH_')
}

# remove from known_hosts helper
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

# Verbosity and settings that you pretty much just always are going to want.
alias \
	cp="cp -iv" \
	mv="mv -iv" \
	rm="rm -vI" \
	bc="bc -ql" \
	rsync="rsync -vrPlu" \
	mkd="mkdir -pv"

# Colorize commands when possible.
alias \
	ls="ls -h --color=auto" \
	grep="grep --color=auto" \
	diff="diff --color=auto" \
	ip="ip -color=auto"


# These common commands are just too long! Abbreviate them.
alias \
	ka="killall" \
	g="git" \
	e="$EDITOR" \
	v="$EDITOR"
