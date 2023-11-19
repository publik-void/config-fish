if status is-interactive
  command -q mosh; and set --global --export MOSH_PREDICTION_DISPLAY always

  set fish_escape_delay_ms 20

  fish_vi_key_bindings
  set fish_cursor_default block
  set fish_cursor_insert line
  set fish_cursor_replace_one underscore
  set fish_vi_force_cursor # Note: Seems to be necessary, at least for iTerm2…

  set --global git_prompt_interpreter
  for candidate in zsh bash
    set git_prompt_interpreter (command -v $candidate)
    set --query git_prompt_interpreter[1] && break
  end
  set --export GIT_PS1_SHOWDIRTYSTATE true
  set --export GIT_PS1_SHOWSTASHSTATE true
  set --export GIT_PS1_SHOWUNTRACKEDFILES true
  set --export GIT_PS1_SHOWUPSTREAM verbose
  set --export GIT_PS1_COMPRESSSPARSESTATE true
  set --export GIT_PS1_SHOWCONFLICTSTATE true
  set --export GIT_PS1_SHOWCOLORHINTS true

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

