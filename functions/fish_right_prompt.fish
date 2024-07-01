function fish_right_prompt
  # NOTE: I had this elaborate function with background daemons and FIFOs and
  # everything here previously, but it's just too complex and error-prone.
  # Sadly, Fish will probably not implement subshells or asynchronous function
  # execution anytime soon. So I think my best bet for now is to just keep this
  # simple and efficient.

  set --local last_status $status

  prompt-right-status $last_status
  if $use_async_right_prompt
    eval-async-latched prompt-right-git "\
source '$__fish_config_dir/functions/prompt-right-git.fish'
prompt-right-git '$(pwd)'"
  else
    prompt-right-git
  end
  prompt-right-pyenv
  prompt-right-guix
  prompt-right-cwd
  prompt-right-time
end
