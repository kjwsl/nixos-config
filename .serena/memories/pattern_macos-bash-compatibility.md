# Pattern: macOS Bash Compatibility for Nix Plugins

## Problem Context
macOS ships with Bash 3.2.57 due to GPLv2 licensing restrictions (Apple won't ship GPLv3). Many modern shell scripts require Bash 4.0+ or 5.0+ features that aren't available in the system bash.

## Common Bash Version Requirements

### Bash 4.0+ Features
- `${var^^}` / `${var,,}` - Uppercase/lowercase parameter expansion
- `${var@U}` / `${var@L}` - Case modification
- Associative arrays improvements
- `&>>` redirection operator

### Bash 4.2+ Features
- `declare -g` - Declare global variables from functions
- Negative array subscripts
- `wait -n` - Wait for any job

### Bash 5.0+ Features
- `wait -p` - Store PID
- Improved parameter expansions

### Bash 5.1+ Features
- `shopt -s assoc_expand_once` - Associative array performance optimization

## Detection Pattern

**Symptoms**:
1. Plugin/script fails with syntax errors
2. Error messages about invalid options: `declare: -g: invalid option`
3. Error messages about bad substitution: `${VAR^^}: bad substitution`
4. Script uses `set -e` and exits with code 1 without clear error

**Verification**:
```bash
# Check system bash version
/bin/bash --version
# Output: GNU bash, version 3.2.57(1)-release

# Check Nix bash version
/nix/store/*/bash-*/bin/bash --version
# Output: GNU bash, version 5.3.9(1)-release
```

## Solution Pattern

### 1. Shebang Patching (Preferred)

For tmux plugins:
```nix
myPlugin = pkgs.tmuxPlugins.mkTmuxPlugin {
  pluginName = "my-plugin";
  version = "1.0.0";
  src = fetchFromGitHub { /* ... */ };
  rtpFilePath = "plugin.tmux";

  # Patch shebang to use Nix bash
  postInstall = ''
    substituteInPlace $target/plugin.tmux \
      --replace '#!/usr/bin/env bash' '#!${pkgs.bash}/bin/bash'
    
    # Patch all bash scripts recursively
    find $target -type f -name "*.sh" -exec \
      substituteInPlace {} \
        --replace '#!/usr/bin/env bash' '#!${pkgs.bash}/bin/bash' \;
  '';

  nativeBuildInputs = [ pkgs.bash ];
};
```

For standalone scripts:
```nix
home.file.".local/bin/myscript" = {
  source = ./scripts/myscript.sh;
  executable = true;
  
  # Patch on copy
  onChange = ''
    ${pkgs.gnused}/bin/sed -i \
      's|#!/usr/bin/env bash|#!${pkgs.bash}/bin/bash|' \
      ~/.local/bin/myscript
  '';
};
```

### 2. Wrapper Script Approach

When you can't modify the original script:
```nix
let
  wrappedScript = pkgs.writeShellScriptBin "my-script" ''
    #!${pkgs.bash}/bin/bash
    exec ${originalScript} "$@"
  '';
in {
  home.packages = [ wrappedScript ];
}
```

### 3. PATH Manipulation

Ensure Nix bash takes precedence:
```nix
home.sessionPath = [
  "${pkgs.bash}/bin"  # Add before system paths
];
```

## Testing Pattern

### Quick Test
```bash
# Test bash 5 features work
/nix/store/*/bash-5.*/bin/bash -c 'declare -g TEST=1 && VAR=test && echo "${VAR^^}"'
# Should output: TEST

# Test with system bash (should fail)
/bin/bash -c 'declare -g TEST=1 && VAR=test && echo "${VAR^^}"'
# Should error: declare: -g: invalid option
```

### Full Plugin Test
```bash
# Run plugin script with Nix bash
/nix/store/*/bash-5.*/bin/bash /path/to/plugin/script.sh

# Check exit code
echo $?  # Should be 0 for success
```

## Common Pitfalls

### ❌ Wrong: Assume bash is available
```nix
# This uses system bash 3.2 on macOS!
home.file.".local/bin/script" = {
  text = ''
    #!/usr/bin/env bash
    declare -g VAR=1  # Fails on macOS!
  '';
};
```

### ✅ Correct: Use Nix bash explicitly
```nix
home.file.".local/bin/script" = {
  text = ''
    #!${pkgs.bash}/bin/bash
    declare -g VAR=1  # Works with Nix bash 5.x
  '';
};
```

### ❌ Wrong: Only patch main script
```nix
postInstall = ''
  substituteInPlace $target/main.sh \
    --replace '#!/usr/bin/env bash' '#!${pkgs.bash}/bin/bash'
  # Sourced scripts still use system bash!
'';
```

### ✅ Correct: Patch all bash scripts
```nix
postInstall = ''
  find $target -type f -name "*.sh" -exec \
    substituteInPlace {} \
      --replace '#!/usr/bin/env bash' '#!${pkgs.bash}/bin/bash' \;
'';
```

## Checklist

When integrating bash-dependent software on macOS:

- [ ] Check if script uses bash 4.0+ features (case modification, etc.)
- [ ] Check if script uses bash 4.2+ features (declare -g, etc.)
- [ ] Check if script uses bash 5.0+ features (advanced features)
- [ ] Identify all bash scripts (not just main entry point)
- [ ] Add bash to nativeBuildInputs or home.packages
- [ ] Patch shebang in all bash scripts
- [ ] Test with Nix bash before deploying
- [ ] Verify script doesn't shell out to /bin/bash anywhere

## Real-World Example: tmux-powerkit

**Problem**: Plugin returned exit code 1 without clear error

**Investigation**:
```bash
# Found the plugin used:
- declare -g (bash 4.2+)
- ${var^^} (bash 4.0+)  
- shopt -s assoc_expand_once (bash 5.1+)

# System bash:
/bin/bash --version  # 3.2.57 ❌
```

**Solution**:
```nix
tmux-powerkit = pkgs.tmuxPlugins.mkTmuxPlugin {
  # ... config ...
  postInstall = ''
    substituteInPlace $target/tmux-powerkit.tmux \
      --replace '#!/usr/bin/env bash' '#!${pkgs.bash}/bin/bash'
  '';
  nativeBuildInputs = [ pkgs.bash ];
};
```

**Result**: Plugin now uses bash 5.3, all features work ✅

## Related Patterns
- See: `pattern_custom-tmux-plugins.md` - Custom plugin integration
- See: `session_2026-02-14_tmux-powerkit-fix.md` - Detailed fix walkthrough
