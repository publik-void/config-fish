function fish_greeting
  echo (whoami)@(hostname) "|" (status fish-path) "|" $TERM "|" (date "+%Y-%m-%d %H:%M")
end

