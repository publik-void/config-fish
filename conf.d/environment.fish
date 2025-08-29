# Note: there are plans to phase out universal variables and the recommendation
# is to only do `set --global` here

command -q nvim && set --global --export EDITOR nvim
command -q vim  && set --global --export EDITOR vim
command -q less && set --global --export PAGER  less # Consider using neovim?

set --global --export PYENV_ROOT $HOME/.pyenv

# Prepend custom paths only in login shells. Thus, e.g. when opening a child
# shell in a `conda` environment, `pyenv` will not override the
# environment-specific `python3`, unless forced with `fish -l`.
if status is-login
  set --local paths "$HOME/bin" "$HOME/.local/bin" "$HOME/.juliaup/bin" \
    "$PYENV_ROOT/bin" "$HOME/.cargo/bin"

  if type -q fish_add_path
    fish_add_path --path $paths
  else
    set --prepend PATH $paths
  end
end

