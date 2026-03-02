#!/usr/bin/env nu

# Build and switch system configuration (NixOS/Darwin with integrated home-manager)
def "main system" [
  action: string = "switch"  # switch, build, or test
] {
  let os = (sys host | get name | str downcase)
  
  if $os == "nixos" {
    print $"🔧 Running nh os ($action)..."
    nh os $action .
  } else if $os =~ "darwin" {
    print $"🍎 Running darwin-rebuild ($action)..." 
    darwin-rebuild $action --flake .
  } else {
    print "❌ System rebuilds only work on NixOS or macOS"
    exit 1
  }
  print "✅ System configuration applied!"
}

# Build and switch home-manager configuration (standalone for non-NixOS systems)
def "main home" [
  system: string = "linux"  # linux, darwin, termux
] {
  print $"🏠 Switching home-manager for ($system)..."
  nix run nixpkgs#nh -- home switch . -c $system -o result -b backup -a
  print "✅ Home configuration applied!"
}

# Legacy commands for backward compatibility
def "main switch" [system] {
  main home $system
}

def "main build" [system] {
  print $"🔨 Building home-manager for ($system)..."
  nix run nixpkgs#nh -- home build . -c $system -o result -b backup -a
  print "✅ Build complete!"
}

# Show current system info and available commands
def "main info" [] {
  let os = (sys host | get name)
  let user = $env.USER
  
  print $"📊 Current system: ($os)"
  print $"👤 Current user: ($user)"
  print ""
  print "Available commands:"
  print "  nu helper.nu system [switch|build|test]  # Full system (NixOS/macOS)"
  print "  nu helper.nu home [linux|darwin|termux]  # Home-manager only" 
  print "  nu helper.nu info                        # Show this info"
}

# Show help when no command provided
def main [] {
  main info
}
