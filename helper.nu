def "main switch" [system] {
    print "Switching to $system"
    nix run nixpkgs#nh -- home switch . -c $"ray-($system)" -o result -b backup -a
    print "Done! 🚀"
}

def "main build" [system] {
    print "Building for $system"
    nix run nixpkgs#nh -- home build . -c $"ray-($system)" -o result -b backup -a
    print "Done! 🚀"
}


# To enable subcommands
def main [] {}
