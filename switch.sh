#!/usr/bin/bash

DEBUG=1
debug() {
    if [ -n "$DEBUG" ]; then
        echo $@
    fi
}

menu() {
    PS3="Choose Platform: "
    platform_options=("Home" "Darwin" "Quit")
    select opt in "${options[@]}"
do
    case $opt in
        "Option 1")
            echo "you chose choice 1"
            ;;
        "Option 2")
            echo "you chose choice 2"
            ;;
        "Option 3")
            echo "you chose choice $REPLY which is $opt"
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac

    # echo "╭------------------------------------------------╮"
    # echo "| 1. Home, 2. Nix Darwin                         |"
    # echo "╰------------------------------------------------╯"
    # read -p "Select: " in
    # debug "input: ${in}"
    #
    # if [[ $in == 1 ]]; then
    # fi
    # if [[ $in == 2 ]]; then
    # fi
    # debug "Platform selected: ${plat}"

}

readarray -t changed_files <<<$(git diff --name-only)
debug "Changed files: ${changed_files[@]}"

nix run nix-darwin build -- --flake . --show-trace
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

now=$(date "+%Y-%m-%d %H:%M:%S")
echo "Committing the changes..."
git commit -am "[${now}] nix-darwin: update system configuration" || true

echo "Switching to the new configuration..."
result/sw/bin/darwin-rebuild switch --flake . --show-trace
