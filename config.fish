switch (hostname)
case lasse-mbp-0 lasse-mba-0
  export LANG=en_US
end

set --universal --export EDITOR nvim
set --universal --export PAGER less # Consider using neovim?
set --universal --export MOSH_PREDICTION_DISPLAY always

if status is-interactive
  set --universal --export FISH_NEW_GREETING_DELTA (math 15 x 60)

  set fish_escape_delay_ms 20

  fish_vi_key_bindings
  set fish_cursor_default block
  set fish_cursor_insert line
  set fish_cursor_replace_one underscore
  set fish_vi_force_cursor # Note: Seems to be necessary, at least for iTerm2…
end

test -e {$HOME}/.iterm2_shell_integration.fish ;\
and source {$HOME}/.iterm2_shell_integration.fish

