function fish_mode_prompt --description "Display the `vi` mode for the prompt"
  set --function last_status $status
  set --function defer_to_fish_prompt false

  if [ $fish_bind_mode = insert ]
    if ! set --query coming_from_non_insert_mode
      # If additional info needs to be printed above the prompt, defer to
      # `fish_prompt`, which then handles the printing.

      set --local previous_prompt_time (prompt-time --write --number=2 --elapsed)
      if begin set --query FISH_NEW_GREETING_DELTA
          and [ (count $previous_prompt_time) != 0 ]
          and [ $previous_prompt_time -gt $FISH_NEW_GREETING_DELTA ]
        end
        set --global new_greeting_delta_exceeded
      else
        set --global --erase new_greeting_delta_exceeded
      end

      if begin set --query CPCP_ENCRYPTION_KEY_DELTA
          and begin not set --query CPCP_ENCRYPTION_KEY_MTIME
            or [ (math "$(date "+%s") - $CPCP_ENCRYPTION_KEY_MTIME") -gt \
              "$CPCP_ENCRYPTION_KEY_DELTA" ]
          end
        end
        set --global cpcp_encryption_key_delta_exceeded
      else
        set --global --erase cpcp_encryption_key_delta_exceeded
      end
    end
    set --global --erase coming_from_non_insert_mode
  else
    set --global coming_from_non_insert_mode
  end

  if begin set --query new_greeting_delta_exceeded
      or set --query cpcp_encryption_key_delta_exceeded
    end
    set defer_to_fish_prompt true
  end

  # Note: I specify colors directly here. I could alternatively use Fish's
  # universal variables like `fish_color_error`, defined in
  # `~/.config/fish/fish_variables`.
  # Note: I'd like to use bold characters, but depending on the setup this may
  # just result in a different color assignment, which seems to be the case with
  # my setup (as of 2022-02-03), so yeah…
  set --local prompt_color green
  if not test $last_status -eq 0
    set prompt_color brred
  end

  set --local prompt_char # Declare this as a local variable
  switch $fish_bind_mode
    case default
      set prompt_char 'n'
    case insert
      switch $USER
        case root toor
          set prompt_char '#'
        case lasse schloer pi tweek
          set prompt_char '>'
        case '*'
          set prompt_char '$'
      end
    case replace_one
      set prompt_char 'r'
    case visual
      set prompt_char 'v'
    case '*'
      set prompt_char '?'
  end
  set --local prompt_text "$prompt_char "

  if ! $defer_to_fish_prompt
    set_color $prompt_color
    printf $prompt_text
    set_color normal
  else
    set --global deferred_fish_mode_prompt_color $prompt_color
    set --global deferred_fish_mode_prompt_text $prompt_text
    # Supposedly, fish calls fish_prompt here if fish_mode_prompt has not
    # produced output, after the mode was changed. Maybe this was the case back
    # in the day, but I don't see it. This results in no mode prompt updates
    # when $defer_to_fish_prompt is true. I guess I'll live with that for now…
    # TODO
  end
end

