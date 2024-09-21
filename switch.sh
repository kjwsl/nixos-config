#!/usr/bin/bash

SCRIPT_PATH=$(dirname -- ${BASH_SOURCE[0]})
DEBUG=1
BUILD_HOME="home-manager/master"
BUILD_DARWIN="nix-darwin"
PLATFORM_BUILD_CMD=""
BUILD_CMD="nix run ${PLATFORM_BUILD_CMD} build -- --flake ${SCRIPT_PATH}"

debug() {
    if [ -n "$DEBUG" ]; then
        echo $@
    fi
}

platform_menu() {
    PS3="Choose Platform: "
    platform_options=("Home" "Darwin" "NixOS" "Quit")
    select opt in "${platform_options[@]}"
do
    case $opt in
        "Home")
            PLATFORM_BUILD_CMD="home-manager/master"
            ;;
        "Darwin")
            PLATFORM_BUILD_CMD="nix-darwin"
            ;;
        "Quit")
            echo "Quitting... "
            exit 0;
            ;;
        *) echo "invalid option $REPLY";;
    esac
    BUILD_CMD="nix run ${PLATFORM_BUILD_CMD} build -- --flake ${SCRIPT_PATH}"
    debug "Build Command: ${BUILD_CMD}"
    echo ${BUILD_CMD}
    return 0
done
}

build() {
    BUILD_CMD=$1
    readarray -t changed_files <<<$(git diff --name-only)
    debug "Changed files: ${changed_files[@]}"

    ${BUILD_CMD}
    if [ $? -ne 0 ]; then
        log_msg=""
        for file in "${changed_files[@]}"; do
            debug "Checking for $file"
            log_msg="${log_msg}$(grep --color=always -n -e \"/nix/store/*/${file}*\" <<<${err_msg})"
        done
        if [ -z "$log_msg" ]; then
            echo $err_msg
            echo "The error message doesn't include any of the changed files."
            exit 1
        fi
        sort -u <<<${log_msg}
        exit 1
    fi
}

commit() {
    now=$(date "+%Y-%m-%d %H:%M:%S")
    echo "Committing the changes..."
    git commit -am "[${now}] nix-darwin: update system configuration" || true
}


switch() {
    echo "Switching to the new configuration..."
    result/sw/bin/darwin-rebuild switch --flake . --show-trace
}

BUILD_CMD=$(platform_menu)
build BUILD_CMD
commit
switch

