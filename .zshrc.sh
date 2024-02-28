# Check if .oh-my-zsh is installed, install if not
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tool
s/install.sh)"
fi

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; the
n
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi




# If you come from bash you might have to change your $PATH.
export REPOS=$HOME/repos
export ZSH="$HOME/.oh-my-zsh"
export NVM_DIR=$HOME/.nvm
export FZF_DIR=$HOME/.fzf
export EMACS_LISP=$HOME/.emacs.d/lisp/
export YARN_DIR=$HOME/.yarn
export YARN_GLOBAL_FOLDER=$YARN_DIR/global_packages
export NINJA_DIR=$REPOS/ninja/build
export CARGO_BIN=$HOME/.cargo/bin
export BAT_STYLE="default"
export FZF_BIN=$REPOS/fzf/bin
export NEOVIM_BIN=/usr/bin/nvim
export BAT_DIR=$REPOS/bat/target/release
export FD_DIR=$REPOS/fd/target/release
export PATH=$REPOS/vcpkg:$HOME/bin:/usr/local/bin:$HOME/.local/share:$NINJA_DIR:$CARG
O_BIN:$FZF_BIN:$BAT_DIR:$FD_DIR:$PATH
export FZF_DEFAULT_OPTS='--color=bg+:#3F3F3F,bg:#4B4B4B,border:#6B6B6B,spinner:#98BC9
9,hl:#719872,fg:#D9D9D9,header:#719872,info:#BDBB72,pointer:#E12672,marker:#E17899,fg
+:#D9D9D9,preview-bg:#3F3F3F,prompt:#98BEDE,hl+:#98BC99'



# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# * You will not see this error message again.
# * Zsh will start quickly but prompt will jump down after initialization.

# - Disable instant prompt either by running p10k configure or by manually
# defining the following parameter:

#typeset -g POWERLEVEL9K_INSTANT_PROMPT=off



ZSH_THEME="agnoster"

plugins=( 
    git
    archlinux
    virtualenvwrapper
    fzf
    fd
    pylint
    git-prompt
    glassfish
    gnu-utils
    git-extras
    github
    npm
    nvm
    tmux
    zsh-interactive-cd
    zsh-navigation-tools
    systemd
    toolbox
    tmuxinator
    python
    autoenv
    autopep8
    starship
    systemadmin
    ssh
    ssh-agent
    textastic
    textmate
    dotenv
    rake
    bundler
)

source $ZSH/oh-my-zsh.sh

### From this line is for pywal-colors
# Import colorscheme from 'wal' asynchronously
# &   # Run the process in the background.
# ( ) # Hide shell job control messages.
# Not supported in the "fish" shell.
(cat ~/.cache/wal/sequences &)

# Alternative (blocks terminal for 0-3ms)
#cat ~/.cache/wal/sequences

# To add support for TTYs this line can be optionally added.
source ~/.cache/wal/colors-tty.sh
# sourcing powerlevel10k theme

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

sudo ryzenadj --max-performance > /dev/null 2>&1 # enabling max performance

# Aliases

alias freshZsh='source $HOME/.zshrc'
alias editZsh='sudo nano $HOME/.zshrc'
alias nvimZsh='sudo nvim $HOME/.zshrc'
alias freshBash='source $HOME/.bashrc'
alias editBash='sudo nano $HOME/.bashrc'
alias nvimBash='sudo nvim $HOME/.bashrc'
alias sudoyay='yay --batchinstall --sudoloop --asdeps'
alias autoyay='yay --batchinstall --sudoloop --asdeps --noconfirm'
alias vimZsh='sudo vim ~/.zshrc'
alias getip="ip addr | grep 'inet ' \
    | grep -v '127.0.0.1' | awk '{print \$2}' | cut -d/ -f1"
alias fzfind='fzf --print0 | xargs -0 -o nvim'
# Functions


clone() {
    local repo=$1
    # Check if $2 is provided and not empty; if so, use $2, otherwise use $REPOS
    local target_dir=${2:-$REPOS}

    # Define the build directory for AUR packages
    local build_dir=~/build_src_dir
    mkdir -p "$build_dir"

    # Clone AUR packages
    if [[ $repo == http* ]]; then
        if [[ $repo == *aur.archlinux.org* ]]; then
            # Clone the AUR repository
            git -C "$build_dir" clone "$repo"
            local repo_name=$(basename "$repo" .git)
            pushd "$build_dir/$repo_name" > /dev/null

            # Build or install based on the second argument
            if [[ $target_dir == "build" ]]; then
                makepkg --syncdeps
            elif [[ $target_dir == "install" ]]; then
                makepkg -si
            fi

            popd > /dev/null
        else
            # Clone non-AUR links
            git clone "$repo" "$target_dir"
        fi
    else
        # Clone GitHub repos given in the format username/repository
        # Ensure the target directory for plugins exists
        git clone "https://github.com/$repo.git" --recurse-submodules "$target_dir"
    fi
}

function addalias() {
    echo "alias $1='$2'" | sudo tee -a ~/.zshrc
    freshZsh
}


export host1=$(getip)
#host2="heini@192.168.1.71"

