set --local subcommands eval status mk rm daemon
set --local daemon_subcommands mgr run exit update-time

complete -c fish-background-daemon \
  -f

complete -c fish-background-daemon \
  -n "not __fish_seen_subcommand_from $subcommands" \
  -a "$subcommands"

complete -c fish-background-daemon \
  -n "__fish_seen_subcommand_from mk rm" \
  -r \
  -l count

complete -c fish-background-daemon \
  -n "__fish_seen_subcommand_from rm" \
  -l all

complete -c fish-background-daemon \
  -n "__fish_seen_subcommand_from daemon; \
      and not __fish_seen_subcommand_from $daemon_subcommands" \
  -a "$daemon_subcommands"

complete -c fish-background-daemon \
  -n "__fish_seen_subcommand_from daemon; \
      and __fish_seen_subcommand_from exit" \
  -r \
  -l delta

