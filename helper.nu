#! /usr/bin/env nix
#! nix shell nixpkgs#nushell nixpkgs#nh --command nu

def get_os_string []: [ nothing -> string, nothing -> nothing ] {
  let os_str = (sys host | get name?)

  if $os_str != null {
    $os_str | str downcase
  } else {
    null
  }
}

def get_hostname []: [ nothing -> string ] {
  (hostname | str trim)
}

# Build and switch system configuration (NixOS/Darwin with integrated home-manager)
def "main system" [
  action: string = "switch"  # switch, build, or test
  os?: string # nixos, darwin, or auto-detect
  --hostname (-H): string = "" # hostname (auto-detected if omitted)
] {
  let os_str = if $os != null { $os } else { get_os_string }
  if $os_str == null {
    print "❌ Unable to detect OS"
    exit 1
  }

  let host = if $hostname == "" { get_hostname } else { $hostname }

  let command = match $os_str {
    "nixos" => "os"
    "darwin" => "darwin"
    _ => "unknown"
  }

  if $command == "unknown" {
    print "❌ System rebuilds only work on NixOS or macOS"
    exit 1
  }

  print $"🔨 Building system ($action) for ($os_str) on host ($host)..."

  nh $command $action . -H $host -a
  print "✅ System configuration applied!"
}

# Build and switch home-manager configuration (standalone for non-NixOS systems)
def "main home" [
  action: string = "switch" # build, switch, or test
  system?: string  # linux, darwin, termux, or auto-detect (termux can't be detected)
] {

  let os = if $system != null { $system } else { get_os_string }
  if $os == null {
    print "❌ Unable to detect OS"
    exit 1
  }

  print $"🏠 Switching home-manager for ($os)..."
  nh home $action . -c $os -o result -b backup -a
  print "✅ Home configuration applied!"
}

# Update flake inputs
def "main update" [
  input?: string  # specific input to update, or all if omitted
] {
  if $input != null {
    print $"📦 Updating flake input: ($input)..."
    nix flake update $input
  } else {
    print "📦 Updating all flake inputs..."
    nix flake update
  }
  print "✅ Flake inputs updated!"
}

# Run garbage collection
def "main gc" [
  --older-than (-d): string = "7d"  # delete generations older than this
] {
  print $"🧹 Running garbage collection (older than ($older_than))..."
  nix-collect-garbage --delete-older-than $older_than
  print "✅ Garbage collection complete!"
}

# Check flake for errors
def "main check" [] {
  print "🔍 Checking flake..."
  nix flake check --no-build
  print "✅ Flake check passed!"
}

# Install git hooks from .githooks/ into this repo
def "main hooks" [
  --status (-s)  # show hook status instead of installing
] {
  if $status {
    print "🪝 Hook status:"
    let global = ($"($env.HOME)/.config/git/templates/hooks/pre-push" | path exists)
    let repo = (".githooks/pre-push" | path exists)
    let local_hook = (".git/hooks/pre-push" | path exists)
    let td_raw = (do { git config --global init.templateDir } | complete | get stdout | str trim)
    let template_dir = if ($td_raw | is-empty) { "not set" } else { $td_raw }
    print $"  Global template dir: ($template_dir)"
    print $"  Global pre-push:     (if $global { '✅ installed' } else { '❌ missing (run home-manager switch)' })"
    print $"  .git/hooks/pre-push: (if $local_hook { '✅ installed (chains to .githooks/)' } else { '❌ run: git init' })"
    print $"  Repo-local pre-push: (if $repo { '✅ .githooks/pre-push' } else { '—  none' })"
    return
  }
  print "🪝 Seeding hooks from template..."
  # Re-init copies template hooks into .git/hooks/ (safe, non-destructive)
  git init out+err>| ignore
  # Ensure repo-local hooks are executable
  if (".githooks" | path exists) {
    ls .githooks | get name | each { |f| chmod +x $f }
  }
  print "✅ Hooks installed!"
  print "   .git/hooks/pre-push (global: secret scan + flake check)"
  print "   .githooks/pre-push  (repo-local: system attr eval)"
  print "   Global hooks are managed via home-manager (modules/tools/git.nix)"
}

# Format all nix files
def "main fmt" [] {
  print "🎨 Formatting nix files..."
  nix fmt
  print "✅ Formatting complete!"
}

# Show current system info and available commands
def "main info" [] {
  let os = get_os_string
  let user = $env.USER
  let host = get_hostname

  print $"📊 Current system: ($os)"
  print $"👤 Current user: ($user)"
  print $"🖥️  Hostname: ($host)"
  print ""
  print "Available commands:"
  print "  nu helper.nu system [switch|build|test]    # Full system (NixOS/macOS)"
  print "  nu helper.nu home [linux|darwin|termux]     # Home-manager only"
  print "  nu helper.nu secrets sync                   # Sync secrets from Bitwarden to sops"
  print "  nu helper.nu update [input]                 # Update flake inputs"
  print "  nu helper.nu gc [-d 7d]                     # Garbage collection"
  print "  nu helper.nu check                          # Check flake"
  print "  nu helper.nu fmt                            # Format nix files"
  print "  nu helper.nu hooks                          # Install repo-local git hooks"
  print "  nu helper.nu hooks --status                  # Show hook status"
  print "  nu helper.nu info                           # Show this info"
}

# Sync secrets from Bitwarden to encrypted sops file
def "main secrets sync" [] {
  if (which bw | is-empty) {
    print "❌ bitwarden-cli (bw) not found"
    return
  }
  
  if (which sops | is-empty) {
    print "❌ sops not found"
    return
  }

  print "🔐 Syncing secrets from Bitwarden..."
  
  # Ensure secrets and sops directories exist
  mkdir secrets
  mkdir $"($env.HOME)/.config/sops/age"

  # Fetch SSH key for decryption
  print "  - Fetching Default SSH Key Pair..."
  let ssh_item = (bw get item 3859a223-3757-4676-bdca-b40a00cb7488 | from json)
  let private_key = $ssh_item.sshKey.privateKey
  
  if ($private_key | is-empty) {
    print "❌ SSH Private Key not found in Bitwarden"
  } else {
    # Prepare temporary file for ssh-to-age conversion
    let temp_ssh = (mktemp --suffix .ssh)
    $private_key | save -f $temp_ssh
    chmod 600 $temp_ssh
    
    # Convert and save as age key
    (ssh-to-age -private-key -i $temp_ssh) | save -f $"($env.HOME)/.config/sops/age/keys.txt"
    rm $temp_ssh
    print "  - Age key derived from SSH and saved to ~/.config/sops/age/keys.txt"
  }

  # Fetch context7 API key
  print "  - Fetching Context7 API Key..."
  let ctx7_item = (bw list items --search context7 | from json | first)
  let ctx7_key = ($ctx7_item.fields | where name == "API Key" | get value | first)
  
  if ($ctx7_key | is-empty) {
    print "❌ Context7 API Key not found in Bitwarden"
    return
  }

  # Prepare temporary cleartext yaml
  let temp_yaml = (mktemp --suffix .yaml)
  $"context7-api-key: ($ctx7_key)" | save -f $temp_yaml

  # Encrypt with sops
  print "  - Encrypting to secrets/secrets.yaml..."
  sops --encrypt --config .sops.yaml --output secrets/secrets.yaml $temp_yaml
  
  rm $temp_yaml
  print "✅ Secrets synced and encrypted!"
}

# Helper script written in Nushell to build and switch system configurations
def main [] {
  main info
}
