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

# Build and switch system configuration (NixOS/Darwin with integrated home-manager)
def "main system" [
  action: string = "switch"  # switch, build, or test
  os?: string # nixos, darwin, or auto-detect
  --hostname (-H): string = "ray" # hostname
] {
  let os_str = if $os != null { $os } else { get_os_string }
  if $os_str == null {
    print "❌ Unable to detect OS"
    exit 1
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

  print $"🔨 Building system ($action) for ($os_str) for host ($hostname)..."

  nh $command $action . -H $hostname -a
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

# Show current system info and available commands
def "main info" [] {
  let os = get_os_string
  let user = $env.USER

  print $"📊 Current system: ($os)"
  print $"👤 Current user: ($user)"
  print ""
  print "Available commands:"
  print "  nu helper.nu system [switch|build|test]  # Full system (NixOS/macOS)"
  print "  nu helper.nu home [linux|darwin|termux]  # Home-manager only"
  print "  nu helper.nu info                        # Show this info"
}

# Helper script written in Nushell to build and switch system configurations
def main [] {
  main info
}
