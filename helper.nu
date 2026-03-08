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
  print "  nu helper.nu update [input]                 # Update flake inputs"
  print "  nu helper.nu gc [-d 7d]                     # Garbage collection"
  print "  nu helper.nu check                          # Check flake"
  print "  nu helper.nu fmt                            # Format nix files"
  print "  nu helper.nu info                           # Show this info"
}

# Helper script written in Nushell to build and switch system configurations
def main [] {
  main info
}
