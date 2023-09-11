# Note: there are plans to phase out universal variables and the recommendation
# is to only do `set --global` here

type -q nvim; and set --global --export EDITOR nvim
type -q less; and set --global --export PAGER less # Consider using neovim?

fish_add_path --path $HOME/bin
fish_add_path --path $HOME/.juliaup/bin

