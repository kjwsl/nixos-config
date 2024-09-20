#!/usr/bin/bash

DEBUG=1
debug() {
    if [ -n "$DEBUG" ]; then
        echo $@
    fi
}

readarray -t changed_files <<<$(git diff --name-only)
debug "Changed files: ${changed_files[@]}"

err_msg=$(nix run nix-darwin build -- --flake . --show-trace 2>&1)
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
results/sw/bin/darwin-rebuild switch --flake . --show-trace
