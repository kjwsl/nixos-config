#!/usr/bin/env nu

def "from conf" [] : string -> record {
  $in 
  | lines 
  | parse "{key} = {value}"
  | group-by key
  | items { |k, v| { key: $k, value: ($v.value | str join " ") } }
  | transpose -rd
}

def "to conf" [] : record -> string {
  $in 
  | items { |k, v| 
      let val = if ($v | describe) == "list<any>" { $v | str join " " } else { $v }
      $"($k) = ($val)" 
    } 
  | str join "\n"
}

# Ensure nix-command and flake experimental features are enabled
def setup-nix-config []: nothing -> nothing {
  let nix_conf_path = ($env.HOME | path join ".config" "nix" "nix.conf")
  let default_config = { "experimental-features": ["nix-command", "flakes"] }

  if not ($nix_conf_path | path exists) {
    print "🛠️  Creating ~/.config/nix/nix.conf..."
    mkdir ($nix_conf_path | path dirname)
    $default_config | to conf | save -f $nix_conf_path
    return
  }

  mut conf = try { open $nix_conf_path | from conf } catch { {} }
  let current_features = ($conf | get -o "experimental-features" | default "" | split row " " | where { $in != "" })
  
  let missing = (["nix-command", "flakes"] | where { $in not-in $current_features })

  if ($missing | is-not-empty) {
    print $"🛠️  Enabling missing features: ($missing | str join ', ')..."
    let new_features = ($current_features | append $missing | uniq)
    $conf = ($conf | upsert "experimental-features" ($new_features | str join " "))
    $conf | to conf | save -f $nix_conf_path
  } else {
    print "✅ nix.conf already configured with flakes and nix-command."
  }
}

# Get current OS
def get-os-str []: nothing -> string {
  if ($env.ANDROID_ROOT? | is-not-empty) { return "android" }
  let name = (sys host | get name | str downcase)
  if ($name | str contains "nixos") { return "nixos" }
  $name
}

def get-hostname []: nothing -> string {
  hostname | str trim
}

# Common pre-setup tasks
def run-pre-setup []: nothing -> string {
  try { setup-nix-config } catch { 
    error make { msg: "❌ Failed to configure nix" } 
  }
  
  let os = get-os-str
  if ($os | is-empty) {
    error make { msg: "❌ Unable to detect OS" }
  }
  $os
}

# Build and switch system configuration (NixOS/Darwin with integrated home-manager)
def "main system" [
  action: string = "switch"  # switch, build, or repl
  os?: string                # nixos, darwin, or auto-detect
  --hostname (-H): string = "" # hostname (auto-detected if omitted)
  --update (-u) = false
  --ask (-a) = false

] {
  print "🔨 Setting up system..."

  let os_detected = run-pre-setup
  let os_str = if $os != null { $os } else { $os_detected }
  let host = if $hostname == "" { get-hostname } else { $hostname }

  if $os_str == "android" {
    print $"🤖 Switching nix-on-droid configuration for host ($host)..."
    nix-on-droid switch --flake $".#($host)"
    return
  }

  let command = match $os_str {
    "nixos" => "os",
    "darwin" | "macos" => "darwin",
    _ => { error make { msg: $"❌ System rebuilds only work on NixOS or macOS (detected: ($os_str))" } }
  }

  let ask = if $ask { "--ask" } else { "" }
  let update = if $update { "--update" } else { "" }

  print $"🔨 Building system ($action) for ($os_str) on host ($host)..."
  nh $command $action . -H $host $ask $update
  print "✅ System configuration applied!"
}

