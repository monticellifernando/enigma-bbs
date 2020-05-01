#!/usr/bin/env bash

{ # this ensures the entire script is downloaded before execution

ENIGMA_NODE_VERSION=${ENIGMA_NODE_VERSION:=10}
ENIGMA_BRANCH=${ENIGMA_BRANCH:=master}
ENIGMA_INSTALL_DIR=${ENIGMA_INSTALL_DIR:=$HOME/enigma-bbs}
ENIGMA_SOURCE=${ENIGMA_SOURCE:=https://github.com/monticellifernando/enigma-bbs.git}
TIME_FORMAT=`date "+%Y-%m-%d %H:%M:%S"`
WAIT_BEFORE_INSTALL=10

enigma_header() {
    clear
    cat << EndOfMessage
                                                                     ______
_____________________   _____  ____________________    __________\\_   /
\\__   ____/\\_ ____   \\ /____/ /   _____ __         \\  /   ______/ // /___jp!
 //   __|___//   |    \\//   |//   |    \\//  |  |    \\//        \\ /___   /_____
/____       _____|      __________       ___|__|      ____|     \\   /  _____  \\
---- \\______\\ -- |______\\ ------ /______/ ---- |______\\ - |______\\ /__/ // ___/
                                                                       /__   _\\
       <*> ENiGMA½ // https://github.com/NuSkooler/enigma-bbs <*>        /__/

ENiGMA½ will be installed to ${ENIGMA_INSTALL_DIR}, from source ${ENIGMA_SOURCE}, branch ${ENIGMA_BRANCH}.

ENiGMA½ requires Node.js. Version ${ENIGMA_NODE_VERSION}.x current will be installed via nvm. If you already have nvm installed, this install script will update it to the latest version.

If this isn't what you were expecting, hit CTRL-C now. Installation will continue in ${WAIT_BEFORE_INSTALL} seconds...

EndOfMessage
    sleep ${WAIT_BEFORE_INSTALL}
}

fatal_error() {
    printf  "${TIME_FORMAT} \e[41mERROR:\033[0m %b\n" "$*" >&2;
    exit 1
}

enigma_install_needs() {
    echo "Checking $1 installation"
    command -v $1 >/dev/null 2>&1 || fatal_error "ENiGMA½ requires $1 but it's not installed. Please install it and restart the installer."
}

log()  {
    printf "${TIME_FORMAT} %b\n" "$*";
}

enigma_install_init() {
    enigma_install_needs git
    enigma_install_needs curl
    enigma_install_needs python
    enigma_install_needs make
    enigma_install_needs gcc
}

install_nvm() {
    log "Installing nvm"
    curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
}

configure_nvm() {
    log "Installing Node ${ENIGMA_NODE_VERSION} via nvm"
    . ~/.nvm/nvm.sh
    nvm install ${ENIGMA_NODE_VERSION}
    nvm use ${ENIGMA_NODE_VERSION}
}

download_enigma_source() {
    local INSTALL_DIR
    INSTALL_DIR=${ENIGMA_INSTALL_DIR}

    if [ -d "$INSTALL_DIR/.git" ]; then
        log "ENiGMA½ is already installed in $INSTALL_DIR, trying to update using git"
        command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" fetch 2> /dev/null ||
            fatal_error "Failed to update ENiGMA½, run 'git fetch' in $INSTALL_DIR yourself."
    else
        log "Downloading ENiGMA½ from git to '$INSTALL_DIR'"
        mkdir -p "$INSTALL_DIR"
        command git clone ${ENIGMA_SOURCE} "$INSTALL_DIR" ||
            fatal_error "Failed to clone ENiGMA½ repo. Please report this!"
    fi
}

is_arch_arm() {
    local ARCH=`arch`
    if [[ $ARCH == "arm"* ]]; then
        true
    else
        false
    fi
}

extra_npm_install_args() {
    if is_arch_arm ; then
        echo "--build-from-source"
    else
        echo ""
    fi
}

install_node_packages() {
    log "Installing required Node packages..."
    log "Note that on some systems such as RPi, this can take a VERY long time. Be patient!"

    cd ${ENIGMA_INSTALL_DIR}
    local EXTRA_NPM_ARGS=$(extra_npm_install_args)
    git checkout ${ENIGMA_BRANCH} && npm install ${EXTRA_NPM_ARGS}
    if [ $? -eq 0 ]; then
        log "npm package installation complete"
    else
        fatal_error "Failed to install ENiGMA½ npm packages. Please report this!"
    fi
}

enigma_footer() {
    log "ENiGMA½ installation complete!"
    echo -e "\e[33m"
    cat << EndOfMessage
If this is the first time you've installed ENiGMA½, you now need to generate a minimal configuration. To do so, run the following commands (note: if you did not already have node.js installed, you may need to log out/back in to refresh your path):

  cd ${ENIGMA_INSTALL_DIR}
  ./oputil.js config new

Additionally, the following support binaires are recommended:
  7zip: Archive support
    Debian/Ubuntu : apt-get install p7zip
    CentOS        : yum install p7zip

  Lha: Archive support
    Debian/Ubuntu : apt-get install lhasa

  Arj: Archive support
    Debian/Ubuntu : apt-get install arj

  sz/rz: Various X/Y/Z modem support
    Debian/Ubuntu : apt-get install lrzsz
    CentOS        : yum install lrzsz

  See docs for more information!

EndOfMessage
    echo -e "\e[39m"
}

enigma_header
enigma_install_init
install_nvm
configure_nvm
download_enigma_source
install_node_packages
enigma_footer

} # this ensures the entire script is downloaded before execution
