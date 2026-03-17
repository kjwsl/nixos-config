#!/usr/bin/env nu

# System Metadata and Detection Logic
# label: User-facing name
# nh: nh command (os/darwin) - null if not supported
# hm: default home-manager configuration name
const SYSTEMS = {
  nixos:  { label: "NixOS",          nh: "os",     hm: "linux" },
  wsl:    { label: "NixOS WSL",      nh: "os",     hm: "wsl"   },
  darwin: { label: "macOS",          nh: "darwin", hm: "darwin" },
  android:{ label: "Android",        nh: null,     hm: "termux" },
  linux:  { label: "Generic Linux",  nh: null,     hm: "linux"  }
}

# Simplified OS detection (cached)
def get-os-info [] {
  if ($env.ANDROID_ROOT? | is-not-empty) { return $SYSTEMS.android }
  
  let host = sys host
  let os_name = ($host | get name | str downcase)
  let kernel = ($host | get -o kernel_version | default "" | str downcase)
  
  if ($os_name | str contains "nixos") or ($host | get -o long_os_version | default "" | str downcase | str contains "nixos") {
    if ($kernel | str contains "wsl") { return $SYSTEMS.wsl }
    return $SYSTEMS.nixos
  }
  
  if ($os_name | str contains "darwin") { return $SYSTEMS.darwin }
  
  $SYSTEMS.linux
}

# Robust nix.conf Parser
def "from conf" [] : string -> record {
  $in 
  | lines 
  | where { |l| not ($l | str starts-with "#") and ($l | str contains "=") }
  | parse "{key}={value}"
  | update key { str trim }
  | update value { str trim }
  | group-by key
  | items { |k, v| { key: $k, value: ($v.value | str join " ") } }
  | transpose -rd
}

def "to conf" [] : record -> string {
  $in 
  | items { |k, v| 
      let val = if ($v | describe | str starts-with "list") { $v | str join " " } else { $v }
      $"($k) = ($val)" 
    } 
  | str join "\n"
}

# Ensure nix-command and flake experimental features are enabled
def setup-nix-config []: nothing -> nothing {
  print "🛠️  Checking nix config..."
  let nix_conf_dir = ($env.HOME | path join ".config" "nix")
  let nix_conf_path = ($nix_conf_dir | path join "nix.conf")
  
  mkdir $nix_conf_dir
  
  mut conf = if ($nix_conf_path | path exists) {
    try { open $nix_conf_path | from conf } catch { {} }
  } else { {} }

  let current_features = ($conf | get -o "experimental-features" | default "" | split row " " | str trim | where { $in != "" })
  let required = ["nix-command", "flakes"]
  let missing = ($required | where { $in not-in $current_features })

  if ($missing | is-not-empty) {
    print $"🛠️  Enabling missing features: ($missing | str join ', ')..."
    let new_features = ($current_features | append $missing | uniq)
    $conf | upsert "experimental-features" ($new_features | str join " ") | to conf | save -f $nix_conf_path
  } else {
    print "✅ nix.conf already configured."
  }
}

# Common pre-setup tasks
def run-pre-setup []: nothing -> record {
  try { setup-nix-config } catch { |e| print $"⚠️ Warning: Failed to configure nix: ($e.msg)" }
  get-os-info
}

# Build and switch system configuration
def "main system" [
  action: string = "switch"  # switch, build, test, boot
  --os: string               # override detected OS
  --hostname (-H): string    # override hostname
  --update (-u) = false      # update flake inputs
  --ask (-a) = false         # ask for confirmation (nh)
] {
  let info = run-pre-setup
  let host = ($hostname | default (hostname | str trim))
  
  # Handle special cases first
  if ($info.label == "Android") {
    print $"🤖 Switching nix-on-droid for host ($host)..."
    nix-on-droid switch --flake $".#($host)"
    return
  }

  if $info.nh == null {
    error make { msg: $"❌ nh rebuilds not supported on ($info.label). Use 'home' instead." }
  }

  let nh_args = [
    $info.nh, $action, ".", 
    "-H", $host,
    ...(if $ask { ["--ask"] } else { [] }),
    ...(if $update { ["--update"] } else { [] })
  ]

  print $"🔨 Building ($info.label) ($action) for host ($host)..."
  nh ...$nh_args
}

# Build and switch home-manager configuration (standalone)
def "main home" [
  action: string = "switch" # build, switch
  system?: string           # linux, darwin, wsl, termux
] {
  let info = run-pre-setup
  let hm_target = ($system | default $info.hm)

  print $"🏠 ($action)ing home configuration for ($hm_target)..."
  nix run home-manager -- $action --flake $".#($hm_target)"
}

# --- Standard Commands ---

def "main update" [ input?: string ] {
  if $input != null {
    print $"📦 Updating flake input: ($input)..."
    nix flake update $input
  } else {
    print "📦 Updating all flake inputs..."
    nix flake update
  }
}

def "main gc" [ --older-than (-d): string = "7d" ] {
  print $"🧹 Running garbage collection (older than ($older_than))..."
  nix-collect-garbage --delete-older-than $older_than
}

def "main check" [] {
  print "🔍 Checking flake..."
  nix flake check --no-build
}

def "main fmt" [] {
  print "🎨 Formatting nix files..."
  nix fmt .
}

def "main info" [] {
  let info = get-os-info
  print $"📊 System: ($info.label)"
  print $"👤 User:   ($env.USER)"
  print $"🏠 Host:   (hostname | str trim)"
  print $"🎯 Default HM: ($info.hm)"
}

def "main hooks" [ --status (-s) ] {
  if $status {
    let global = ($env.HOME | path join ".config" "git" "templates" "hooks" "pre-push" | path exists)
    let local_hook = (".git" | path join "hooks" "pre-push" | path exists)
    
    [
      { Component: "Global pre-push", Status: (if $global { "✅" } else { "❌" }) }
      { Component: "Local .git hook", Status: (if $local_hook { "✅" } else { "❌" }) }
    ]
  } else {
    git init out+err>| ignore
    if (".githooks" | path exists) {
      ls .githooks | each { |f| chmod +x $f.name }
    }
    print "✅ Hooks ready!"
  }
}

# Main entry
def main [] {
  main info
}
