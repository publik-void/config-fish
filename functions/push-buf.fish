function push-buf
  argparse "f/fifo" -- $argv

  if not [ (count $argv) -ge 1 ]
    echo "expected at least one argument (key)" >&2
    return 1
  end

  set --function key (string escape --no-quote "$argv[1]")
  set --function commands $argv[2..-1]

  if string match --quiet "*\$*" "$key"
    echo "key is not allowed to contain a \"\$\"" >&2
    return 2
  end

  # Apparently, there is a guarantee that writes of up to 512 bytes into named
  # pipes are atomic. To make sure that messages are written and read intact
  # when using the named pipe with concurrent processes, I should limit the
  # message size accordingly (or at least warn otherwise).
  set --function message_max_bytes 512

  if set --query _flag_fifo
    set --function fifo_path (create-fifo)
  else
    set --universal --query FISH_FILO_BUFFER
    or set --universal FISH_FILO_BUFFER
  end

  set --function r 0
  for command in $commands
    set --function value \
      (eval "$command" | string escape --no-quote | string join "\n")

    set --function message "$key\$$value"

    if set --query _flag_fifo
      set --function n_bytes (echo "$message" | wc -c)
      if [ "$n_bytes" -ge "$message_max_bytes" ]
        echo "warning: resulting message too long" \
          "($n_bytes bytes, $message_max_bytes allowed)" >&2
      end

      echo "$message" >> "$fifo_path"
      or set --function r 4
    else
      set --universal --append FISH_FILO_BUFFER "$message"
    end
  end
  return $r
end

