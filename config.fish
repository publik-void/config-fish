switch (hostname)
case lasse-mbp-0
  export LANG=en_US
end

set -Ux EDITOR nvim

## This is suggested by the kitty docs as a way to keep fish completions up-to-
## date. But it adds a substantial amount of startup time to the fish shell.
#if type -q kitty
#  kitty + complete setup fish | source
#end

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

