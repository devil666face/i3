alias ls='lsd'
alias docker-compose='docker compose'

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Add this to your ~/.zshrc
gpge() {
    if [[ -z "$1" ]]; then
        echo "Usage: gpge <file>"
        return 1
    fi

    local input_file="$1"
    local output_file="${input_file}.gpg"

    if [[ ! -f "$input_file" ]]; then
        echo "Error: File '$input_file' does not exist."
        return 1
    fi

    gpg --encrypt --output "$output_file" "$input_file"

    if [[ $? -eq 0 ]]; then
        echo "File encrypted successfully: $output_file"
    else
        echo "Error: Failed to encrypt file."
    fi
}

gpgd() {
    if [[ -z "$1" ]]; then
        echo "Usage: gpgd <file.gpg>"
        return 1
    fi

    local input_file="$1"
    local output_file="${input_file%.gpg}"

    if [[ ! -f "$input_file" ]]; then
        echo "Error: File '$input_file' does not exist."
        return 1
    fi

    gpg --decrypt --output "$output_file" "$input_file"

    if [[ $? -eq 0 ]]; then
        echo "File decrypted successfully: $output_file"
    else
        echo "Error: Failed to decrypt file."
    fi
}

export GOPATH=~/.go
export EDITOR=hx
export PATH=$GOPATH/bin:\
/opt/helix/node/bin:\
/opt/helix/python/bin:\
/opt/helix/nim/bin:\
/opt/helix/zig:\
/opt/helix/cargo/bin:\
/opt/helix:\
/home/d6f/.nimble/bin:\
$PATH
# export PATH=\
# /opt/helix/go/bin:\
# $PATH
export PATH=\
/opt/helix/go1.20.14/bin:\
$PATH

export GPG_TTY=$(tty)
gpgconf --launch gpg-agent
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

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

