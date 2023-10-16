function fish_greeting
  set --local label_color normal
  set --local item_color yellow
  set --local failure_color red
  set --local failure_string "(failure)"
  set --local separator_color green
  set --local separator " | "

  set --local magazine_shorthands p c d u f t
  set --local magazine_labels \
    "previous prompt" \
    "previous command" \
    "datetime" \
    "user" \
    "fish path" \
    "terminal"
  set --local magazine_commands \
    "show-date (prompt-time --number=2) --date --time" \
    "show-date (command-time) --date --time" \
    "show-date --date --time" \
    "echo (whoami)@(hostname)" \
    "status fish-path" \
    "echo $TERM"

  set --local n (count $magazine_shorthands)
  set --local is (seq0 $n)

  set --local magazine_flags
  set --local magazine_longforms
  set --local magazine_args
  for i in $is
    set magazine_flags[$i] \
      (echo $magazine_labels[$i] | sed -e 's/ /_/g; s/^/_flag_/')
    set magazine_longforms[$i] \
      (echo $magazine_labels[$i] | sed -e 's/ /-/g')
    set magazine_args[$i] \
      "$magazine_shorthands[$i]/$magazine_longforms[$i]"
  end

  argparse "a/all" $magazine_args "n/newlines" "l/labels" -- $argv
  if [ $status != 0 ]; return 1; end

  if set --query _flag_all
    # Make magazine flags act as off-switches if `--all` is given
    for i in $is
      if set --query $magazine_flags[$i]
        set --erase $magazine_flags[$i]
      else
        set $magazine_flags[$i] "--$magazine_longforms[$i]"
      end
    end
  else
    # Run a certain default if no magazine flags are given
    set --query magazine_flags # Initialize loop with zero status
    if for i in $is
        and not set --query $magazine_flags[$i]
      end
      if [ (count (prompt-time --number 2)) != 0 ]
        fish_greeting $_flag_newlines --previous-prompt --previous-command \
          --labels
      end
      set _flag_user --user
      set _flag_fish_path --fish-path
      set _flag_terminal --terminal
      set _flag_datetime --datetime
    end
  end

  set --local labels
  set --local items
  set --local colors

  for i in $is
    if set --query $magazine_flags[$i]
      set --append labels $magazine_labels[$i]
      if set --local item (eval $magazine_commands[$i] 2> /dev/null)
        set --append items $item
        set --append colors $item_color
      else
        set --append items $failure_string
        set --append colors $failure_color
      end
    end
  end

  set --local m (count $labels)
  set --local js (seq0 $m)

  for j in $js
    if set --query _flag_labels
      set_color $label_color
      echo -n "$labels[$j]: "
    end

    set_color $colors[$j]
    echo -n "$items[$j]"

    if [ $j != $m ]
      if set --query _flag_newlines
        echo
      else
        set_color $separator_color
        echo -n "$separator"
      end
    end
  end

  if [ $m != 0 ]
    set_color normal
    echo
  end
end

