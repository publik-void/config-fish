# Note: Normally, Conda creates a block of code in this file when running
# `conda init fish`. This block is apparently managed by Conda then. I don't
# want it to mess with my git repository in non-portable ways, however, so I'll
# add the integration by myself. The caveat here is that the way conda does the
# integration may presumably be subject to change over different versions.

if status is-interactive # I hope it's not needed otherwise
  set --local conda_executable
  for candidate in \
    "conda" \
    "$HOME/anaconda3/bin/conda" \
    "$HOME/miniconda3/bin/conda"
    if command -q "$candidate"
      set conda_executable "$candidate"
    end
  end
  if set --query conda_executable[1]
    eval $conda_executable "shell.fish" "hook" $argv | source
  end
end

