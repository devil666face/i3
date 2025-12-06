export ZSH="$HOME/.oh-my-zsh"

plugins=(
	git
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ ! -f ~/.local/bin/env ]] || source ~/.local/bin/env

eval "$(mise activate zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"

alias ls='lsd'
alias docker-compose='docker compose'
alias default-ssh-agent='eval "$(ssh-agent -s)"'
alias laz='lazygit'
alias lad='lazydocker'
alias pr='proxychains4 -q'

proxy_run() {
	HTTP_PROXY=$PROXY HTTPS_PROXY=$PROXY ALL_PROXY=$PROXY NO_PROXY=$NO_PROXY "$@"
}
proxychains_run() {
	pr "$@"
}

alias crush='proxy_run crush'
alias aichat='proxy_run aichat'
# alias aider='proxy_run aider-ce'
alias aider='proxychains_run aider-ce'

alias ai='cd ~/.ai && aider'
alias ai-pro='cd ~/.ai && aider --model o3-pro'
alias cr='cd ~/.ai && crush'

_get_ssh_hosts() {
	local opts history_hosts
	opts=$(
		awk '/^Host / {
            for (i=2; i<=NF; i++) print $i
        }' ~/.ssh/config ~/.ssh/config.d/*.conf 2>/dev/null | grep -v '\*' | sort -u
	)
	history_hosts=$(history | tail -n 1000 | grep -oP 'ssh \K[^\s]+' | sort -u)
	echo -e "$opts\n$history_hosts" | sort -u
}

ssh() {
	if [[ -z $1 ]]; then
		host=$(fzf --reverse <<<"$(_get_ssh_hosts)")
		[[ -z $host ]] && return 1
		/usr/bin/ssh "$host"
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
	set +m
	nohup setsid "$@" >/dev/null 2>&1 </dev/null &
	disown
	set -m
}
_o_completion() {
	_command_names
}
compdef _o_completion o

n() {
	o nautilus .
}
compdef _o_completion n

k() {
	local session=$(find ~/ -maxdepth 4 -type f -name "*.kitty-session" | fzf --reverse)
	o kitty --session "$session"
}

clip() {
	if [[ -z $1 ]]; then
		if ! xclip -selection clipboard; then
			echo "Failed: copy from stdin."
			return 1
		fi
	else
		if ! cat "$1" | xclip -selection clipboard; then
			echo "Failed: copy file \"$1\"."
			return 1
		fi
	fi
	return 0
}
_clip_completion() {
	_files
}
compdef _clip_completion clip

share() {
	if [[ -z $1 ]]; then
		echo "Usage: share <file_or_directory>"
		return 1
	fi

	local input="$1"
	local zip_file="$input".zip
	local pass=$(openssl rand 32 | base64)
	zip -e -rq9 "$zip_file" "$input" -P "$pass"

	local url=$(curl --silent -F "file=@${zip_file}" https://temp.sh/upload | sed 's/http:/https:/')

	echo "Password: $pass"
	echo "Download:
curl -X POST -o $zip_file $url
wget --method=POST -O $zip_file $url
Invoke-WebRequest -Uri \"$url\" -Method \"POST\" -OutFile $zip_file
"
}
_share_completion() {
	_files
}
compdef _share_completion share

gpge() {
	if [[ -z $1 ]]; then
		echo "Usage: gpge <file_or_directory>"
		return 1
	fi

	local input="$1"
	local input_file=""
	local cleanup=0

	if [[ -d $input ]]; then
		input_file="${input%/}.zip"
		if ! zip -r "$input_file" "$input" >/dev/null; then
			echo "Error: Failed to zip directory '$input'."
			return 1
		fi
		cleanup=1
	elif [[ -f $input ]]; then
		input_file="$input"
	else
		echo "Error: '$input' is neither a file nor a directory."
		return 1
	fi

	local output_file="$input_file.gpg"

	if gpg --encrypt --output - "$input_file" | base64 >"$output_file"; then
		echo "File encrypted successfully: $output_file"
		[[ $cleanup -eq 1 ]] && rm -f "$input_file"
	else
		echo "Error: Failed to encrypt file."
		[[ $cleanup -eq 1 ]] && rm -f "$input_file"
		return 1
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
	if base64 --decode "$input_file" | gpg --decrypt --output "$output_file"; then
		echo "File decrypted successfully: $output_file"
	else
		echo "Error: Failed to decrypt file."
	fi
}
_gpgd_completion() {
	_files
}
compdef _gpgd_completion gpgd

yubi() {
	if [[ -z $1 ]]; then
		return 1
	fi
	local phrase="$1"
	local password=$(echo "$phrase" | xxd -p | ykman otp calculate 1)
	echo "$password"
	echo "$phrase"
	echo "$password" >"$phrase.pass"
}

yubi-zip() {
	if [[ -z $1 ]]; then
		return 1
	fi
	local phrase="$1"
	local password=$(echo "$phrase" | xxd -p | ykman otp calculate 1)
	echo "$password"
	echo "$phrase"
	echo "$password" >"$phrase.pass"
	zip -r9 -P "$password" "$1.zip" "$1"
}

ssh-copy-id-all() {
	if [[ -z $1 ]]; then
		return 1
	fi
	ssh-copy-id -f "$1"
	ssh-copy-id -f -i ~/.ssh/id_rsa "$1"
	ssh-copy-id -f -i ~/.ssh/id_ed25519_sk "$1"
}
complete -F _ssh_complete ssh-copy-id-all

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

# source <(_YKMAN_COMPLETE=bash_source ykman | tee /etc/bash_completion.d/ykman)
source /etc/bash_completion.d/ykman
# task --completion zsh > task
source /etc/bash_completion.d/task

export GOPATH=~/.go

export EDITOR=hx

export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/opt/helix/lsp

# Aider conf
export AIDER_WATCH_FILES=True
export AIDER_DRY_RUN=False
export AIDER_EDITOR=hx
export AIDER_GUI=False
export AIDER_AUTO_COMMITS=False
export AIDER_MODEL=openai/gpt-5.1
export AIDER_CODE_THEME=dracula
export AIDER_CHAT_LANGUAGE=ru_RU
export AIDER_PRETTY=True
export AIDER_VOICE_LANGUAGE=ru
export AIDER_STREAM=True
export AIDER_CHECK_UPDATE=False
export AIDER_SHOW_RELEASE_NOTES=False
export AIDER_SHOW_DIFFS=True
export AIDER_ENV_FILE=.env.aider
export AIDER_RESTORE_CHAT_HISTORY=True

# Aider-ce conf
export AIDER_AGENT=False
export AIDER_CACHE_PROMPTS=False
export AIDER_PRESERVE_TODO_LIST=True
export AIDER_ENABLE_CONTEXT_COMPACTION=True

export AIDER_ANALYTICS=False
# export AIDER_ANALYTICS_DISABLE=True
export CRUSH_DISABLE_METRICS=1
export DO_NOT_TRACK=1

[[ ! -f ~/.env ]] || source ~/.env
