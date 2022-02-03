function fish_prompt --description 'Write out the prompt'
  set -l last_status $status
  # Note: I specify colors directly here. I could alternatively use Fish's
  # universal variables like `fish_color_error`, defined in
  # `~/.config/fish/fish_variables`.
  set -l prompt_color green
  if not test $last_status -eq 0
    set prompt_color brred
  end

  set -l prompt_text
  switch "$USER"
    case root toor
      set prompt_text '# '
    case '*'
      set prompt_text '> '
    end
    if test "$fish_key_bindings" = "fish_vi_key_bindings"
    switch $fish_bind_mode
      case default
        set prompt_text 'n '
      case replace_one
        set prompt_text 'r '
      case visual
        set prompt_text 'v '
      #case insert
      #  set prompt_text 'i '
      case '*'
        # Do nothing
    end
  end
  set_color $prompt_color
  printf $prompt_text
  set_color normal
end
