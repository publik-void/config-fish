# So, turns out these locale issues specifically happen when logging in to
# Linux from macOS and the below approach is maybe not the ideal solution (or
# one at all). The Terminal automatically sets environment variables after
# logging in via SSH and that seems to be the issue. There's something about SSH
# forwarding locale settings as well, but I think that's not the issue I'm
# experiencing. See:
# https://askubuntu.com/questions/599808/cannot-set-lc-ctype-to-default-locale-
#   no-such-file-or-directory
# The solution would be to disable a checkbox in the terminal application.
# E.g. for iTerm2, Preferences -> Profiles -> Terminal -> Environment -> "Set
# locale variables automatically"
#switch (hostname)
#case lasse-mbp-0 lasse-mba-0
#  export LANG=en_US
#end

