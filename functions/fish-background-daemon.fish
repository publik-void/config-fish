function fish-background-daemon
  set --function usage_message "\
Usage:
  fish-background-daemon eval [commands ...]
  fish-background-daemon status
  fish-background-daemon mk [--count=]
  fish-background-daemon rm [--count=] [--all]

  fish-background-daemon daemon mgr [args ...]
  fish-background-daemon daemon run [args ...]
  fish-background-daemon daemon exit [--delta=] [message ...]
  fish-background-daemon daemon update-time

I wrote this function out of the necessity to have reasonably performant
concurrency in the fish shell. Since fish will not run functions concurrently
and does not have subshells, running fish code concurrently requires invoking a
new fish process. This function takes care of maintaining a pool of background
'daemon' processes to run concurrent code, avoiding the need to wait for a new
process to launch when some code needs to be run concurrently.

Subcommands:
  eval
    Run the command(s) in the next idle daemon.
    Automatically create a new daemon if none exist.

  status
    Output the PIDs of currently running daemons managed by the current shell.
    Return status is nonzero if current shell is itself a daemon.
    Note: This is not meant to imply that daemons cannot have subdaemons.

  mk
    Create 1 (or `count`) new daemons.

  rm
    Send an exit subcommand to the next 1 (or `count`) idle daemons.
    Return status is nonzero if none exist.

    `--all` stops all daemons.

  daemon mgr
    Run code for the supervising process.

  daemon run
    Run daemon code.

  daemon exit
    Tell a daemon to stop and remove itself.
    Let it output any `message`s to stderr.
    If `delta` is given, only exit if there have not been commands running for
    `delta` number of seconds.

  daemon update-time
    Tell a daemon to update its internal time stamp.

