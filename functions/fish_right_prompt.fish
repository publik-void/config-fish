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
  # (push-buf and pop-buf). In the end, both have their issues. Named pipes
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
  #
  # Can anything be done about this?
  # Maybe, because it's not the spawning of background jobs itself that takes
  # time, and neither named pipe communication by the way, but the starting of
  # new fish processes, it seems. So anything running a fish script or using
  # `fish -c '…'` will result in some perceptible latency. Using `fish --private
  # --no-config -c '…'` helps a little bit, but not much, and disallows the usage
  # of universal variables for inter-process communication. An issue with fish
  # that has not received much work for a long time is that it doesn't support
  # background subshells or background functions.
  #
  # I guess one approach would be
  # to launch a bunch of background fish shells when starting fish and then send
  # commands to those for concurrency, ameliorating the need to wait for the
  # start of a new fish process at the time it is needed, but man would that
  # feel hacky. It'd probably also result in a bunch of new issues.
  #
  # Another way would be to use compiled binaries that handle the prompt string
  # creation as well as the inter-process communication and rely on those, at
  # least if they're available. Seems like quite the project, too, however.
  #
  # Using `timeout` instead of concurrent jobs will require a command (and not
  # a fish function) to be run as well, so that's of no help.
  #
  # Sooo… I coded `fish-background-daemon` and it seems to improve things a bit.
  # It seems it would be even faster if we wouldn't use universal variables, but
  # named pipes here in this function.
  # To add to this, universal variables may get deprecated in the future…
  # (TODO)

  set --function cwd (pwd)
  set --function ttl 3
  set --function id $fish_pid

  # TODO: Integrate some of the other fields here (conda, juliaup, …)
  set --function background_fieldnames \
    "fish_git_prompt_buffer"
  set --function background_commands \
    "configured-git-prompt"

  set --function background_fieldnames_with_id
  for name in $background_fieldnames
    set --append background_fieldnames_with_id "$name"_"$id"
  end

  # Make sure files to capture background job's output don't exist
  user-tmp-file rm $background_fieldnames_with_id

  # Run background jobs with escaped output being captured in the files
  # TODO: extra escaping may not be necessary since user-tmp-file does it too
  for i in (seq0 (count background_fieldnames))
    fish-background-daemon eval "cd $cwd; \
      user-tmp-file write \"$background_fieldnames_with_id[$i]\" \
      ($background_commands[$i])"
  end

  # Meanwhile, run foreground jobs and capture in local buffers
  set --function cwd_prompt (configured-cwd-prompt)
  set --function status_prompt \
    (configured-status-prompt --value=$last_status)

  # And do other setup
  set --function timeout 1
  set --function interval .01

  set --function red_esc (set_color red)
  set --function normal_esc $__fish_prompt_normal

  # Set empty variables for fields
  for name in $background_fieldnames
    set --function "$name"
  end

  # Wait for background jobs to finish or timeout
  while true
    set --local any_unfinished false
    for name in $background_fieldnames
      if begin
          not set --query "$name"[1]
          and not user-tmp-file query "$name"_"$id"
        end
        set any_unfinished true
      else
        set "$name" (user-tmp-file read "$name"_"$id")
        user-tmp-file rm "$name"_"$id"
      end
    end

    begin; not $any_unfinished; or [ "$timeout" -le 0 ]; end; and break

    set --function timeout (math "$timeout - $interval")
    sleep "$interval"
  end

  # If desired, create default values for background jobs that took too long
  set --query "fish_git_prompt_buffer"[1]
  or set --function "fish_git_prompt_buffer" \
    "(git:$red_esc timeout$normal_esc)"

  # Output non-empty fields
  set --function separator
  for field in "$status_prompt" "$fish_git_prompt_buffer" "$cwd_prompt"
    if begin
        and [ "$field" != "" ]
      end
      printf "$separator%s" "$field"
      set --function separator " "
    end
  end

  set_color normal
end
