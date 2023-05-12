function fish_greeting
  set --function label_color normal
  set --function item_color yellow
  set --function failure_color red
  set --function failure_string "(failure)"
  set --function separator_color green
  set --function separator " | "

  set --function magazine_shorthands p c d u f t
  set --function magazine_labels \
    "previous prompt" \
    "previous command" \
    "datetime" \
    "user" \
    "fish path" \
    "terminal"
  set --function magazine_commands \
    "show-date (prompt-time --number=2) --date --time" \
    "show-date (command-time) --date --time" \
    "show-date --date --time" \
    "echo (whoami)@(hostname)" \
    "status fish-path" \
    "echo $TERM"

  set --function n (count $magazine_shorthands)
  set --function is (seq0 $n)

  for i in $is
    set --function magazine_flags[$i] \
      (echo $magazine_labels[$i] | sed -e 's/ /_/g; s/^/_flag_/')
    set --function magazine_longforms[$i] \
      (echo $magazine_labels[$i] | sed -e 's/ /-/g')
    set --function magazine_args[$i] \
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
        set --function $magazine_flags[$i] "--$magazine_longforms[$i]"
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
      set --function _flag_user --user
      set --function _flag_fish_path --fish-path
      set --function _flag_terminal --terminal
      set --function _flag_datetime --datetime
    end
  end

  set --function labels
  set --function items
  set --function colors

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

  set --function m (count $labels)
  set --function js (seq0 $m)

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

