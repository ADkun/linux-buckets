USERHOME=$HOME
# Setup fzf
# ---------
if [[ ! "$PATH" == ${USERHOME}/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}${USERHOME}/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${USERHOME}/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "${USERHOME}/.fzf/shell/key-bindings.zsh"
