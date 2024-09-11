if status is-interactive
  set --global --export MOSH_PREDICTION_DISPLAY always

  # For Python `venv`/`poetry`
  set --global --export VIRTUAL_ENV_DISABLE_PROMPT 1

  set --global --export NNN_OPTS HiRU
  # TODO: This will move trashed files into `$HOME/.local/share/Trash` usually,
  # also on macOS, instead of into the macOS trash. Fix this. Unfortunately, it
  # is the same with `trash-cli` and `nnn` does not seem to support the other
  # macOS-specific CLI trashers.
  # I haven't looked for issues in the `nnn` GitHub repo yet.
  set --global --export NNN_TRASH 2

  set fish_escape_delay_ms 20

  fish_vi_key_bindings
  set fish_cursor_default block
  set fish_cursor_insert line
  set fish_cursor_replace_one underscore
  set fish_vi_force_cursor # Note: Seems to be necessary, at least for iTerm2…

  set --global --export __fish_git_prompt_show_informative_status 1
  set --global --export __fish_git_prompt_hide_untrackedfiles 1
  set --global --export __fish_git_prompt_color_branch magenta #--bold
  set --global --export __fish_git_prompt_showupstream "informative"
  set --global --export __fish_git_prompt_char_upstream_ahead "↑"
  set --global --export __fish_git_prompt_char_upstream_behind "↓"
  set --global --export __fish_git_prompt_char_upstream_prefix ""
  set --global --export __fish_git_prompt_char_stagedstate "●"
  set --global --export __fish_git_prompt_char_dirtystate "✚"
  set --global --export __fish_git_prompt_char_untrackedfiles "…"
  set --global --export __fish_git_prompt_char_conflictedstate "✖"
  set --global --export __fish_git_prompt_char_cleanstate "✔"
  set --global --export __fish_git_prompt_color_dirtystate blue
  set --global --export __fish_git_prompt_color_stagedstate yellow
  set --global --export __fish_git_prompt_color_untrackedfiles $fish_color_normal
  set --global --export __fish_git_prompt_color_cleanstate green #--bold

  set --global async_id "fish-async-$USER-$fish_pid-$(random)"
  set --global async_dir
  for candidate in /dev/shm /run/shm "$TMPDIR" /tmp
    test -d "$candidate" && set async_dir "$candidate" && break
  end

  set --global use_async_right_prompt true
  switch "$hostname"
    case "test-host"
      set use_async_right_prompt false
  end

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

