if status is-interactive
  # NOTE: The `hostname` variable is available since fish version 3.0.0
  switch "$hostname"
  case lasse-raspberrypi-1
    # (keep the prompt simple for better performance on these hosts)
  case "*"
    set --global FISH_PROMPT_FULL_FEATURED
  end
  switch "$hostname"
  case lasse-raspberrypi-0 lasse-raspberrypi-1 lasse-lubuntu-0
    # (don't use background processing in `fish_right_prompt` on these hosts)
  case "*"
    set --global FISH_RIGHT_PROMPT_USE_BACKGROUND
  end

  command -q mosh; and set --global --export MOSH_PREDICTION_DISPLAY always

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

