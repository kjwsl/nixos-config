#!/usr/bin/env nu

const SYSTEMS = {
  nixos:   { label: "NixOS",        nh_cmd: "os",     home: "linux" },
  darwin:  { label: "macOS",        nh_cmd: "darwin", home: "darwin" },
  android: { label: "nix-on-droid", nh_cmd: "android", home: "termux" },
  linux:   { label: "Linux",        nh_cmd: "os",     home: "linux" }
}

# Robust parser for key=value config files (like nix.conf)
def "from conf" [] : string -> record {
  $in 
  | lines 
  | where { not ($in | str starts-with "#") and ($in | str contains "=") }
  | split column -r '\s*=\s*' key value
  | group-by key
  | items { |k, v| { key: $k, value: ($v.value | str join " ") } }
  | transpose -rd
}

def "to conf" [] : record -> string {
  $in 
  | items { |k, v| 
      let val = if ($v | describe) =~ "list" { $v | str join " " } else { $v }
      $"($k) = ($val)" 
    } 
  | str join "\n"
}

# Ensure nix-command and flake experimental features are enabled
def setup-nix-config []: nothing -> nothing {
  print "🔧 Configuring Nix..."
  let nix_conf_path = ($env.HOME | path join ".config" "nix" "nix.conf")
  let required_features = ["nix-command", "flakes"]

  if not ($nix_conf_path | path exists) {
    mkdir ($nix_conf_path | path dirname)
    { "experimental-features": $required_features } | to conf | save -f $nix_conf_path
    return
  }

  mut conf = try { open $nix_conf_path | from conf } catch { {} }
  let current_features = ($conf | get -o "experimental-features" | default "" | split row " " | where { $in != "" })
  let missing = ($required_features | where { $in not-in $current_features })

  if ($missing | is-not-empty) {
    print $"🛠️  Enabling: ($missing | str join ', ')..."
    let new_features = ($current_features | append $missing | uniq)
    $conf = ($conf | upsert "experimental-features" ($new_features | str join " "))
    $conf | to conf | save -f $nix_conf_path
  }
}

# Get current OS info from the SYSTEMS table
def get-os-info []: nothing -> record {
  if ($env.ANDROID_ROOT? | is-not-empty) { return $SYSTEMS.android }
  let name = (sys host | get name | str downcase)
  if ($name | str contains "nixos") { return $SYSTEMS.nixos }
  if ($name | str contains "darwin") { return $SYSTEMS.darwin }
  $SYSTEMS.linux
}

# Build and switch system configuration
def "main system" [
  action: string = "switch"    # switch, build, or test
  os?: string                  # nixos, darwin, or android
  --hostname (-H): string = "" # hostname (auto-detected if omitted)
  --update (-u) = false
  --ask (-a) = false
] {
  setup-nix-config
  let info = if $os != null { $SYSTEMS | get $os } else { get-os-info }
  let host = if $hostname == "" { sys host | get hostname } else { $hostname }

  let host_label = if ($host | is-empty) { "" } else { $" for ($host)" }
  print $"🔨 Building ($info.label) ($action)($host_label)..."

  if $info.nh_cmd == "android" {
    let flake_target = if ($host | is-empty) { "." } else { $".#($host)" }
    nix-on-droid switch --flake $flake_target
  } else {
    let h_flag = if ($host | is-empty) { [] } else { ["-H" $host] }
    let flags = [] 
      | append (if $ask { ["--ask"] } else { [] }) 
      | append (if $update { ["--update"] } else { [] })
    
    nh $info.nh_cmd $action . ...$h_flag ...$flags
  }
  print "✅ Done!"
}

# Build and switch home-manager configuration
def "main home" [
  action: string = "switch" # build, switch
  system?: string           # linux, darwin, termux
] {
  setup-nix-config
  let info = if $system != null { $SYSTEMS | get $system } else { get-os-info }
  
  print $"🏠 ($action)ing Home configuration for ($info.home)..."
  nh home $action '.' -c $info.home -b bak -o result -a
  print "✅ Done!"
}

# Update flake inputs
def "main update" [input?: string] {
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
def "main gc" [--older-than (-d): string = "7d"] {
  print $"🧹 Running garbage collection (older than ($older_than))..."
  nix-collect-garbage --delete-older-than $older_than
  print "✅ Garbage collection complete!"
}

# Check flake for errors
def "main check" [] {
  print "🔍 Checking flake..."
  let os = get-os-info
  if $os.label == "macOS" {
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

# Sync secrets from Bitwarden to encrypted sops file
def "main secrets sync" [] {
  let deps = ["bw", "sops", "ssh-to-age"]
  let missing = ($deps | where { (which $in | is-empty) })
  if ($missing | is-not-empty) { error make { msg: $"❌ Missing dependencies: ($missing | str join ', ')" } }

  if not ((do { bw status } | from json | get status) == "unlocked") {
    error make { msg: "❌ Bitwarden is locked. Run 'bw unlock' first." }
  }

  print "🔐 Syncing secrets from Bitwarden..."
  mkdir secrets
  let age_dir = ($env.HOME | path join ".config" "sops" "age")
  let age_keys = ($age_dir | path join "keys.txt")
  mkdir $age_dir

  # Fetch SSH key for decryption
  print "  - Fetching Default SSH Key Pair..."
  let ssh_item = (bw get item 3859a223-3757-4676-bdca-b40a00cb7488 | from json)
  let private_key = ($ssh_item | get -o sshKey.privateKey)
  
  if ($private_key | is-not-empty) {
    try {
      $private_key | ssh-to-age -private-key | save -f $age_keys
      chmod 600 $age_keys
      print "  ✅ Age key derived and saved."
    } catch { |err|
        print $"⚠️  Error deriving age key: ($err.msg)"
    }
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

  try {
    let tmp = (mktemp --suffix .yaml)
    { "context7-api-key": $ctx7_key } | to yaml | save -f $tmp
    sops --encrypt --config .sops.yaml --output secrets/secrets.yaml $tmp
    rm $tmp
    print "✅ Secrets synced and encrypted!"
  } catch { |err|
      print $"⚠️  Error syncing secrets: ($err.msg)"
  }
}

# Show current system info and available commands
def "main info" [] {
  let info = get-os-info
  let host = sys host | get hostname

  print $"📊 OS: ($info.label) | Host: ($host) | User: ($env.USER)"

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

# Helper script written in Nushell to build and switch system configurations
def main [] {
  main info
}
