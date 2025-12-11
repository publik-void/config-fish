function eval-async-latched
  if not set --query argv[2]
    echo "\
Usage:
  eval-async-latched name command args...

Evaluate `\$command \$args` in a disowned `fish` subprocess and save to a
temporary `tmux` buffer `\$async_id-\$name` or file
`\$async_dir/\$async_id/\$name` if the directory given by the environment
variables `async_dir[1]` and `async_id[1]` exist.

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

  # Maybe this second check is redundant, I don't know.
  if set --query TMUX[1] && [ "$TMUX" != "" ]
    $fish --no-config -c "\
set data \"\$($command)\"
if [ \$status = 0 ] && set --query data[1] && [ \"\$data\" != \"\" ]
  tmux set-buffer -b '$async_id-$name' \"\$data\"
else
  tmux delete-buffer -b '$async_id-$name' 2> /dev/null
end
" &
    disown $last_pid
    tmux show-buffer -b "$async_id-$name" 2> /dev/null
    return $status
  else
    if set --query async_dir[1] && set --query async_id[1]
      set --local dirname "$async_dir/$async_id"
      set --local filename "$dirname/$name"

      $fish --no-config -c "\
set data \"\$($command)\"

mkdir -p '$dirname' || return 1
test ! -e '$filename' -o \
  \( -f '$filename' -a -O '$filename' -a -w '$filename' \) || return 1

if [ \$status = 0 ] && set --query data[1] && [ \"\$data\" != \"\" ]
  echo \"\$data\" > '$filename'
else
  rm -f '$filename'
end
" &
      disown $last_pid

      # We could test for the existence of the file before `cat`ting it, but it
      # seems like in rare cases, the file may be deleted by the disowned
      # process just between the `test` and the `cat` command. Hence let's just
      # assume that `cat` might fail and let it do so silently.
      cat "$filename" 2> /dev/null
      return 0
    else
      echo "eval-async-latched: `async_dir[1]` or `async_id[1]` not set." >&2
      return 1
    end
  end
end
