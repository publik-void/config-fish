function create-fifo
  set --function fifo_path "$FISH_ASYNC_FIFO_PATH"

  if begin test -e "$fifo_path"; and not test -p "$fifo_path"; end
    echo "warning: removing \"$fifo_path\" which is not a named pipe" >&2
    rm -f "$fifo_path"
  end

  if not test -p "$fifo_path"
    mkfifo "$fifo_path"
    or return $status
  end

  printf "%s" "$fifo_path"
end

