function fish_mode_prompt --description "Display the `vi` mode for the prompt"
  set --local last_status $status

  set --local prompt_color green
  if not [ $last_status = 0 ]
    set prompt_color brred
  end

  set --local prompt_char # Declare this as a local variable
  switch $fish_bind_mode
    case default
      set prompt_char 'n'
    case insert
      if fish_is_root_user
        set prompt_char '#'
      else
        switch $USER
          case root toor
            set prompt_char '!'
          case lasse schloer pi tweek lasse-schloer
            set prompt_char '>'
          case '*'
            set prompt_char '$'
        end
      end
    case replace_one
      set prompt_char 'r'
    case visual
      set prompt_char 'v'
    case '*'
      set prompt_char '?'
  end

  echo "$(set_color --bold $prompt_color)$prompt_char $(set_color normal)"
end

