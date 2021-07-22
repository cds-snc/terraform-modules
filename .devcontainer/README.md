# Setup
1. [SSH keys](#SSH-keys)
1. [GPG commit signing](#GPG-commit-signing)

## SSH keys
To make your keys available in the devcontainer, you'll need:
1. the `ssh-agent` running on the host; and
2. your key(s) added to it.

To make this happen:
1. Auto-start the ssh-agent:
```sh
# Update ~/.bashrc or ~/.zshrc
[ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)"
```
2. Add your key:
```sh
# Update ~/.ssh/config
Host *
	UseKeychain yes
	AddKeysToAgent yes
	IdentityFile ~/.ssh/<PRIVATE_KEY>

# Or manually add the key
ssh-add -K ~/.ssh/<PRIVATE_KEY>
```

## GPG commit signing
You'll need a [graphical pinentry program on Mac/Windows](https://github.com/microsoft/vscode-remote-release/issues/3168#issuecomment-654637826) to capture your GPG key's password.  On your host:
```sh
brew install pinentry-mac
echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent 		# force a restart to reload the config
```
Test in the devcontainer:
```sh
gpg --list-secret-keys			# you should see your key(s)
echo "mello" | gpg --clear-sign	# you should be prompted for your key's password
```