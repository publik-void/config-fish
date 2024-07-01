if type -q pyenv
  if status is-interactive
    pyenv init - | source
  else
    pyenv init --path | source
  end
end

