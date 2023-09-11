function configured-cwd-prompt
  set -l color_cwd $fish_color_cwd

  set_color $color_cwd
  echo (prompt_pwd)"$__fish_prompt_normal"
end

