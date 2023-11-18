# Note: there are plans to phase out universal variables and the recommendation
# is to only do `set --global` here

type -q nvim && set --global --export EDITOR nvim
type -q vim  && set --global --export EDITOR vim
type -q less && set --global --export PAGER less # Consider using neovim?

begin
  set --local paths "$HOME/bin" "$HOME/.juliaup/bin"

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