function scp_transfer() {
    local direction=$1
    local src_path=$2
    local dest_path=$3
    local host_alias=$4

    # Retrieve the actual host address from the alias
    local host_address=$(eval echo "\$$host_alias")

    if [[ $direction == "TO" ]]; then
        scp $src_path ${host_address}:$dest_path
    elif [[ $direction == "FROM" ]]; then
        scp ${host_address}:$src_path $dest_path
    else
        echo "Invalid direction. Use TO or FROM."
    fi
}

check_and_install_packages() {
  local missing_packages=()

  # Check which packages are not installed
  for package in "$@"; do
    if ! pacman -Qi "$package" &> /dev/null; then
      missing_packages+=("$package")
    else
      echo "Package '$package' is already installed."
    fi
  done

  # If there are missing packages, ask the user if they want to install them
  if [ ${#missing_packages[@]} -ne 0 ]; then
    echo "The following packages are not installed: ${missing_packages[*]}"
    read -p "Do you want to install them? (Y/n) " -n 1 -r
    echo    # Move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
      for package in "${missing_packages[@]}"; do
        yes | sudo pacman -S "$package"
        if [ $? -ne 0 ]; then
          echo "Failed to install $package. Aborting."
          exit 1
        fi
      done
    else
      echo "The following packages are required to continue:\
      ${missing_packages[*]}. Aborting."
      exit 1
    fi
  fi
}

check_if_pyEnv_exists() {
    local my_zshrc_dir=~/.zshrc
    local my_virtEnv_dir=~/virtualPyEnvs
    local py_env_name=pyEnv
    local pkg1=python-virtualenv
    local pkg2=python-virtualenvwrapper
    sudo pacman -S --needed --noconfirm $pkg1 $pkg2
    # Check if the virtual environment directory exists
    if [ ! -d "$my_virtEnv_dir" ]; then
        echo "Python Virtualenv and directory doesn't exist, creating it ..."
        sleep 1
        mkdir -p $my_virtEnv_dir
        # Use $1 to check if a custom environment name is provided
        local env_name=${1:-$py_env_name}
        echo "Creating virtual environment: $env_name"
        virtualenv $my_virtEnv_dir/$env_name --system-site-packages --symlinks
      echo "alias startEnv='source /home/$USER/'virtualPyEnvs/pyEnv/bin/activate" >> 
~/.zshrc
    else
        echo "Python virtualenv directory exists ..."
        # Check if the standard pyEnv exists or if a custom name is provided
        if [ -z "$1" ] && [ -e "$my_virtEnv_dir/$py_env_name/bin/activate" ]; then
            echo "pyenv directory exists, and no argument, exiting.."
            sleep 2
            exit 1
        else
            # Create a virtual environment with the provided name or the default one
            local env_name=${1:-$py_env_name}
            echo "Creating virtual environment: $env_name"
            virtualenv $my_virtEnv_dir/$env_name --system-site-packages --symlinks
        fi
    fi
}

export vcpkgPATH='"-DCMAKE_TOOLCHAIN_FILE=$HOME/repos/vcpkg/scripts/buildsystems/vcpk
g.cmake"'


Default_pyEnv_Trigger(){
    local zshrcFile=/home/$USER/.zshrc
    default_pyEnv=/home/$USER/virtualPyEnvs/pyEnv/bin/activate
    if [ ! -f "$default_pyEnv" ]; then
        check_if_pyEnv_exists

    fi
}


function setup_oh_my_zsh_and_plugins() {
    local ZSH="$HOME/.oh-my-zsh"
    local ZSH_REPO_PATH="$ZSH/repos"
    local plugins=(zsh-syntax-highlighting zsh-autosuggestions zsh-completions zsh-hi
story-substring-search)

    # Check and clone Oh My Zsh
    if [ ! -d "$ZSH" ]; then
        clone ohmyzsh/ohmyzsh "$ZSH"
    fi

    # Ensure the repos directory exists
    mkdir -p "$ZSH_REPO_PATH"

    # Check and clone each plugin
    for plugin in "${plugins[@]}"; do
        if [ ! -d "$ZSH_REPO_PATH/$plugin" ]; then
        clone "zsh-users/$plugin" "$ZSH_REPO_PATH/$plugin"
        fi
    done

    # Source the plugins
    for plugin in "${plugins[@]}"; do
        local plugin_path="$ZSH_REPO_PATH/$plugin"
        if [ -d "$plugin_path" ]; then
            for file in "$plugin_path"/*.zsh; do
                source "$file"
            done
        fi
    done
}

setup_oh_my_zsh_and_plugins
Default_pyEnv_Trigger

#alias startEnv='source $HOME/virtualPyEnvs/pyEnv/bin/activa'
alias startEnv="source /home/$USER/virtualPyEnvs/pyEnv/bin/activate"


source /usr/share/nvm/init-nvm.sh
[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/nvm.sh
source /usr/share/nvm/bash_completion
source /usr/share/nvm/install-nvm-exec

alias find='fd'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


#fzf --bind 'enter:become(vim {})'

source /usr/share/autoenv-git/activate.sh
eval "$(starship init zsh)"
