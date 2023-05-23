function complete-data-directory
  set --local data_directory (get-data-directory 2> /dev/null)
  or return $status

  set --local argv
  set --local tokens (commandline --current-process --tokenize)
  set --local ends_on_slash false
  set --local kind
  set --local name
  if set --query tokens[1]
    [ (string sub --start -1 -- "$tokens[-1]") = "/" ]
    and set ends_on_slash true

    if begin; [ "$tokens[1]" = "cw" ]; or [ "$tokens[1]" = "cr" ]; end
      if [ "$tokens[1]" = "cw" ]; set kind "work-"; else; set kind "repo-"; end
      set tokens $tokens[2..-1]
      if set --query tokens[1]
        set name "$tokens[1]"
        set tokens $tokens[2..-1]
      else
        set name ""
      end
    else if [ "$tokens[1]" = "get-data-directory" ]
      set tokens $tokens[2..-1]
      argparse --max-args=1 "k/kind" "n/name" -- $tokens 2> /dev/null
      or return $status
      set tokens $argv
      # There would be nicer ways to do this, like a subrountine in
      # `get-data-directory` to match the kind which is accessible from outside…
      set kind "$_flag_kind"
      set name "$_flag_name"
    end
  end

  set --local opts
  set --query kind[1]; and set --append opts "--kind=$kind"
  set --query name[1]; and set --append opts "--name=$name"
  set --local directory (get-data-directory \
    "--data-directory=$data_directory" $opts $tokens 2> /dev/null)
  or return $status

  # Note: This depends on `get-data-directory` always outputting a normalize
  # path, otherwise an extra `path normalize` would be needed on both
  # `data_directory` and `directory` here.

  # If the directory that's entered in the command so far is the data directory
  # or one of its subfolders, append a slash to do completion of subfolders
  # Also, keep a slash if it was present in the token
  test -d "$directory"
  and begin
    $ends_on_slash
    or [ (path dirname -- "$directory") = "$data_directory" ]
    or [ "$directory" = "$data_directory" ]
  end
  #and not string match --regex --quiet -- ".*/\$" "$directory"
  and set directory "$directory/"

  set --local candidates (__fish_complete_path "$directory")

  set --local prefix
  if set --query tokens[1]
    # Complete from arg
    #set prefix "$directory"
    set prefix (path basename -- "$directory")
  else if set --query name[1]
    # Complete from name
    set --local full_kind "work-"
    string match --regex -- "^r.*" "$kind"; and set full_kind "repo-"
    #set prefix "$data_directory/$full_kind$name"
    set prefix "$data_directory/$full_kind"
  else if set --query kind[1]
    # Complete from kind
    #set prefix "$data_directory/$kind"
    set prefix "$data_directory/"
  else
    # Complete from data directory
    set prefix "$data_directory/"
  end

  set regex (string escape --style="regex" -- "$prefix")
  set regex "^$regex(.*)"
  string match --regex --groups-only -- "$regex" $candidates
end

