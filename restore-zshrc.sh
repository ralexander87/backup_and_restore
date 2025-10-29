#!/bin/bash

ZSHR="$HOME/.mydotfiles/com.ml4w.dotfiles.stable/.config/zshrc"

# Delete not needed blocks
sed -i '/^source \$ZSH\/oh-my-zsh.sh/d;/^eval/d;/^POSH=/d;/plugins=(/,/)/d' "$ZSHR/20-customization"

plugins=(
    git
    sudo
    ssh-agent
    catimg
    colorize
    web-search
    archlinux
    copyfile
    copybuffer
    dirhistory
    colored-man-pages
    zsh-autosuggestions
    zsh-syntax-highlighting
    fast-syntax-highlighting
)

# Customization
cat >> "$ZSHR/20-customization" << 'EOF'

# Set-up oh-my-zsh
source $ZSH/oh-my-zsh.sh
CASE_SENSITIVE="true"
DISABLE_MAGIC_FUNCTIONS="false"
DISABLE_LS_COLORS="false"
DISABLE_AUTO_TITLE="false"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"

eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/EDM115-newline.omp.json)"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/GitHub
EOF

# Aliases
cat > "$ZSHR/25-aliases" << 'EOF'
# -----------------------------------------------------
# ALIASES
# -----------------------------------------------------

alias c='clear'
alias cat='bat'
alias ld='exa -Dl --icons'
alias ls='exa --icons'
alias ll='exa -alhbo --no-time --total-size --icons --group-directories-first'
alias cls='clear ; exa --icons'
alias la='exa -ha --icons'
alias cla='clear ; exa -ha --icons'
alias lt='eza -a --tree --level=1 --icons'
alias wifi='nmtui'
alias v='$EDITOR'
alias vim='$EDITOR'
alias svim='sudo nvim'
alias icat='kitten icat'
alias cll='clear ; exa -aoblh --icons --no-time --total-size --no-permissions --group-directories-first'
alias backup='/home/ralexander/Working/bash/backup-rsync.sh |& tee -a "backup-rsync-$(date +%F).log"'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias ..='cd ..'
EOF

# Autostart
cat > "$ZSHR/30-autostart" << 'EOF'
if [[ $(tty) == *"pts"* ]]; then
	fastfetch --config ~/.config/fastfetch/config.jsonc
fi
EOF

