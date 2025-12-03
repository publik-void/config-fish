# Note: there are plans to phase out universal variables and the recommendation
# is to only do `set --global` here

# `EDITOR` is theoretically meant for editors that work in less capable
# terminals, but nowadays it's probably best to simply set both `EDITOR` and
# `VSIUAL` to one's preferred editor.
command -q vim  && set --global --export EDITOR vim
command -q nvim && set --global --export EDITOR nvim
set --query EDITOR && set --global --export VISUAL $EDITOR

command -q less && set --global --export PAGER  less # Consider using neovim?

# `LANG` is a bit like the last fallback for a locale. Set it if it's not
# pre-set by something else. Some systems support `C.UTF-8` as a neutral Unicode
# locale, but its benefit over `en_US.UTF-8` is marginal or at times even
# negative. So we'll just stick with `en_US.UTF-8` as a sane default.
set --query LANG || set --global --export LANG "en_US.UTF-8"

set --global --export PYENV_ROOT $HOME/.pyenv

if status is-login
  # Prepend custom paths only in login shells. Thus, e.g. when opening a child
  # shell in a `conda` environment, `pyenv` will not override the
  # environment-specific `python3`, unless forced with `fish -l`.
  set --local paths "$HOME/bin" "$HOME/.local/bin" "$HOME/.juliaup/bin" \
    "$HOME/.julia/bin" "$PYENV_ROOT/bin" "$HOME/.cargo/bin" "$HOME/.ghcup/bin" \
    "$HOME/.luarocks/bin"

  if type -q fish_add_path
    # `--prepend` is default, but doesn't hurt to be explicit.
    fish_add_path --prepend --path $paths
  else
    # Filter out nonexistent directories like `fish_add_path` does and keept the
    # order of `paths`.
    set --local paths_existing
    for path in $paths
      if test -d $path
        set --append paths_existing $path
      end
    end

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
