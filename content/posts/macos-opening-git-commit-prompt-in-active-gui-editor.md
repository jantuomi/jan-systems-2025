---
title: "MacOS: Opening Git commit prompt in active GUI editor"
date: 2025-01-29
extra:
  kind: note
---

This is a quick, neat thing I happened to find on accident. As a result of the application bundle system that MacOS uses ubiquitously, you can figure out the currently open application with the `__CFBundleIdentifier` environment variable.

```bash
$ echo $__CFBundleIdentifier
dev.zed.Zed
```

This bundle identifier uniquely identifies an installed application.

Many editors or IDEs (Zed in my example) allow you to open an integrated terminal. It can be convenient to use that same graphical editor as the `$EDITOR` for commands like `git commit` or `git rebase -i` instead of using `vim` or `nano` or some other TUI editor inside the integrated terminal.

Use it like this:

```bash
# $HOME/.zshrc

if [ "$__CFBundleIdentifier" = "dev.zed.Zed" ]; then
  export EDITOR="zed -w"
elif [ "$__CFBundleIdentifier" = "com.jetbrains.intellij" ]; then
  export EDITOR="idea --wait"
fi
```

Alternatively, if your editor supports setting custom environment variables for the integrated terminal, you can do that and avoid having the if-else in your shell rc. I prefer to have all my environment shenanigans in one place so I chose not to follow that route.

Note that your editor must support a flag like `-w` or `--wait` that blocks the editor command from exiting before you close the file. If you don't do that, you will see stuff like:

```bash
$ git commit
Aborting commit due to empty commit message
```
