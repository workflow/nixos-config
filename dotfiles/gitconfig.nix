{ pkgs }:

let

  gitignore = pkgs.writeText "git-global-ignore" ''
    # Python
    *.pyc
    *.pyo
    .ropeproject/

    # Sphinx
    #docs/_build

    # Vim
    *.swp

    # emacs
    .projectile
    .dir-locals.el

    # tern
    .tern-port

    # haskell
    .ghcid-output
    .stack-work

    .my_local_data
  '';

in

''
  [user]
      name = Alexandros Peitsinis
      email = alexpeitsinis@gmail.com
  [credential]
      helper = store
  [core]
      excludesfile = ${gitignore}
      editor = vim
  [alias]
      ls = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative
      lr = log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative
      ll = log --graph --decorate --pretty=oneline --abbrev-commit
      ld = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat
      lla = log --graph --decorate --pretty=oneline --abbrev-commit --all
      c = commit --verbose
      a = add -A
      fl = log -u
      count = shortlog -s -n --all
      squash = rebase -i HEAD^^
      delremote = push origin --delete
      branch-point = !zsh -c 'diff -u <(git rev-list --first-parent "''${1:-master}") <(git rev-list --first-parent "''${2:-HEAD}") | sed -ne \"s/^ //p\" | head -1' -
      diff-branch = !git diff "$@" $(git branch-point)..HEAD
      show-nth = !zsh -c 'git show `git rev-list master..HEAD --reverse | sed "$1q;d"`'
''
