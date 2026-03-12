#!/usr/bin/env nu

def "from conf" [] : string -> record {
  $in | lines | where not (str starts-with '#') | split row '=' | rename key value
}

def "to conf" [] : record -> string {
  $in | items { |k, v| $"($k) = ($v | str join ' ')" } | str join '\n'
}

# Enable nix-command and flake experimental features
def setup-nix-config []: nothing -> nothing {
  print "🛠️  Configuring nix..."

  const default_nix_conf = {
    experimental-features: [ 'nix-command' 'flakes' ]
  }

  if not ('~/.config/nix/nix.conf' | path exists) {
    print "`nix.conf` not found, creating..."

    mkdir ~/.config/nix
    $default_nix_conf | to conf | save -f ~/.config/nix/nix.conf

    print "🛠️  Created ~/.config/nix/nix.conf"

    return
  }

  mut conf = try { open ~/.config/nix/nix.conf | from conf | get '' } catch { $default_nix_conf }

  mut experimental_features = try { $conf.experimental-features | split row ' '} catch { [] }
  print $"🛠️  Current experimental features: ($experimental_features)"


  mut changed = false
  if ('nix-command' not-in $experimental_features) {
    print "🛠️  Enabling nix-command experimental feature..."
    $experimental_features ++= [ 'nix-command' ]
    $changed = true
  } 
  if ('flakes' not-in $experimental_features) {
    print "🛠️  Enabling flake experimental feature..."
    $experimental_features ++= [ 'flakes' ]
    $changed = true
  }

  if $changed {
    print "🛠️  Saving nix.conf..."
    $conf.experimental-features = $experimental_features
    $conf | to conf | save -f ~/.config/nix/nix.conf
  } else {
    print "🛠️  nix.conf already configured"
  }
}

# Get current OS
def get-os-str []:  nothing -> string {
  # nix-on-droid (Android) sets ANDROID_ROOT; check before sys host
  if ($env.ANDROID_ROOT? | is-not-empty) {
    return "android"
  }

  let os_str = (sys host | get name?)

  if $os_str != null {
    $os_str | str downcase
  } else {
    ""
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
  print "🔨 Setting up system..."

  try {
  setup-nix-config
  } catch {
    print "❌ Failed to configure nix"
    exit 1
  }

  let os_str = if $os != null { $os } else { get-os-str }
  if $os_str == null {
    print "❌ Unable to detect OS"
    exit 1
  }

  let host = if $hostname == "" { get_hostname } else { $hostname }

  if $os_str == "android" {
    print $"🤖 Switching nix-on-droid configuration for host ($host)..."
    nix-on-droid switch --flake $".#($host)"
    print "✅ nix-on-droid configuration applied!"
    return
  }

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
  try {
  setup-nix-config
  } catch {
    print "❌ Failed to configure nix"
    exit 1
  }

  let os = if $system != null { $system } else { get-os-str }
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
  let os = get-os-str
  if $os == "darwin" {
    # nix flake check evaluates all nixosConfigurations even on Darwin,
    # which fails for Linux-only derivations — check only Darwin outputs instead
    nix eval .#darwinConfigurations --apply builtins.attrNames | ignore
    nix eval .#homeConfigurations --apply builtins.attrNames | ignore
  } else {
    nix flake check --no-build
  }
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
  nix fmt .
  print "✅ Formatting complete!"
}

# Show current system info and available commands
def "main info" [] {
  let os = get-os-str
  let user = $env.USER
  let host = get_hostname

  print $"📊 Current system: ($os)"
  print $"👤 Current user: ($user)"
  print $"🖥️  Hostname: ($host)"
  print ""
  print "Available commands:"
  print "  nu setup.nu system [switch|build|test]    # Full system (NixOS/macOS)"
  print "  nu setup.nu home [linux|darwin|android]    # Home-manager only (android = nix-on-droid)"
  print "  nu setup.nu secrets sync                   # Sync secrets from Bitwarden to sops"
  print "  nu setup.nu update [input]                 # Update flake inputs"
  print "  nu setup.nu gc [-d 7d]                     # Garbage collection"
  print "  nu setup.nu check                          # Check flake"
  print "  nu setup.nu fmt                            # Format nix files"
  print "  nu setup.nu hooks                          # Install repo-local git hooks"
  print "  nu setup.nu hooks --status                  # Show hook status"
  print "  nu setup.nu info                           # Show this info"
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
