export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-suggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
alias ls='eza --icons'
alias la='eza -la --icons'
alias cat='batcat'
eval "$(zoxide init zsh)"
