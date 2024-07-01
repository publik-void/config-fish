function prompt-right-pyenv
  if type -q pyenv
    set pyenv_version_name (pyenv version-name)
    if [ "$pyenv_version_name" != system ]
      echo "$(set_color white)$pyenv_version_name$(set_color normal) "
    end
  end
end

