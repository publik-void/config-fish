function fish_prompt --description 'Write out the prompt'
  if set --query deferred_fish_mode_prompt_text
    if set --query new_greeting_delta_exceeded
      fish_greeting
    end

    set_color $deferred_fish_mode_prompt_color
    printf $deferred_fish_mode_prompt_text
    set_color normal
    set --global --erase deferred_fish_mode_prompt_text
    set --global --erase deferred_fish_mode_prompt_color
  end
end
