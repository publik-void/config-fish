function fish_right_prompt --description 'Write out the right prompt'

    if not set -q __fish_prompt_normal
        set -g __fish_prompt_normal (set_color normal)
    end

    set --function uuid (string pad --char "0" --width 10 (random 0 2147483647))
    set --function id "$fish_pid-$uuid"

    fish -c "push-buf \"git-prompt#$id\" \"configured-git-prompt\"" &
    fish -c "push-buf \"cwd-prompt#$id\" \"configured-cwd-prompt\"" &

    set --function red_esc (set_color red)
    set --function default \
      (string join "" "($red_esc" "timeout$__fish_prompt_normal)")

    pop-buf --timeout=1 --default="$default" \
      "git-prompt#$id" "cwd-prompt#$id" | while read --line --local field
      [ "$field" ]; and printf "%s " "$field"
    end

    set_color normal
end
