{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # Git Configuration
  # ============================================================================
  programs.git = {
    enable = true;

    # Core settings
    settings = {
      # User identity
      user = {
        name = "ray";
        email = "kjwdev01@gmail.com";
      };

      core = {
        compression = 9;
        autocrlf = "input";
        whitespace = "error";
        preloadindex = true;
      };

      diff = {
        renames = "copies";
        interHunkContext = 10;
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

      # Include work config for work directories
      includeIf."gitdir:~/work/" = {
        path = "~/.config/git/config-work";
      };

      # Git aliases
      alias = {
      # Submodule management
      sm = "submodule";
      spl = "submodule foreach git pull";
      sinit = "submodule init";
      sdeinit = "submodule deinit";
      supdate = "submodule update --remote --rebase";
      sadd = "submodule add";

      # Common operations
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

      # Conventional Commits helpers
      build = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "build''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      chore = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "chore''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      ci = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "ci''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      docs = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "docs''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      feat = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "feat''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      fix = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "fix''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      perf = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "perf''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      refactor = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "refactor''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      rev = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "revert''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      style = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "style''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      test = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "test''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      wip = ''!a() { local _scope _attention _message; while [ $# -ne 0 ]; do case $1 in -s | --scope ) if [ -z $2 ]; then echo "Missing scope!"; return 1; fi; _scope="$2"; shift 2;; -a | --attention ) _attention="!"; shift 1;; * ) _message="''${_message} $1"; shift 1;; esac; done; git commit -m "wip''${_scope:+(''${_scope})}''${_attention}:''${_message}"; }; a'';
      };
    };
  };

  # ============================================================================
  # Delta Diff Viewer
  # ============================================================================
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      dark = true;
    };
  };

  # ============================================================================
  # Jujutsu (jj) Configuration
  # ============================================================================
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "ray";
        email = "kjwdev01@gmail.com";
      };

      ui = {
        diff-formatter = ":git";
        pager = "delta";
        editor = "nvim";
        diff-editor = ["nvim" "-c" "DiffviewOpen"];
        log-format = "builtin";
        default-command = "log";
      };

      diff = {
        tool.difftastic.command = ["difft" "--color=always"];
      };

      git = {
        # Keep Git in the loop
        push-branch-prefix = "jj/";
        auto-local-branch = true;
      };

      revsets = {
        # What jj shows by default (recent, relevant stuff)
        log = "ancestors(@, 50) | descendants(@, 10)";
      };

      templates = {
        # Cleaner commit summaries
        commit_summary = ''"description"'';

        # Diff at bottom of message when running 'jj describe'
        draft_commit_description = ''
          concat(
            description,
            surround(
              "\nJJ: Changes:\n",
              "",
              indent("JJ: ", diff.stat(72)),
            ),
            surround("\nJJ: Diff:\n", "", indent("JJ: ", diff.git(4)))
          )
        '';
      };

      aliases = {
        # Status & inspection
        lg = ["log" "-r" "ancestors(@, 20)"];
        df = ["diff"];
        dfp = ["diff" "-r" "@-"];  # diff parent commit
        dft = ["diff" "--tool" "difft"];

        # Navigation
        co = ["checkout"];
        sw = ["checkout"];

        # Commit ergonomics
        cm = ["commit"];
        am = ["amend"];
        sp = ["split"];
      };
    };
  };

  # ============================================================================
  # Lazygit Configuration
  # ============================================================================
  programs.lazygit = {
    enable = true;
    # Lazygit config can be extended here if needed
    # For now, keep complex config in ~/.config/lazygit/config.yml
  };

  # ============================================================================
  # GitHub CLI
  # ============================================================================
  programs.gh = {
    enable = true;
    # Extensions and settings can be added here
  };
}