Environment variables:
  FISH_BACKGROUND_DAEMON_MGR_INTERVAL
  FISH_BACKGROUND_DAEMON_MGR_DELTA
    Can be set to override the default time to live and checking period for
    daemons."

  # Constant parameters
  set --function base_directory_dirnames_list "/dev/shm" "/run/shm" "/tmp"
  set --function base_directory_basename_prefix "fish-background-daemons"
  set --function common_buffer_name "common"
  set --function mgr_interval "600"
  set --function mgr_delta "300" # Must be smaller than `mgr_interval`

  # Get subcommand
  if not set --query argv[1]
    echo $usage_message >&2
    return 1
  end
  set --function subcommand $argv[1]
  set --function argv $argv[2..-1]

  # Handle daemon subcommands
  if [ "$subcommand" = "daemon" ]
    # Get daemon subcommand
    if not set --query argv[1]
      echo $usage_message >&2
      return 1
    end
    set --function daemon_subcommand $argv[1]
    set --function argv $argv[2..-1]

    if [ "$daemon_subcommand" = "exit" ]
      argparse "d/delta=!_validate_int --min 1" -- $argv
      or return $status

      if set --query _flag_delta
        if not set --global --query FISH_BACKGROUND_DAEMON_LAST_UPDATE_TIME
          echo "fish-background-daemon:" \
            "FISH_BACKGROUND_DAEMON_LAST_UPDATE_TIME not set" >&2
          return 1
        end
        set --local current_time (date +%s)
        set --local current_delta (math --scale=0 \
          "$current_time - $FISH_BACKGROUND_DAEMON_LAST_UPDATE_TIME")
        [ "$current_delta" -le "$_flag_delta" ]; and return 0
      end

      set --query $argv[1]; and echo -- $argv >&2
      if set --query FISH_DAEMON_FILE
        test -f "$FISH_DAEMON_FILE"; and rm "$FISH_DAEMON_FILE"
        exit
      else
        echo "fish-background-daemon:" \
          "apparently not a daemon, but exiting nonetheless" >&2
        exit 1
      end
    else if [ "$daemon_subcommand" = "update-time" ]
      set --global FISH_BACKGROUND_DAEMON_LAST_UPDATE_TIME (date +%s)
      return
    else if [ "$daemon_subcommand" = "run" ]
      if [ (count $argv) != 2 ]
        echo "fish-background-daemon daemon run:" \
          "expected exactly 2 arguments" >&2
        return 1
      end

      set --local directory "$argv[1]"
      set --local common_file "$argv[2]"

      # A bit of explanation for some of the below:
      # If several commands are read from the named pipe, all except the first
      # will be written back into the named pipe, because we can't guarantee
      # that the current daemon will still be around to process them all after
      # the first (e.g. when sending multiple exits).
      # `fish` won't put `echo` or even `/bin/echo` into the background and thus
      # I use `tee` to do the job.
      set --global FISH_DAEMON_FILE \
        (path normalize -- "$directory/$fish_pid")
      if test -e "$FISH_DAEMON_FILE"; rm -r "$FISH_DAEMON_FILE"; end
      fish-background-daemon daemon update-time
      touch "$FISH_DAEMON_FILE"; chmod 600 "$FISH_DAEMON_FILE"
      while begin
          test -p "$common_file"
          test -f "$FISH_DAEMON_FILE"
        end
        for file in "$common_file" "$FISH_DAEMON_FILE"
          if test -e "$file"
            set --local escaped_commands (cat "$common_file")
            if set --local --query escaped_commands[2]
              for escaped_command in $escaped_commands[2..-1]
                echo -- "$escaped_command" | \
                  tee "$common_file" > /dev/null & \
              end
            end
            if set --local --query escaped_commands[1]
              set --local escaped_command $escaped_commands[1]
              set --local command \
                (esc --unescape --prefix --join "$escaped_command")
              or fish-background-daemon daemon exit \
                "exiting because of faulty command input"
              eval $command
              fish-background-daemon daemon update-time
            end
          end
        end
        test -f "$FISH_DAEMON_FILE"; and echo > "$FISH_DAEMON_FILE"
      end
      if test -f "$FISH_DAEMON_FILE"; rm "$FISH_DAEMON_FILE"; end
      return 1

    else if [ "$daemon_subcommand" = "mgr" ]
      if [ (count $argv) != 2 ]
        echo "fish-background-daemon daemon mgr:" \
          "expected exactly 2 arguments" >&2
        return 1
      end

      set --query FISH_BACKGROUND_DAEMON_MGR_DELTA
      and set mgr_delta "$FISH_BACKGROUND_DAEMON_MGR_DELTA"
      set --query FISH_BACKGROUND_DAEMON_MGR_INTERVAL
      and set mgr_interval "$FISH_BACKGROUND_DAEMON_MGR_INTERVAL"
      if [ "$mgr_delta" -ge "$mgr_interval" ]
        echo "fish-background-daemon daemon mgr:" \
          "delta must be smaller than interval" >& 2
        return 1
      end

      set --local directory "$argv[1]"
      set --local common_file "$argv[2]"

      while test -p "$common_file"
        sleep "$mgr_interval"
        set --local daemon_file_basenames (ls "$directory/")
        set --local n_daemons (count $daemon_file_basenames)
        if [ "$n_daemons" -gt 0 ]
          for daemon_file_basename in "$daemon_file_basenames"
            echo "fish-background-daemon daemon exit --mgr_delta=$mgr_delta" | \
              tee "$common_file" > /dev/null &
          end
        else
          # Empty common buffer, remove directory, exit
          echo "#end" | tee "$common_file" > /dev/null &
          while test -p "$common_file"
            set --local escaped_commands (cat "$common_file")
            for escaped_command in $escaped_commands
              string match --quiet --regex -- ".*#end\$" "$escaped_command"
              and rm "$common_file"
            end
          end
          rm -r "$directory"
        end
      end
      return 0
    else
      echo $usage_message >&2
      return 1
    end
  end

  # Determine directories
  set --function base_directory_dirname
  if set --query FISH_BACKGROUND_DAEMON_BASE_DIRECTORY_DIRNAME
    set --function base_directory_dirname \
      "$FISH_BACKGROUND_DAEMON_BASE_DIRECTORY_DIRNAME"
    if not test -d "$base_directory_dirname/"
      echo "fish-background-daemon:" \
        "FISH_BACKGROUND_DAEMON_BASE_DIRECTORY_DIRNAME set, but nonexistent"
    end
  else
    for dirname in $base_directory_dirnames_list
      if test -d "$dirname/"
        set --function base_directory_dirname "$dirname"
        break
      end
    end
    if set --function --query base_directory_dirname[1]
      set --global --export FISH_BACKGROUND_DAEMON_BASE_DIRECTORY_DIRNAME \
        "$base_directory_dirname"
    else
      echo "fish-background-daemon:" \
        "none of the possible base directory dirnames exist" >&2
      return 1
    end
  end
  set --function base_directory \
    "$base_directory_dirname/$base_directory_basename_prefix-u$(id -u)-g$(id -g)"
  set --function directory "$base_directory/$fish_pid"
  set --function common_file "$directory/.$common_buffer_name"

  # Handle non-daemon subcommands (that depend on the above setup)
  if [ "$subcommand" = "mk" ]
    argparse --max-args=0 "n/count=!_validate_int --min 1" -- $argv
    or return $status

    if not test -d "$directory/"
      if not test -d "$base_directory/"
        mkdir -m 700 "$base_directory"
      end
      mkdir -m 700 "$directory"
    end
    if not test -p "$common_file"
      mkfifo -m 600 "$common_file"
      fish -c "fish-background-daemon daemon mgr \
        \"$directory\" \"$common_file\"" &
      disown (jobs --last --pid)
    end

    set --local n_daemons_to_make 1
    set --query _flag_count; and set n_daemons_to_make "$_flag_count"

    for i in (seq0 "$n_daemons_to_make")
      fish -c "fish-background-daemon daemon run \
        \"$directory\" \"$common_file\"" &
      disown (jobs --last --pid)
    end

  else if [ "$subcommand" = "rm" ]
    argparse --max-args=0 --exclusive="n,a" \
      "n/count=!_validate_int --min 1" "a/all" -- $argv
    or return $status

    set --local n_daemons 0
    test -d "$directory/"; and set n_daemons (count (ls "$directory/"))
    set --local n_daemons_to_remove 1
    if set --query _flag_count
      set n_daemons_to_remove "$_flag_count"
    else if set --query _flag_all
      set n_daemons_to_remove "$n_daemons"
    end
    if begin
        test -p "$common_file"
        and [ "$n_daemons" -gt 0 ]
        and [ "$n_daemons_to_remove" -le "$n_daemons" ]
      end
      for i in (seq0 "$n_daemons_to_remove")
        esc --prefix --join -- "fish-background-daemon daemon exit" > \
          "$common_file"
      end
    else
      set --query _flag_all; and set n_daemons_to_remove "all"
      echo "fish-background-daemon:" \
        "requested to remove $n_daemons_to_remove daemons," \
        "but $n_daemons found" >&2
      return 1
    end

  else if [ "$subcommand" = "status" ]
    if [ (count $argv) != 0 ]
      echo "fish-background-daemon status:" \
        "expected exactly 0 arguments" >&2
      return 1
    end
    test -d "$directory/"; and ls "$directory/" | cat
    not set --global --query FISH_DAEMON_FILE; return $status

  else if [ "$subcommand" = "eval" ]
    begin
      test -p "$common_file"
      and [ "$(count (ls "$directory/"))" -gt 0 ]
    end
    or fish-background-daemon mk

    if test -p "$common_file"
      esc --prefix --join -- $argv > "$common_file"
    else
      echo "fish-background-daemon:" \
        "creation of $common_file failed" >&2
        return 1
    end

  else
    echo $usage_message >&2
    return 1
  end
end

