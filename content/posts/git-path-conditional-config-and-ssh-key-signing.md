---
title: Path-conditional config and SSH key signing in `git`
date: 2024-12-21
extra:
  kind: note
---

Today I learned about two recent-ish Git features.

## Conditional configs

Since Git version 2.13, it is possible to use different Git configurations based on values such as the current branch, or what's useful in my use case, path prefix:

```bash
# File: .gitconfig

[includeIf "gitdir:~/Projects/Work/"]
    path = .gitconfig-work
```

[🔗 `includeIf` in Git documentation](https://git-scm.com/docs/git-config#_includes)

I personally use separate Git identities and SSH keys for personal and work projects. With `includeIf`, using the right ones is a breeze. Just make sure to `includeIf` after your default configuration, in order for precedence to function as expected.

```bash
# File: .gitconfig-work

[core]
    sshCommand = ssh -i $HOME/.ssh/<work key name> -o IdentitiesOnly=yes
[user]
    email = <work email>
    signingkey = $HOME/.ssh/<work key name>
[gpg]
    format = ssh
[commit]
    gpgsign = true
```

I'm happy that this is supported natively, so I don't have to use any wrapper scripts, such as those described in [a previous note](../archive/directory-aware-git).

## SSH key signing

The above config snippet also includes another recent addition:

```bash
[user]
    signingkey = $HOME/.ssh/<key name>
[gpg]
    format = ssh
```

[🔗 `gpg.format = ssh` in Git documentation](https://git-scm.com/docs/gitformat-signature#Documentation/gitformat-signature.txt-codesshcodeSSH)

You can use the same SSH keys that you use to authenticate your pushes to sign your commits. This is a nice for multiple reasons:

- Most developers already have an SSH key
- PGP keys are not as popular as SSH keys, and suffer from usability issues
- Managing one key is less work than managing multiple keys

After configuring your key as a signing key, you need to enable commit signing either with `git commit -S` or the inaccurately named configuration value:

```bash
[commit]
    gpgsign = true
```

Your Git server must support SSH key signing for your commits to show up as _Verified_. At least GitHub and modern versions of GitLab support this. Just make sure your corresponding public key is listed as a _Signing key_ (GitHub) or an _Authentication & signing key_ (GitLab).
