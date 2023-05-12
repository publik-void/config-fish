function configured-cwd-prompt
  set -l color_cwd $fish_color_cwd

  set_color $color_cwd
  printf "%s$__fish_prompt_normal" (prompt_pwd)
end

