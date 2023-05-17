function get-data-directory
  # TODO: Add fish REPL completions for this

  # Parse args
  argparse --max-args=1 "k/kind=" "n/name=" -- $argv

  # Set default `argv[1]`
  if not set --function --query argv[1]
    set --function argv[1] ""
  end

  # List of kinds (first words in names) of subfolders
  set --function kinds "work" "repo"

  # Find data directory
  if set --query LASSE_DATA_DIRECTORY
    if not test -d "$LASSE_DATA_DIRECTORY"
      echo "get-data-directory: `LASSE_DATA_DIRECTORY` set," \
        "but is not a directory" >&2
      return 1
    end
    set --function data_directory "$LASSE_DATA_DIRECTORY"
  else
    set --local candidates \
      "$HOME/data" \
      "$HOME/Documents/data" \
      "/zdata"
    for candidate in $candidates
      if test -d "$candidate"
        set --function data_directory "$candidate"
      end
    end
  end
  if not set --function --query data_directory
    echo "get-data-directory: unable to find data directory" >&2
    return 1
  end

  # Complete `--kind` and `--name` if given
  for part in "kind" "name"
    set --local flag "_flag_$part"

    if set --function --query "$flag"
      set --local candidates
      set --local separator
      set --local nextvar

      # `part`-specific setup
      if [ "$part" = "kind" ]
        set candidates $kinds
        set separator "-"
        set nextvar "_flag_name"
      else
        set --local ks
        if set --function --query _flag_kind
          set ks "$kind"
        else
          for kind in $kinds
            set --append ks "$kind-"
          end
        end
        for k in $ks
          # Doing this in separate batches per `k` to preserve order of `kinds`
          set --append candidates \
            (ls "$data_directory" | \
             string escape --no-quote -- | \
             sed -n -e "s/^$k//p")
        end
        set candidates (for c in $candidates; echo $c; end | sort -u)
        set separator "/"
        set nextvar "argv[1]"
      end

      # Complete part based on candidates
      for candidate in $candidates
        set --local x "$$flag"
        set --local c "$candidate$separator"
        set --local x_length (string length -- "$x")
        set --local c_length (string length -- "$c")
        if [ "$x_length" -gt "$c_length" ]
          set x (string sub --length "$c_length" -- "$x")
        else
          set c (string sub --length "$x_length" -- "$c")
        end
        if string match --quiet -- "$c" "$x"
          set --function "$part" "$candidate$separator"
          if [ "$x_length" -gt "$c_length" ]
            set --local c_length_plus_one (math "$c_length + 1")
            set --local r (string sub --start "$c_length_plus_one" -- "$$flag")
            set --function "$nextvar" "$r$$nextvar"
          end
          break
        end
      end

      # Check if completion succeeded
      if not set --function --query "$part"
        echo "get-data-directory: could not determine valid $part from" \
          "\"$$flag\"" >&2
        return 1
      end
    else
      set --function "$part"
    end
  end

  # Determine `--kind` if only `--name` was given
  if begin
      set --function --query _flag_name
      and not set --function --query _flag_kind
    end
    set --function --erase kind
    set --local dirname "$name"
    if string match --regex --quiet -- "^.*/.*/\$" "$dirname"
      set dirname (path dirname -- "$dirname")
    end
    for k in $kinds
      if test -d "$data_directory/$k-$dirname"
        set --function kind "$k-"
        break
      end
    end
    if not set --function --query kind
      echo "get-data-directory: kind could not be determined for dirname" \
        "`*-$dirname`" >&2
        return 1
    end
  end

  path normalize -- "$data_directory/$kind$name$argv[1]"
  return 0
end
