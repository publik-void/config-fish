function get-data-directory
  # TODO: I feel like there's a bunch of stuff that's a bit messy about these
  # `get-data-directory` type functions. I'm not gonna list everything here
  # right now, but suffice it to say that I think these could use a makeover
  # where a bunch of stuff is made a bit more sensible and modular and the
  # functions work nicely together with the completions and so on. However,
  # since these functions will only save me a couple seconds here and there in
  # my workflow, it's probably a bad idea to spend more time on improving them.
  # I guess they more or less do their job for now.

  # Parse args
  argparse --max-args=1 "k/kind=" "n/name=" "d/data-directory=" -- $argv

  # Set default `argv[1]`
  if not set --query argv[1]
    set argv[1] ""
  end

  # List of kinds (first words in names) of subfolders
  set --local kinds "work" "repo"

  # Find data directory
  set --local data_directory
  if set --query _flag_data_directory
    set data_directory "$_flag_data_directory"
  else if set --query LASSE_DATA_DIRECTORY
    if not test -d "$LASSE_DATA_DIRECTORY"
      echo "get-data-directory: `LASSE_DATA_DIRECTORY` set," \
        "but is not a directory" >&2
      return 1
    end
    set data_directory "$LASSE_DATA_DIRECTORY"
  else
    set --local candidates \
      "$HOME/data" \
      "$HOME/Documents/data" \
      "/zdata"
    for candidate in $candidates
      if test -d "$candidate"
        set data_directory "$candidate"
      end
    end
  end
  if not set --query data_directory[1]
    echo "get-data-directory: unable to find data directory" >&2
    return 1
  end

  # Complete `--kind` and `--name` if given
  set --local kind
  set --local name
  for part in "kind" "name"
    set --local flag "_flag_$part"

    if set --query "$flag"
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
        if set --query _flag_kind
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
          set "$part" "$candidate$separator"
          if [ "$x_length" -gt "$c_length" ]
            set --local c_length_plus_one (math "$c_length + 1")
            set --local r (string sub --start "$c_length_plus_one" -- "$$flag")
            set "$nextvar" "$r$$nextvar"
          end
          break
        end
      end

      # Check if completion succeeded
      if not set --query "$part[1]"
        echo "get-data-directory: could not determine valid $part from" \
          "\"$$flag\"" >&2
        return 1
      end
    end
  end

  # Determine `--kind` if only `--name` was given
  if begin
      set --query _flag_name
      and not set --query _flag_kind
    end
    set kind
    set --local dirname "$name"
    if string match --regex --quiet -- "^.*/.*/\$" "$dirname"
      set dirname (path dirname -- "$dirname")
    end
    for k in $kinds
      if test -d "$data_directory/$k-$dirname"
        set kind "$k-"
        break
      end
    end
    if not set --query kind[1]
      echo "get-data-directory: kind could not be determined for dirname" \
        "`*-$dirname`" >&2
        return 1
    end
  end

  path normalize -- "$data_directory/$kind$name$argv[1]"
  return 0
end
