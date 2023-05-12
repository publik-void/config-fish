function pop-buf
  argparse "f/fifo" "t/timeout=" "d/default=" -- $argv

  # UUID with 18 bytes in base64
  # Note: I think it makes sense to have a bit length that is divisible by
  # 8 (for the bytes of `dd`) and 6 (for the digits of `base64`). That way, no
  # space is wasted on padding and there is no variability in message length, so
  # that overlength warnings aren't inconsistent.
  #dd if=/dev/urandom bs=18 count=1 2> /dev/null | base64 | read --function uuid
  # Note: Okay, scratch that, it's way too time-intensive, even when trying to
  # do this several ways… Let's just use a single `random` call.
  set --function uuid (string pad --char "0" --width 10 (random 0 2147483647))

  set --function id "$fish_pid-$uuid"

  set --function interval "0.01"

  set --function finished False
  set --function timeout False
  set --function exit_status 0
  set --function keys
  set --function values
  set --function is (seq0 (count $argv))

  for i in $is
    set --function keys[$i] (string escape --no-quote $argv[$i])
    set --function values[$i] "\$"
  end

  if set --query _flag_fifo
    set --function fifo_path (create-fifo)

    set --query _flag_timeout
    and fish -c "sleep $_flag_timeout; and echo \"timeout#$id\" >> $fifo_path" &

    fish -c "echo \"sentinel#$id\" >> $fifo_path" &

    while not $finished
      cat "$fifo_path" | while read --local pop
        if string split --max 1 "\$" "$pop" | read --line --local key value
          for i in $is
            if [ "$keys[$i]" = "$key" ]
              set --function values[$i] "$value"
            end
          end
        else
          if [ "$key" = "sentinel#$id" ]
            if begin set --query _flag_timeout; and not $timeout
                and not for value in $values
                  and [ "$value" != "\$" ]
                end
              end
              sleep "$interval"
              fish -c "echo \"sentinel#$id\" >> $fifo_path" &
            else
              set --function finished True
            end
          else if [ "$key" = "timeout#$id" ]
            set --function timeout True
          end
        end
      end
    end
  else
    set --universal --query FISH_FILO_BUFFER
    or set --universal FISH_FILO_BUFFER

    while begin not $timeout
        and not for value in $values
          and [ "$value" != "\$" ]
        end
      end
      while set --query FISH_FILO_BUFFER[1]
        set --local pop $FISH_FILO_BUFFER[-1]
        set --universal --erase FISH_FILO_BUFFER[-1]
        if string split --max 1 "\$" "$pop" | read --line --local key value
          for i in $is
            if [ "$keys[$i]" = "$key" ]
              set --function values[$i] "$value"
            end
          end
        else
          # Nothing here but potential … for some directives
        end
      end

      if set --query _flag_timeout
        set --function _flag_timeout (math "$_flag_timeout - $interval")
        [ "$_flag_timeout" -gt 0 ]; or set --function timeout True
      else
        set --function timeout True
      end
    end
  end

  for value in $values
    if [ "$value" = "\$" ]
      set --function exit_status 1
      echo $_flag_default
    else
      string unescape "$value"
    end
  end

  return $exit_status
end

