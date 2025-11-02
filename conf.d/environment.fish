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
    "$PYENV_ROOT/bin" "$HOME/.cargo/bin" "$HOME/.ghcup/bin" \
    "$HOME/.luarocks/bin"

  if type -q fish_add_path
    fish_add_path --path $paths
  else
    set --prepend PATH $paths
  end
end

# LuaRocks needs host/user-specific environment variables. Alternatively, the
# LuaRocks loader can be used in any Lua script. That's perhaps the way to go so
# I'm commenting out the lines below.
# if type -q luarocks
#   # Unfortunately, `luarocks path` can take a second or two to run.
#   set -q LUA_PATH; and set -q LUA_CPATH; or bass (luarocks path --no-bin)
# end
