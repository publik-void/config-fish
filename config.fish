switch (hostname)
case lasse-mbp-0 lasse-mba-0
  export LANG=en_US
end

set -Ux EDITOR nvim
set -Ux PAGER less # Although I might want to consider using neovim?
set -Ux MOSH_PREDICTION_DISPLAY always

set fish_escape_delay_ms 20

test -e {$HOME}/.iterm2_shell_integration.fish ;\
and source {$HOME}/.iterm2_shell_integration.fish