# Build and switch home-manager configuration (standalone for non-NixOS systems)
def "main home" [
  action: string = "switch" # build, switch, or repl
  system?: string           # linux, darwin, termux, or auto-detect
] {
  print "🔨 Setting up home-manager..."

  let os_detected = run-pre-setup
  mut os = if $system != null { $system } else { $os_detected }
  
  # Map android/nixos to their home-manager standalone names
  if $os == "android" { $os = "termux" }
  if $os == "nixos" { $os = "linux" }

  print $"🏠 ($action)ing home configuration for ($os)..."
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
  if $os == "darwin" or $os == "macos" {
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
    print "🪝  Hook status:"
    let global = ($env.HOME | path join ".config" "git" "templates" "hooks" "pre-push" | path exists)
    let repo = (".githooks" | path join "pre-push" | path exists)
    let local_hook = (".git" | path join "hooks" "pre-push" | path exists)
    let td_raw = (do { git config --global init.templateDir } | complete | get stdout | str trim)
    let template_dir = if ($td_raw | is-empty) { "not set" } else { $td_raw }
    
    [
      { Component: "Global template dir", Status: $template_dir }
      { Component: "Global pre-push", Status: (if $global { "✅ installed" } else { "❌ missing (run home-manager switch)" }) }
      { Component: ".git/hooks/pre-push", Status: (if $local_hook { "✅ installed (chains to .githooks/)" } else { "❌ run: git init" }) }
      { Component: "Repo-local pre-push", Status: (if $repo { "✅ .githooks/pre-push" } else { "— none" }) }
    ]
    return
  }

  print "🪝  Seeding hooks from template..."
  git init out+err>| ignore
  if (".githooks" | path exists) {
    ls .githooks | each { |f| chmod +x $f.name }
  }
  print "✅ Hooks installed!"
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
  let host = get-hostname

  print $"📊 System Info:"
  [
    { Metric: "OS", Value: $os }
    { Metric: "User", Value: $env.USER }
    { Metric: "Hostname", Value: $host }
  ]

  print "\n🚀 Available commands:"
  [
    { Command: "system [switch|build|test]", Description: "Full system rebuild (NixOS/macOS)" }
    { Command: "home [linux|darwin|termux]", Description: "Home-manager standalone switch" }
    { Command: "secrets sync", Description: "Sync secrets from Bitwarden to sops" }
    { Command: "update [input]", Description: "Update flake inputs" }
    { Command: "gc [-d 7d]", Description: "Run garbage collection" }
    { Command: "check", Description: "Check flake for errors" }
    { Command: "fmt", Description: "Format nix files" }
    { Command: "hooks [--status]", Description: "Install or check git hooks" }
  ]
}

# Sync secrets from Bitwarden to encrypted sops file
def "main secrets sync" [] {
  let missing_deps = (["bw", "sops", "ssh-to-age"] | where { (which $in | is-empty) })
  if ($missing_deps | is-not-empty) {
    error make { msg: $"❌ Missing dependencies: ($missing_deps | str join ', ')" }
  }

  print "🔐 Syncing secrets from Bitwarden..."
  
  mkdir secrets
  let age_dir = ($env.HOME | path join ".config" "sops" "age")
  mkdir $age_dir

  # Fetch SSH key for decryption
  print "  - Fetching Default SSH Key Pair..."
  let ssh_item = (bw get item 3859a223-3757-4676-bdca-b40a00cb7488 | from json)
  let private_key = ($ssh_item | get -o sshKey.privateKey)
  
  if ($private_key | is-not-empty) {
    let temp_ssh = (mktemp --suffix .ssh)
    try {
      $private_key | save -f $temp_ssh
      chmod 600 $temp_ssh
      (ssh-to-age -private-key -i $temp_ssh) | save -f ($age_dir | path join "keys.txt")
      print "  ✅ Age key derived and saved."
    } catch { |err|
        print $"⚠️  Error deriving age key: ($err.msg)"
    }
    rm -f $temp_ssh
  } else {
    print "⚠️  SSH Private Key not found in Bitwarden"
  }

  # Fetch context7 API key
  print "  - Fetching Context7 API Key..."
  let ctx7_item = (bw list items --search context7 | from json | first)
  let ctx7_key = ($ctx7_item | get -o fields | where name == "API Key" | get -o value.0)
  
  if ($ctx7_key | is-empty) {
    print "❌ Context7 API Key not found in Bitwarden"
    return
  }

  let temp_yaml = (mktemp --suffix .yaml)
  try {
    { "context7-api-key": $ctx7_key } | to yaml | save -f $temp_yaml
    sops --encrypt --config .sops.yaml --output secrets/secrets.yaml $temp_yaml
    print "✅ Secrets synced and encrypted!"
  } catch { |err|
      print $"⚠️  Error syncing secrets: ($err.msg)"
  }
  rm -f $temp_yaml
}

# Helper script written in Nushell to build and switch system configurations
def main [] {
  main info
}
