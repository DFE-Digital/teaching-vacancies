# Default bashrc providing some Teaching Vacancies conveniences
# Intended to be sourced into /etc/bash.bashrc so it can be overridden by user dotfiles

## Add Rails `bin` and Bundler `bin` directories to PATH
##   Adds `$PWD/bin` to support checking out a repository into a Docker volume through VS Code
##   (which results in the workspace not living in the default `/workspace` directory)
PATH=$PWD/bin:/workspace/bin:/usr/local/bundle/bin:$PATH

## Enable Git bash completion
source /usr/share/bash-completion/completions/git
