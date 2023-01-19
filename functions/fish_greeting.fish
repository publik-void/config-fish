function fish_greeting
  argparse "a/all" "u/user" "f/fish-path" "t/terminal" "d/datetime" \
    "p/previous-prompt" "c/previous-command" "n/newlines" "l/labels" -- $argv
  if [ $status != 0 ]; return 1; end

  set --function label_color normal
  set --function item_color yellow
  set --function separator_color green
  set --function separator " | "

  if set --query _flag_all
    if set --query _flag_user; set --erase _flag_user;
    else; set --function _flag_user --user; end
    if set --query _flag_fish_path; set --erase _flag_fish_path;
    else; set --function _flag_fish_path --fish-path; end
    if set --query _flag_terminal; set --erase _flag_terminal;
    else; set --function _flag_terminal --terminal; end
    if set --query _flag_datetime; set --erase _flag_datetime;
    else; set --function _flag_datetime --datetime; end
    if set --query _flag_previous_prompt; set --erase _flag_previous_prompt;
    else; set --function _flag_previous_prompt --previous-prompt; end
    if set --query _flag_previous_command; set --erase _flag_previous_command;
    else; set --function _flag_previous_command --previous-command; end
  else
    if begin ! set --query _flag_user
        and ! set --query _flag_fish_path
        and ! set --query _flag_terminal
        and ! set --query _flag_datetime
        and ! set --query _flag_previous_prompt
        and ! set --query _flag_previous_command
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

  if set --query _flag_previous_prompt
    set --append labels "previous prompt"
    set --append items (show-date (prompt-time --number=2) --date --time)
    set --append colors $item_color
  end

  if set --query _flag_previous_command
    set --append labels "previous command"
    set --append items (show-date (command-time) --date --time)
    set --append colors $item_color
  end

  if set --query _flag_datetime
    set --append labels "datetime"
    set --append items (show-date --date --time)
    set --append colors $item_color
  end

  if set --query _flag_user
    set --append labels "user"
    set --append items (whoami)@(hostname)
    set --append colors $item_color
  end

  if set --query _flag_fish_path
    set --append labels "fish path"
    set --append items (status fish-path)
    set --append colors $item_color
  end

  if set --query _flag_terminal
    set --append labels "terminal"
    set --append items $TERM
    set --append colors $item_color
  end

  if set --query _flag_newlines
    set separator "\n"
  end

  set --local n (count $labels)
  if [ $n != (count $items) ]; return 2; end
  if [ $n != (count $colors) ]; return 3; end
  set --local is (seq 1 $n)
  if [ $n = 0 ]; set is; end

  if set --query _flag_labels
    for i in $is; set labels[$i] "$labels[$i]: "; end
  else
    for i in $is; set labels[$i] ""; end
  end

  for i in $is
    set_color $label_color
    printf $labels[$i]
    set_color $colors[$i]
    printf $items[$i]
    if [ $i != $n ]
      set_color $separator_color
      printf $separator
    else
      set_color normal
      if [ $n != 0 ]
        echo
      end
    end
  end
end

