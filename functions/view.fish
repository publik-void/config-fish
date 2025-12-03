# `vim` comes with various extra command names. One of those is `view`, which is
# essentially an alias for `vim -R`. `nvim` doesn't have these by default,
# therefore this wrapper function.

function view --wraps nvim --description '`view` with `nvim`'
  if type -q nvim
    command nvim -R $argv
  else
    command view $argv
  end
end

