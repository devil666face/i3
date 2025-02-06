alias ls='lsd'
alias docker-compose='docker compose'
alias default-ssh-agent='eval "$(ssh-agent -s)"'

_get_ssh_hosts() {
	local opts history_hosts
	opts=$(awk '/^Host / {for (i=2; i<=NF; i++) print $i}' ~/.ssh/config | grep -v '*' | sort -u)
	history_hosts=$(history | tail -n 1000 | grep -oP 'ssh \K[^\s]+' | sort -u)
	echo -e "$opts\n$history_hosts" | sort -u
}

ssh() {
	local host args
	if [[ -z $1 ]]; then
		host=$(fzf --reverse <<<"$(_get_ssh_hosts)")
		[[ -z $host ]] && return 1
		/usr/bin/ssh $host
	else
		/usr/bin/ssh "$@"
	fi
}

_ssh_complete() {
	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"
	COMPREPLY=($(compgen -W "$(_get_ssh_hosts)" -- "$cur"))
}

complete -F _ssh_complete ssh

sshp() {
	local host args
	if [[ -z $1 ]]; then
		host=$(fzf --reverse <<<"$(_get_ssh_hosts)")
		[[ -z $host ]] && return 1
		proxychains /usr/bin/ssh $host
	else
		proxychains /usr/bin/ssh "$@"
	fi
}

complete -F _ssh_complete sshp

y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

o() {
	if [[ -z $1 ]]; then
		return 1
	fi
	nohup "$@" >/dev/null &
}
_o_completion() {
	_command_names
}
compdef _o_completion o

clip() {
	if [[ -z $1 ]]; then
		return 1
	fi
	cat "$1" | xclip -selection clipboard
	if [[ $? -eq 0 ]]; then
	else
		echo "Error: Failed to clip."
	fi
}
_clip_completion() {
	_files
}
compdef _clip_completion clip

gpge() {
	if [[ -z $1 ]]; then
		return 1
	fi
	local input_file="$1"
	local output_file="$input_file.gpg"
	if [[ ! -f $input_file ]]; then
		echo "Error: File '$input_file' does not exist."
		return 1
	fi
	gpg --encrypt --output - "$input_file" | base64 >"$output_file"
	if [[ $? -eq 0 ]]; then
		echo "File encrypted successfully: $output_file"
	else
		echo "Error: Failed to encrypt file."
	fi
}
_gpge_completion() {
	_files
}
compdef _gpge_completion gpge

gpgd() {
	if [[ -z $1 ]]; then
		return 1
	fi
	local input_file="$1"
	local output_file="${input_file%.gpg}"
	if [[ ! -f $input_file ]]; then
		echo "Error: File '$input_file' does not exist."
		return 1
	fi
	base64 --decode "$input_file" | gpg --decrypt --output "$output_file"
	if [[ $? -eq 0 ]]; then
		echo "File decrypted successfully: $output_file"
	else
		echo "Error: Failed to decrypt file."
	fi
}
_gpgd_completion() {
	_files
}
compdef _gpgd_completion gpgd

ssh-copy-id-all() {
	if [[ -z $1 ]]; then
		return 1
	fi
	ssh-copy-id -f "$1"
	ssh-copy-id -f -i .ssh/id_rsa "$1"
	ssh-copy-id -f -i .ssh/id_ed25519_sk "$1"
}
complete -F _ssh_complete ssh-copy-id-all

sshp-copy-id-all() {
	if [[ -z $1 ]]; then
		return 1
	fi
	proxychains ssh-copy-id -f "$1"
	proxychains ssh-copy-id -f -i .ssh/id_rsa "$1"
	proxychains ssh-copy-id -f -i .ssh/id_ed25519_sk "$1"
}
complete -F _ssh_complete sshp-copy-id-all
export GOPATH=~/.go
export EDITOR=hx
export PATH=$GOPATH/bin:/opt/helix/node/bin:/opt/helix/python/bin:/opt/helix/nim/bin:/opt/helix/zig:/opt/helix/cargo/bin:/opt/helix:/home/d6f/.nimble/bin:$PATH
# export PATH=/opt/helix/go1.20.14/bin:$PATH
export PATH=/opt/helix/go/bin:$PATH

_start_gpg_agent() {
	pgrep -u "$USER" gpg-agent >/dev/null || gpgconf --launch gpg-agent
	export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
}
_start_gpg_agent

_gen_fzf_default_opts() {
	local theme=${1:-'default'}
	local colors=""
	if [[ $theme == 'gruvbox' ]]; then
		colors="bg+:#3c3836,bg:#282828,spinner:#8ec07c,hl:#83a598,fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c,marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598"
	elif [[ $theme == 'dracula' ]]; then
		colors="fg:#f8f8f2,bg:#282a36,hl:#bd93f9,fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9,info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6,marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
	elif [[ $theme == 'cattpucin' ]]; then
		colors="bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39,fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78,marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39"
	fi
	export FZF_DEFAULT_OPTS="--color=$colors"
}
_gen_fzf_default_opts 'dracula'

eval "$(zoxide init zsh --cmd cd)"
#source <(_YKMAN_COMPLETE=bash_source ykman | tee /etc/bash_completion.d/ykman)
source /etc/bash_completion.d/ykman
