function esc --description "helper function for escaping strings"
  argparse --exclusive="j,s" \
    "u/unescape" "j/join=?" "s/split=?" "p/prefix=?" -- $argv

  set --local args
  if isatty
    set args $argv
  else
    if set --query $argv[1]
      echo "esc: too many arguments"
      return 2
    end
    set args
    while read x
      set --append args $x
    end
  end

  set --query _flag_split
  and set _flag_join $_flag_split

  set --query _flag_join
  and not set --query _flag_join[1]
  and set _flag_join "\n"

  set --query _flag_prefix
  and not set --query _flag_prefix[1]
  and set _flag_prefix "\$"

  set local exit_code 0

  if set --query _flag_unescape
    if set --query _flag_prefix
      set --local prefix \
        (string escape --no-quote --style=regex "$_flag_prefix")
      if begin; set --query _flag_join; and [ "$_flag_join" = "\n" ]; end
        set --erase _flag_join
      end
      if set --query _flag_join
        for arg in $args
          string match --regex --groups-only -- "^$prefix(.*)" "$arg" | \
            string split -- "$_flag_join" | string unescape --
          or set exit_code 1
        end
      else
        for arg in $args
          string match --regex --groups-only -- "^$prefix(.*)" "$arg" | \
            string unescape --
          or set exit_code 1
        end
      end
    else
      if set --query _flag_join
        string split -- "$_flag_join" $args | string unescape --
      else
        string unescape -- $args
      end
    end
  else
    set --local output
    if set --query _flag_join
      set output \
        (string escape --no-quote -- $args | string join -- "$_flag_join")
    else
      if set --query _flag_prefix
        set --local separator \n
        set output (string escape --no-quote -- $args | \
            string join -- "$separator$_flag_prefix")
      else
        set output (string escape --no-quote -- $args)
      end
    end
    set --query _flag_prefix
    and set output "$_flag_prefix$output"
    # Re-printing because sometimes it's important to not flush prematurely
    printf "%s\n" "$output"
  end

  return $exit_code
end

