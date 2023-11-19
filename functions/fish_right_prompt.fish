function fish_right_prompt --description 'Write out the right prompt'
  # NOTE: I had this elaborate function with background daemons and FIFOs and
  # everything here previously, but it's just too complex and error-prone.
  # Sadly, Fish will probably not implement subshells or asynchronous function
  # execution anytime soon. So I think my best bet for now is to just keep this
  # simple and efficient.

  set --local last_status $status
  set --local cwd (pwd)

  configured-status-prompt $last_status
  configured-git-prompt
  configured-guix-prompt
  configured-cwd-prompt $cwd
  configured-time-prompt
end
