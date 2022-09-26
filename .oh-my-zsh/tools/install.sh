set -e

custom_zsh=yes
USERHOME=${HOME}

ZSH=${USERHOME}/.oh-my-zsh
REPO=ohmyzsh/ohmyzsh
REMOTE=https://github.com/${REPO}.git
BRANCH=master

CHSH=no
RUNZSH=no
KEEP_ZSHRC=no


command_exists() {
  command -v "$@" >/dev/null 2>&1
}

if [ -t 1 ]; then
  is_tty() {
    true
  }
else
  is_tty() {
    false
  }
fi

supports_hyperlinks() {
  if [ -n "$FORCE_HYPERLINK" ]; then
    [ "$FORCE_HYPERLINK" != 0 ]
    return $?
  fi

  is_tty || return 1

  if [ -n "$DOMTERM" ]; then
    return 0
  fi

  if [ -n "$VTE_VERSION" ]; then
    [ $VTE_VERSION -ge 5000 ]
    return $?
  fi

  case "$TERM_PROGRAM" in
  Hyper|iTerm.app|terminology|WezTerm) return 0 ;;
  esac

  if [ "$TERM" = xterm-kitty ]; then
    return 0
  fi

  if [ -n "$WT_SESSION" ] || [ -n "$KONSOLE_VERSION" ]; then
    return 0
  fi

  return 1
}

fmt_link() {
  if supports_hyperlinks; then
    printf '\033]8;;%s\a%s\033]8;;\a\n' "$2" "$1"
    return
  fi

  case "$3" in
  --text) printf '%s\n' "$1" ;;
  --url|*) fmt_underline "$2" ;;
  esac
}

fmt_underline() {
  is_tty && printf '\033[4m%s\033[24m\n' "$*" || printf '%s\n' "$*"
}

fmt_code() {
  is_tty && printf '`\033[2m%s\033[22m`\n' "$*" || printf '`%s`\n' "$*"
}

fmt_error() {
  printf '%sError: %s%s\n' "$BOLD$RED" "$*" "$RESET" >&2
}

setup_color() {
  if is_tty; then
    RAINBOW="
      $(printf '\033[38;5;196m')
      $(printf '\033[38;5;202m')
      $(printf '\033[38;5;226m')
      $(printf '\033[38;5;082m')
      $(printf '\033[38;5;021m')
      $(printf '\033[38;5;093m')
      $(printf '\033[38;5;163m')
    "
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[34m')
    BOLD=$(printf '\033[1m')
    RESET=$(printf '\033[m')
  else
    RAINBOW=""
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
  fi
}

setup_zshrc() {
  echo "${BLUE}Looking for an existing zsh config...${RESET}"

  OLD_ZSHRC=${USERHOME}/.zshrc.pre-oh-my-zsh
  if [ -f ${USERHOME}/.zshrc ] || [ -h ${USERHOME}/.zshrc ]; then
    if [ "$KEEP_ZSHRC" = yes ]; then
      echo "${YELLOW}Found ${USERHOME}/.zshrc.${RESET} ${GREEN}Keeping...${RESET}"
      return
    fi
    if [ -e "$OLD_ZSHRC" ]; then
      OLD_OLD_ZSHRC="${OLD_ZSHRC}-$(date +%Y-%m-%d_%H-%M-%S)"
      if [ -e "$OLD_OLD_ZSHRC" ]; then
        fmt_error "$OLD_OLD_ZSHRC exists. Can't back up ${OLD_ZSHRC}"
        fmt_error "re-run the installer again in a couple of seconds"
        exit 1
      fi
      mv "$OLD_ZSHRC" "${OLD_OLD_ZSHRC}"

      echo "${YELLOW}Found old ${USERHOME}/.zshrc.pre-oh-my-zsh." \
        "${GREEN}Backing up to ${OLD_OLD_ZSHRC}${RESET}"
    fi
    echo "${YELLOW}Found ${USERHOME}/.zshrc.${RESET} ${GREEN}Backing up to ${OLD_ZSHRC}${RESET}"
    mv ${USERHOME}/.zshrc "$OLD_ZSHRC"
  fi

  echo "${GREEN}Using the Oh My Zsh template file and adding it to ${USERHOME}/.zshrc.${RESET}"

  sed "/^export ZSH=/ c\\
export ZSH=\"$ZSH\"
" "$ZSH/templates/zshrc.zsh-template" > ${USERHOME}/.zshrc-omztemp
  mv -f ${USERHOME}/.zshrc-omztemp ${USERHOME}/.zshrc

  echo
}

setup_shell() {
  if [ "$CHSH" = no ]; then
    return
  fi

  if [ "$(basename -- "$SHELL")" = "zsh" ]; then
    return
  fi

  if ! command_exists chsh; then
    cat <<EOF
I can't change your shell automatically because this system does not have chsh.
${BLUE}Please manually change your default shell to zsh${RESET}
EOF
    return
  fi

  echo "${BLUE}Time to change your default shell to zsh:${RESET}"

  printf '%sDo you want to change your default shell to zsh? [Y/n]%s ' \
    "$YELLOW" "$RESET"
  read -r opt
  case $opt in
    y*|Y*|"") echo "Changing the shell..." ;;
    n*|N*) echo "Shell change skipped."; return ;;
    *) echo "Invalid choice. Shell change skipped."; return ;;
  esac

  case "$PREFIX" in
    *com.termux*) termux=true; zsh=zsh ;;
    *) termux=false ;;
  esac

  if [ "$termux" != true ]; then
    if [ -f /etc/shells ]; then
      shells_file=/etc/shells
    elif [ -f /usr/share/defaults/etc/shells ]; then
      shells_file=/usr/share/defaults/etc/shells
    else
      fmt_error "could not find /etc/shells file. Change your default shell manually."
      return
    fi

    if ! zsh=$(command -v zsh) || ! grep -qx "$zsh" "$shells_file"; then
      if ! zsh=$(grep '^/.*/zsh$' "$shells_file" | tail -1) || [ ! -f "$zsh" ]; then
        fmt_error "no zsh binary found or not present in '$shells_file'"
        fmt_error "change your default shell manually."
        return
      fi
    fi
  fi

  if [ -n "$SHELL" ]; then
    echo "$SHELL" > ${USERHOME}/.shell.pre-oh-my-zsh
  else
    grep "^$USERNAME:" /etc/passwd | awk -F: '{print $7}' > ${USERHOME}/.shell.pre-oh-my-zsh
  fi

  if ! chsh -s "$zsh"; then
    fmt_error "chsh command unsuccessful. Change your default shell manually."
  else
    export SHELL="$zsh"
    echo "${GREEN}Shell successfully changed to '$zsh'.${RESET}"
  fi

  echo
}

