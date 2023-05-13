function configured-status-prompt
  argparse --max-args=0 "n/value=!_validate_int --min 0 --max 255" -- $argv \
    1>/dev/null 2> /dev/null
  and set --query _flag_value
  and [ $_flag_value != 0 ]
  and begin
    if not set --query __fish_prompt_normal
        set --global __fish_prompt_normal (set_color normal)
    end
    set --function red_esc (set_color red)
    string join "" "($_flag_value$red_esc" "↵$__fish_prompt_normal)"
  end
end

