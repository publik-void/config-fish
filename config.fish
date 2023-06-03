# fish shell startup config
# vim: foldmethod=marker

# {{{1 locale settings

# So, turns out these locale issues specifically happen when logging in to
# Linux from macOS and the below approach is maybe not the ideal solution (or
# one at all). The Terminal automatically sets environment variables after
# logging in via SSH and that seems to be the issue. There's something about SSH
# forwarding locale settings as well, but I think that's not the issue I'm
# experiencing. See:
# https://askubuntu.com/questions/599808/cannot-set-lc-ctype-to-default-locale-
#   no-such-file-or-directory
# The solution would be to disable a checkbox in the terminal application.
# E.g. for iTerm2, Preferences -> Profiles -> Terminal -> Environment -> "Set
# locale variables automatically"
#switch (hostname)
#case lasse-mbp-0 lasse-mba-0
#  export LANG=en_US
#end

# {{{1 environment

# Note: there are plans to phase out universal variables and the recommendation
# is to only do `set --global` here

fish_add_path --path $HOME/bin
fish_add_path --path $HOME/.juliaup/bin

type -q nvim; and set --global --export EDITOR nvim
type -q less; and set --global --export PAGER less # Consider using neovim?

# {{{1 interactive environment

if status is-interactive
  set --global --export FISH_NEW_GREETING_DELTA (math 15 x 60)
  set --global --export CPCP_ENCRYPTION_KEY_DELTA (math 16 x 60 x 60)
  type -q mosh; and set --global --export MOSH_PREDICTION_DISPLAY always

  set fish_escape_delay_ms 20

  fish_vi_key_bindings
  set fish_cursor_default block
  set fish_cursor_insert line
  set fish_cursor_replace_one underscore
  set fish_vi_force_cursor # Note: Seems to be necessary, at least for iTerm2…

  # TODO: Check the source code of `fish_update_completions` to check if it
  # always writes to `$HOME/.local/share/fish/generated_completions/`. Then, add
  # code here that checks the modification time of that folder if it exists or
  # the files in it or something, and re-run a background
  # `fish_update_completions` if the completion files haven't been updated in a
  # while. And probably output a notice that this is happening, and perhaps
  # disown the process. Maybe ensure that the modification time is up to date by
  # doing a `touch`.
  # Note: Checking modification time should be easy with fish's `path mtime
  # --relative`
end

# {{{1 iTerm2 integration

if status is-interactive
  test -e {$HOME}/.iterm2_shell_integration.fish ;\
    and source {$HOME}/.iterm2_shell_integration.fish
end

# {{{1 Conda integration

# Note: Normally, Conda creates a block of code in this file when running
# `conda init fish`. This block is apparently managed by Conda then. I don't
# want it to mess with my git repository in non-portable ways, however, so I'll
# add the integration by myself. The caveat here is that the way conda does the
# integration may presumably be subject to change over different versions.

if status is-interactive # I hope it's not needed otherwise
  set --function conda_executable
  for candidate in \
    "conda" \
    "$HOME/anaconda3/bin/conda" \
    "$HOME/miniconda3/bin/conda"
    if type -q "$candidate"
      set --function conda_executable "$candidate"
    end
  end
  if set --function --query conda_executable[1]
    eval $conda_executable "shell.fish" "hook" $argv | source
  end
end

# {{{1 Juliaup intergation

# Note: At the time of writing this, Juliaup does not seem to support fish
# integration. Otherwise, it looks like it creates a block to manage similar to
# Conda, so the same issues may apply.
# (TODO)

