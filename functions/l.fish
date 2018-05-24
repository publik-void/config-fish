# This file was created by me (incredigital) and inspired by Homebrew's /usr/local/Cellar/fish/2.7.1/share/fish/functions/la.fish

function l --description "Custom ls variant by me (incredigital)"
  set opts -l -h -A
  switch (uname)
    case FreeBSD
    case '*'
      set opts $opts -o 
  end
  ls $opts $argv
end

