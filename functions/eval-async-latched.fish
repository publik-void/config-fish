function eval-async-latched
  if not set --query argv[2]
    echo "\
Usage:
  eval-async-latched name command args...

Evaluate `command args...` in a disowned `fish` subprocess and save to a
temporary `tmux` buffer `async_id-name` or file `async_dir/async_id/name` if the
directory given by the environment variable `async_dir` exists.

Print the contents of this buffer or file immediately, if it exists. This will
usually print the output of the previous subprocess.

Fish is called with `--no-config`, so functions must be sourced before calling,
environment variables must be set if needed (and not exported), etc.

`name`, `async_id`, and `async_dir` will be set into single quotes (`'`) with no
additional escaping. Thus, it is important that they do not contain any single
quote characters." >&2
    return 1
  end

  set --local name "$argv[1]"
  set --local command $argv[2..-1]

  set --local fish (status fish-path)

  if set --query TMUX
    $fish --no-config -c \
      "tmux set-buffer -b '$async_id-$name' \"\$($command)\"" &
    disown $last_pid
    tmux show-buffer -b "$async_id-$name" 2> /dev/null
  else
    if set --query async_dir[1]
      set --local dirname "$async_dir/$async_id"
      set --local filename "$dirname/$name"

      $fish --no-config -c "\
if not test -d '$dirname'
  mkdir -p '$dirname'
  test -d '$dirname' || return 1
end
test -e '$filename' || touch '$filename'
test -f '$filename' || return 1
test -O '$filename' || return 1
test -w '$filename' || return 1
echo \"\$($command)\" > '$filename'
" &
      disown $last_pid

      if test -e "$dirname"
        if test -f "$filename"
          cat "$filename" && return $status
        end
      end
    else
      echo "eval-async-latched: `async_dir[1]` not set." >&2
      return 1
    end
  end
end
