# Note: there are plans to phase out universal variables and the recommendation
# is to only do `set --global` here

command -q nvim && set --global --export EDITOR nvim
command -q vim  && set --global --export EDITOR vim
command -q less && set --global --export PAGER  less # Consider using neovim?

set --global --export PYENV_ROOT $HOME/.pyenv

begin
  set --local paths "$HOME/bin" "$HOME/.local/bin" "$HOME/.juliaup/bin" \
    "$PYENV_ROOT/bin"

  if type -q fish_add_path
    for path in $paths
      fish_add_path --path "$path"
    end
  else
    for path in $paths
      set --append PATH "$path"
    end
  end
end

