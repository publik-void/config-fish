function fish_right_prompt --description 'Write out the right prompt'
  # So apparently, `fish_right_prompt` does not necessarily receive any globally
  # set variables from `fish_pompt` or `fish_mode_prompt`. Instead, `$status` is
  # set to the correct value, but unfortunately only on some platforms or
  # versions, it seems. Oh my god, these prompt functions are starting to annoy
  # me a whole lot. Well, for now, let's just accept that `$status` may be
  # incorrect on some platforms. It should hopefully be `0` in virtually all of
  # these cases anyway, and the left prompt will still indicate a nonzero retuen
  # value.
  set --function last_status $status

  if not set --query __fish_prompt_normal
      set --global __fish_prompt_normal (set_color normal)
  end

  # So on 2023-05-12, I tried to get this right prompt to work in a way where
  # its individual parts would be computed in parallel asynchronously with a
  # timeout. I first tried it with a named pipe buffer, later switched to fish
  # universal variables. I encapsulated this in some extra fish functions
  # (push-buf and pop-buf) In the end, both have their issues. named pipes
  # mainly having some latency and thus making the prompt very un-snappy, and a
  # single central stack buffer built on a universal variable not being able to
  # deal with data races well (if two background jobs try to append something to
  # the same universal variable at the same time, it usually fails).
  # One thing to keep in mind here is that (at least as of the time of writing
  # this) fish has no functionality of running a `function` in the background.
  #
  # I think what probably makes more sense is to just have a separate universal
  # variable for every part of the right prompt that is supposed to run in a
  # separate background job.
  # Also, it only makes sense to run those jobs in the background that actually
  # have a possibility of taking their time. Anything fast and (mostly)
  # fail-safe like printing the working directory should probably be done
  # in the foreground, as that is faster than spawning an extra background job.
  # In fact, this is unfortunately why this prompt won't be really snappy ever –
  # because it always spawns background jobs which takes some time.
  # TODO: Can anything still be done about this?

  # Initialize buffers for the capture of background jobs' output
  set --universal fish_git_prompt_buffer
  # TODO: Integrate some of the other fields here (conda, juliaup, …)

  # Run background jobs with escaped output being captured in the buffers
  fish -c "set --universal fish_git_prompt_buffer \
    (configured-git-prompt | esc --prefix --join)" &

  # Meanwhile, run foreground jobs and capture in local buffers
  set --function cwd_prompt (configured-cwd-prompt | esc --prefix --join)
  set --function status_prompt \
    (configured-status-prompt --value=$last_status | esc --prefix --join)

  # And do other setup
  set --function timeout 1
  set --function interval .01

  set --function red_esc (set_color red)
  set --function normal_esc $__fish_prompt_normal

  # Wait for background jobs to finish or timeout
  while begin true
      # Check for captured output of background jobs
      and not set --query fish_git_prompt_buffer[1]

      # Check for timeout last
      and [ $timeout -gt 0 ]
    end
    set --function timeout (math "$timeout - $interval")
    sleep $interval
  end

  # If desired, create default values for background jobs that took too long
  set --query fish_git_prompt_buffer[1]
  or set --function fish_git_prompt_buffer \
    (esc --prefix --join "(git:$red_esc timeout$normal_esc)")

  # Output non-empty fields
  set --function separator
  for field_esc in "$status_prompt" "$fish_git_prompt_buffer" "$cwd_prompt"
    if begin
        set --function field (esc --unescape --prefix --join "$field_esc")
        and [ "$field" != "" ]
      end
      printf "$separator%s" "$field"
      set --function separator " "
    end
  end

  set_color normal
end