print_success() {
  printf '%s         %s__      %s           %s        %s       %s     %s__   %s\n' $RAINBOW $RESET
  printf '%s  ____  %s/ /_    %s ____ ___  %s__  __  %s ____  %s_____%s/ /_  %s\n' $RAINBOW $RESET
  printf '%s / __ \%s/ __ \  %s / __ `__ \%s/ / / / %s /_  / %s/ ___/%s __ \ %s\n' $RAINBOW $RESET
  printf '%s/ /_/ /%s / / / %s / / / / / /%s /_/ / %s   / /_%s(__  )%s / / / %s\n' $RAINBOW $RESET
  printf '%s\____/%s_/ /_/ %s /_/ /_/ /_/%s\__, / %s   /___/%s____/%s_/ /_/  %s\n' $RAINBOW $RESET
  printf '%s    %s        %s           %s /____/ %s       %s     %s          %s....is now installed!%s\n' $RAINBOW $GREEN $RESET
  printf '\n'
  printf '\n'
  printf "%s %s %s\n" "Before you scream ${BOLD}${YELLOW}Oh My Zsh!${RESET} look over the" \
    "$(fmt_code "$(fmt_link ".zshrc" "file://$HOME/.zshrc" --text)")" \
    "file to select plugins, themes, and options."
  printf '\n'
  printf '%s\n' "• Follow us on Twitter: $(fmt_link @ohmyzsh https://twitter.com/ohmyzsh)"
  printf '%s\n' "• Join our Discord community: $(fmt_link "Discord server" https://discord.gg/ohmyzsh)"
  printf '%s\n' "• Get stickers, t-shirts, coffee mugs and more: $(fmt_link "Planet Argon Shop" https://shop.planetargon.com/collections/oh-my-zsh)"
  printf '%s\n' $RESET
}

main() {
  if [ ! -t 0 ]; then
    RUNZSH=no
    CHSH=no
  fi

  while [ $# -gt 0 ]; do
    case $1 in
      --unattended) RUNZSH=no; CHSH=no ;;
      --skip-chsh) CHSH=no ;;
      --keep-zshrc) KEEP_ZSHRC=yes ;;
    esac
    shift
  done

  setup_color

  if ! command_exists zsh; then
    echo "${YELLOW}Zsh is not installed.${RESET} Please install zsh first."
    exit 1
  fi

  setup_zshrc
  setup_shell

  print_success

  if [ $RUNZSH = no ]; then
    echo "${YELLOW}Run zsh to try it out.${RESET}"
    exit
  fi

  #exec zsh -l
}

main "$@"
