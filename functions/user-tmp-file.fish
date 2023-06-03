function user-tmp-file --description \
  "An interface to load and store data in temporary files. The motivation being
  that fish universal variables functionality may not be around in the future."

  # TODO: Extend this to optionally use named pipes
  # Ideally in a way where there's a guarantee that a named pipe contains one
  # input iff it exists … should be doable, right?
  set --local usage_message "Usage:
  user-tmp-file dirname
  user-tmp-file list    [<name> ...]
  user-tmp-file query   [<name> ...]
  user-tmp-file read    <name>
  user-tmp-file write   <name> [<contents> ...]
  user-tmp-file append  <name> [<contents> ...]
  user-tmp-file rm      [<name> ...]"

  if set --query argv[1]
    if begin [ "$argv[1]" = "dirname" ]
        and [ (count $argv) = 1 ]
      end
      set --local dir
      if set --query FISH_USER_TMP_FILE_DIR
        set dir "$FISH_USER_TMP_FILE_DIR"
        test -d "$dir"; or begin
          echo "user-tmp-file:" \
            "FISH_USER_TMP_FILE_DIR set, but is not a directory" >&2
          return 2
        end
      else
        set --local dir_candidates \
          "/dev/shm" "/run/shm" "/tmp" "$HOME/.config/fish"
        for dir_candidate in $dir_candidates
          test -d "$dir_candidate"; and begin
            set dir "$dir_candidate"
            break
          end
        end
        set --query dir[1]; or begin
          echo "user-tmp-file:" \
            "none of the following are directories: $dir_candidates" >&2
          return 3
        end
        set --global --export FISH_USER_TMP_FILE_DIR "$dir"
      end

      set --local subdir
      if set --query FISH_USER_TMP_FILE_SUBDIR
        set subdir "$FISH_USER_TMP_FILE_SUBDIR"
      else
        set subdir "fish-user-tmp-files-u$(id -u)-g$(id -g)"
        set --global --export FISH_USER_TMP_FILE_SUBDIR "$subdir"
      end

      echo "$dir/$subdir"
      return 0
    else if [ "$argv[1]" = "list" ]
      set --local dirname (user-tmp-file dirname); or return $status
      test -d "$dirname"; or return 0
      set --local names $argv[2..-1]
      if [ (count $names) = 0 ]
        set names (ls -A "$dirname")
      end
      for name in $names
        test -f "$dirname/$name"; and echo -- "$name"
      end
      return 0

    else if begin
        [ "$argv[1]" = "query" ]
      end
      set --local dirname (user-tmp-file dirname); or return $status
      for arg in $argv[2..-1]
        if not test -f "$dirname/$arg"
          return 127
        end
      end
      return 0

    else if begin
        [ "$argv[1]" = "read" ]
        and [ (count $argv) = 2 ]
      end
      set --local dirname (user-tmp-file dirname); or return $status
      set --local file "$dirname/$argv[2]"
      if test -f "$file"
        cat "$file" | esc --unescape --prefix --
        return $status
      else
        echo "user-tmp-file:" \
          "$file is not a file" >&2
        return 4
      end

    else if begin;
        begin; [ "$argv[1]" = "write" ]; or [ "$argv[1]" = "append" ]; end
        and set --query argv[2]
      end
      set --local dirname (user-tmp-file dirname); or return $status
      test -d "$dirname"; or mkdir -m 700 "$dirname"; or return $status

      set --local file "$dirname/$argv[2]"
      touch "$file"; and chmod 600 "$file"; or return $status

      [ "$argv[1]" = "write" ]; and printf "" > "$file"
      true; for arg in $argv[3..-1]
        and esc --prefix -- "$arg" >> "$file"
      end

      return $status

    else if [ "$argv[1]" = "rm" ]
      set --local dirname (user-tmp-file dirname); or return $status
      set --local return_status 0
      if [ (count $argv) = 1 ]
        rm -rf "$dirname"; or set return_status 5
      else
        for arg in $argv[2..-1]
          rm -f "$dirname/$arg"; or set return_status 6
        end
      end
      return $return_status
    end
  end

  echo "$usage_message" >&2
  return 1
end

