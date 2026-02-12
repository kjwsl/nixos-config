{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    
    settings = {
      user = {
        name = "ray";
        email = "kjwsl@fatherslab.com";
      };
      
      core = {
        compression = 9;
        autocrlf = "input";
        whitespace = "error";
        preloadindex = true;
        # pager is handled by programs.delta module
      };
      
      
      pull = {
        default = "current";
        rebase = true;
      };
      
      rebase = {
        autoStash = true;
        missingCommitsCheck = "warn";
      };
      
      color = {
        ui = "auto";
      };
      
      "oh-my-zsh" = {
        git-commit-alias = "61bacd95b285a9792a05d1c818d9cee15ebe53c6";
      };
      
      "includeIf \"gitdir:~/work/\"" = {
        path = "~/.config/git/config-work";
      };
      
      alias = {
        # Submodule aliases
        sm = "submodule";
        spl = "submodule foreach git pull";
        sinit = "submodule init";
        sdeinit = "submodule deinit";
        supdate = "submodule update --remote --rebase";
        sadd = "submodule add";
        
        # Basic git aliases
        cl = "clone";
        co = "checkout";
        br = "branch";
        st = "status";
        sw = "switch";
        ss = "stash";
        cm = "commit";
        cmm = "commit -m";
        pl = "pull";
        plr = "pull --rebase";
        ps = "push";
        m = "merge";
        ms = "merge --squash";
        rb = "rebase";
        t = "tag";
        df = "diff";
        dfh = "diff HEAD";
        lg = "log --graph --decorate";
        rs = "reset";
        rss = "reset --soft";
        rsh = "reset --hard";
        
        # Simplified conventional commit aliases (complex functions moved to separate script)
        feat = "!f() { git commit -m \"feat: $*\"; }; f";
        fix = "!f() { git commit -m \"fix: $*\"; }; f";
        docs = "!f() { git commit -m \"docs: $*\"; }; f";
        style = "!f() { git commit -m \"style: $*\"; }; f";
        refactor = "!f() { git commit -m \"refactor: $*\"; }; f";
        test = "!f() { git commit -m \"test: $*\"; }; f";
        chore = "!f() { git commit -m \"chore: $*\"; }; f";
        perf = "!f() { git commit -m \"perf: $*\"; }; f";
        ci = "!f() { git commit -m \"ci: $*\"; }; f";
        build = "!f() { git commit -m \"build: $*\"; }; f";
        wip = "!f() { git commit -m \"wip: $*\"; }; f";
        revert = "!f() { git commit -m \"revert: $*\"; }; f";
      };
    } // lib.optionalAttrs (lib.hasAttr "gh" pkgs) {
      "credential \"https://github.com\"" = {
        helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
      "credential \"https://gist.github.com\"" = {
        helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
    } // lib.optionalAttrs (lib.hasAttr "git-lfs" pkgs) {
      "filter \"lfs\"" = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      dark = true;
      line-numbers = true;
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      customCommands = [
        {
          key = "O";
          command = "git checkout --ours {{ .SelectedFile.Name }}";
          context = "global";
          loadingText = "take ours";
        }
        {
          key = "T";
          command = "git checkout --theirs {{ .SelectedFile.Name }}";
          context = "global";
          loadingText = "take theirs";
        }
        {
          key = "C";
          command = "git cherry-pick {{ .SelectedLocalBranch.Name }}";
          context = "localBranches";
          prompts = [
            {
              type = "confirm";
              title = "Cherry-pick {{ .SelectedLocalBranch.Name }}?";
              body = "Are you sure you want to cherry-pick {{ .SelectedLocalBranch.Name }}?";
            }
          ];
        }
      ];
      
      gui = {
        theme = {
          activeBorderColor = [ "#f38ba8" "bold" ];
          inactiveBorderColor = [ "#a6adc8" ];
          optionsTextColor = [ "#89b4fa" ];
          selectedLineBgColor = [ "#313244" ];
          cherryPickedCommitBgColor = [ "#45475a" ];
          cherryPickedCommitFgColor = [ "#f38ba8" ];
          unstagedChangesColor = [ "#f38ba8" ];
          defaultFgColor = [ "#cdd6f4" ];
          searchingActiveBorderColor = [ "#f9e2af" ];
        };
        authorColors = {
          "*" = "#b4befe";
        };
      };
    };
  };
}