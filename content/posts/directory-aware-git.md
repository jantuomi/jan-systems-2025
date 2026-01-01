---
title: Directory aware `git`
date: 2024-05-07
extra:
  kind: note
---

> Update 2024-12-22: The functionality described here is available natively in modern versions of Git, see more recent note [Path-conditional config and SSH key signing in `git`](../archive/git-path-conditional-config-and-ssh-key-signing).

> Update 2024-05-10: Fixed a bug in the provided script.

> Update 2024-05-14: Added user name and email config features.

I have separate SSH keys and email addresses for personal projects and work projects. My work-related Git projects reside in `~/Projects/Work`. Without a "directory aware" git config, I would have to define `GIT_SSH_COMMAND` when cloning to use the correct key, as well as set up each work repository to use the work key for interacting with the remote, as well as the `user.name` and `user.email` configuration values manually using `git config` commands. This is naturally very error prone and is an easy thing to forget.

To avoid these issues, here's a script that wraps `git`:

```bash
#!/bin/bash

# If GIT_SSH_COMMAND is set, skip automatic key selection
if [ -n $GIT_SSH_COMMAND ]; then
  echo # skip
elif [[ $PWD == *Projects/Work* ]]; then
  echo "dir-aware-git: using work profile"
  export GIT_SSH_COMMAND='ssh -i ~/.ssh/work_rsa'
  export GIT_AUTHOR_NAME='<my work name>'
  export GIT_AUTHOR_EMAIL='<my work email>'
fi

git "$@"
```

Update the `GIT_` environment values as well as the directory matcher in the `elif` conditional to suit your needs.

Save the script as `directory-aware-git`, make it executable with `chmod +x directory-aware-git` and put it in some directory that is in `$PATH`. For me, that would be `~/.local/bin/`. Then, add this alias to your shell config, updated with your selected path:

```bash
alias git=~/.local/bin/directory-aware-git
```

Enjoy 👍
