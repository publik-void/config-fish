function fish_mode_prompt --description "Display the `vi` mode for the prompt"
  set -l last_status $status

  # Note: I specify colors directly here. I could alternatively use Fish's
  # universal variables like `fish_color_error`, defined in
  # `~/.config/fish/fish_variables`.
  # Note: I'd like to use bold characters, but depending on the setup this may
  # just result in a different color assignment, which seems to be the case with
  # my setup (as of 2022-02-03), so yeah…
  set -l prompt_color green
  if not test $last_status -eq 0
    set prompt_color brred
  end

  set_color $prompt_color

  set -l prompt_text # Declare this as a local variable
  switch $fish_bind_mode
    case default
      set prompt_text 'n'
    case insert
      switch $USER
        case root toor
          set prompt_text '#'
        case lasse schloer pi tweek
          set prompt_text '>'
        case '*'
          set prompt_text '$'
      end
    case replace_one
      set prompt_text 'r'
    case visual
      set prompt_text 'v'
    case '*'
      set prompt_text '?'
  end

  printf $prompt_text

  set_color normal
end

