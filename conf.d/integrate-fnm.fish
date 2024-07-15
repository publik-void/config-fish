if type -q fnm
  fnm env --use-on-cd | source
  fnm completions --shell fish | source
end
