# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Case-insensitive globbing (used in pathname expansion)
if command -v shopt >/dev/null 2>&1; then
	shopt -s nocaseglob;
fi

# Append to the Bash history file, rather than overwriting it
if command -v shopt >/dev/null 2>&1; then
	shopt -s histappend;
fi

# Autocorrect typos in path names when using `cd`
if command -v shopt >/dev/null 2>&1; then
	shopt -s cdspell;
fi

# Don't attempt tab completion when prompt is empty.
if command -v shopt >/dev/null 2>&1; then
	shopt -s no_empty_cmd_completion;
fi

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
if command -v shopt >/dev/null 2>&1; then
	for option in autocd globstar; do
		shopt -s "$option" 2> /dev/null;
	done;
fi

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d";
	source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Add old bash completions for compatibility
export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"

# Tab completion for newer bash versions.
[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
if [ -e "$HOME/.ssh/config" ]; then
	_hosts="$(grep "^Host " ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')"
	if [ -n "$BASH_VERSION" ]; then
		complete -o default -o nospace -W "$_hosts" scp sftp ssh
	elif [ -n "$ZSH_VERSION" ]; then
		autoload -Uz compinit
		compinit
	fi
fi

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
if command -v complete >/dev/null 2>&1; then
	complete -W "NSGlobalDomain" defaults;
fi

# Add `killall` tab completion for common apps
if command -v complete >/dev/null 2>&1; then
	complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;
fi

# Initialize virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON="`which python3`";
source $(brew --prefix)/bin/virtualenvwrapper.sh;

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh --no-use" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '~/Documents/google-cloud-sdk/path.bash.inc' ]; then . '~/Documents/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '~/Documents/google-cloud-sdk/completion.bash.inc' ]; then . '~/Documents/google-cloud-sdk/completion.bash.inc'; fi

export PATH="${HOME}/.local/bin:$PATH"

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# Alias for running starkup installer
alias starkup="curl --proto '=https' --tlsv1.2 -sSf https://sh.starkup.sh | sh -s --"

# BEGIN SCARB COMPLETIONS
_scarb() {
  if ! scarb completions bash >/dev/null 2>&1; then
    return 0
  fi
  source <(scarb completions bash)
  _scarb "$@"
}

complete -o default -F _scarb scarb
# END SCARB COMPLETIONS

# BEGIN FOUNDRY COMPLETIONS
_snforge() {
  if ! snforge completions bash >/dev/null 2>&1; then
    return 0
  fi
  source <(snforge completions bash)
  _snforge "$@"
}

_sncast() {
  if ! sncast completions bash >/dev/null 2>&1; then
    return 0
  fi
  source <(sncast completions bash)
  _sncast "$@"
}

complete -o default -F _snforge snforge
complete -o default -F _sncast sncast
# END FOUNDRY COMPLETIONS

export PATH="$PATH:/Users/markus/.bifrost/bin"

# Activate mise, which manages tool versions for the GitLab Development Kit (GDK).
# Keep this last, so the versions it selects come before everything else in `$PATH`.
if command -v mise &> /dev/null; then
	eval "$(mise activate bash)";
fi;
