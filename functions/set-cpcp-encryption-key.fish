function set-cpcp-encryption-key
  argparse --max-args 1 \
    "q/quiet" "r/random=?" "d/delta=!_validate_int --min 0" \
    -- $argv; or return $status

  set --function key_color yellow

  if [ (count $argv) = 0 ]; and set --query _flag_random; and type -q cpcp
    set --function key
  else if [ (count $argv) = 1 ]; and type -q cpcp
    set --function key "$argv[1]"
  else
    user-tmp-file rm "cpcp-encryption-key-mtime"
    user-tmp-file rm "cpcp-encryption-key"
    type -q cpcp
    return $status
  end

  set --function time (date "+%s")
  set --function cpcp_encryption_key_mtime \
    (user-tmp-file read "cpcp-encryption-key-mtime" 2> /dev/null)
  or set --function --erase cpcp_encryption_key_mtime
  if begin not set --query _flag_delta
      or not set --query cpcp_encryption_key_mtime
      or [ (math "$time - $cpcp_encryption_key_mtime") -gt "$_flag_delta" ]
    end

    set --function previous_key \
      (user-tmp-file read "cpcp-encryption-key" 2> /dev/null)
    or set --function --erase previous_key

    if set --query _flag_random
      if not set --query _flag_random[1]
        set _flag_random "32"
      end

      set --function n_bytes (math --scale=0 "ceil($_flag_random / 4) * 3")
      set --function rnd (cpcp --base64 rand $n_bytes)
      set --function rnd (string sub --length $_flag_random "$rnd")
    else
      set --function rnd
    end

    user-tmp-file write "cpcp-encryption-key-mtime" "$time"
    user-tmp-file write "cpcp-encryption-key" "$key$rnd"

    if not set --query _flag_quiet
      echo -n "New CPCP encryption key set."
      if set --query previous_key
        echo " To undo, run:"
        echo -n " `"
        set_color --bold
        echo -n "set-cpcp-encryption-key "
        set_color normal
        set_color $key_color
        echo -n "\""
        set_color --background $key_color
        echo -n -- "$previous_key"
        set_color normal
        set_color $key_color
        echo -n "\""
        set_color normal
        echo -n "`"
      end
      echo
    end
  end
end

