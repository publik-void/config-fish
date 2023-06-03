set --local subcommands dirname list read write append rm

complete -c user-tmp-file \
  -n "not __fish_seen_subcommand_from $subcommands" \
  -f \
  -a "$subcommands"

complete -c user-tmp-file \
  -n "__fish_seen_subcommand_from list read write append rm" \
  -f \
  -a "(user-tmp-file list)"
