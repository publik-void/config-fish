switch (hostname)
case lasse-mbp-0 lasse-mba-0
  export LANG=en_US
end

set --universal --export EDITOR nvim
set --universal --export PAGER less # Consider using neovim?
set --universal --export MOSH_PREDICTION_DISPLAY always

set --universal --export FISH_ASYNC_FIFO_PATH "$HOME/.config/fish/async-fifo"

if status is-interactive
  set --universal --export FISH_NEW_GREETING_DELTA (math 15 x 60)
  set --universal --export CPCP_ENCRYPTION_KEY_DELTA (math 16 x 60 x 60)

  set fish_escape_delay_ms 20

  fish_vi_key_bindings
  set fish_cursor_default block
  set fish_cursor_insert line
  set fish_cursor_replace_one underscore
  set fish_vi_force_cursor # Note: Seems to be necessary, at least for iTerm2…
end

# Make sure `$HOME/bin` is on the `PATH`.
# Note: We could check if it exists first, but I think it's nicer to just have
# it in there always?
set PATH $HOME/bin $PATH

# iTerm2 integration
test -e {$HOME}/.iterm2_shell_integration.fish ;\
  and source {$HOME}/.iterm2_shell_integration.fish

# Conda integration
# Note: Normally, Conda creates a block of code in this file when running
# `conda init fish`. This block is apparently managed by Conda then. I don't
# want it to mess with my git repository in non-portable ways, however, so I'll
# add the integration by myself. The caveat here is that the way conda does the
# integration may presumably be subject to change over different versions.
if type -q conda
  set --function conda_executable conda
else if test -f $HOME/anaconda3/bin/conda
  set --function conda_executable $HOME/anaconda3/bin/conda
else if test -f $HOME/miniconda3/bin/conda
  set --function conda_executable $HOME/miniconda3/bin/conda
end
if set --query conda_executable
  eval $conda_executable "shell.fish" "hook" $argv | source
end

# Juliaup intergation
# Note: At the time of writing this, Juliaup does not seem to support fish
# integration. Otherwise, it looks like it creates a block to manage similar to
# Conda, so the same issues may apply.
set PATH $HOME/.juliaup/bin $PATH

