# Make sure we’re using the latest Homebrew
update

# Upgrade any already-installed formulae
upgrade

# This will go first, to ensure completions are installed for everything else
install bash-completion

# Install GNU core utilities (those that come with OS X are outdated)
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
install coreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
install findutils
# Install Bash 4
install bash

# Install wget with IRI support
install wget --enable-iri

# Install more recent versions of some OS X tools
install vim --override-system-vi
tap homebrew/dupes
install homebrew/dupes/grep
tap josegonzalez/homebrew-php
install php55

# Install other useful binaries
install ack
install git
install imagemagick --with-webp
install node
install the_silver_searcher

# Remove outdated versions from the cellar
cleanup
