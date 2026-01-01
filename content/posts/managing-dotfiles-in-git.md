---
title: Managing dotfiles in `git`
date: 2024-07-08
extra:
  kind: note
---

Dealing with dotfiles can be a nuisance. I use a method that I read about in [this Git tutorial](https://www.atlassian.com/git/tutorials/dotfiles) (which is in turn based on a Hacker News post).

It is the most elegant approach I've come across. It does not need to clutter your home directory, it does not cause your shell prompt to show Git status info whenever you're in a subdirectory of `$HOME`. It stays out of the way, but is still instantly accessible whenever you need it and allows you to use the full power of Git.

Check out the linked tutorial for the full rundown. Here's the core idea, with my personal improvements added on top.

1. Use `git init --bare` to initialize a bare `dotfiles` Git repository somewhere on your file system. I used `$HOME/.dotfiles/`. This repository will track all of your dotfiles while hiding away in a convenient location, which is not your home directory root.
2. Add a shell alias that uses this newly created bare dotfiles repository:

```bash
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

3. Configure the `dotfiles` repo to not show untracked files in status output:

```bash
dot config --local status.showUntrackedFiles no
```

4. Add some prints to your shell `rc` file in order to be reminded when you have forgotten to sync your stuff:

```bash
dotfiles_status="$(dot status)"
if ! echo "$dotfiles_status" | grep -q "nothing to commit"; then
  echo 'There are dotfiles changes to commit. Run "dotfiles status" to see them.'
fi

if echo "$dotfiles_status" | grep -q "Your branch is ahead"; then
  echo 'There are dotfiles commits to push. Run "dotfiles log" to see recent commits.'
fi
```
