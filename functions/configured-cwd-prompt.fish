function configured-cwd-prompt
  set_color $color_cwd
  echo "$(set_color $fish_color_cwd)$(prompt_pwd)$(set_color normal) "
end

