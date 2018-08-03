function create-password-hash --description "Custom password registration for later password validation"
  
  if test -z "$argv[1]"
    set hashes_path ~/.config/fish/password-hashes/
  else
    set hashes_path\
    (string join (string trim '' {$argv[1]} --right --chars '/') '/')
  end
  
  if not test -d $hashes_path
    echo Path \"{$hashes_path}\" is invalid.
    exit
  end
  
  echo Please enter the name of the hash file: [default]
  read --prompt="set_color green; echo -n '> '; set_color normal;"\
    --local filename
  if test -z "$filename"
    set filename default
  end
  if test -e {$hashes_path}{$filename}
    echo \"{$filename}\" already exists. Overwrite\? [y/N]
    read --prompt="set_color green; echo -n '> '; set_color normal;"\
          --local overwrite
    switch $overwrite
    case 'y*' 'Y*' 
      echo OK, hash file \"{$hashes_path}{$filename}\" will be overwritten.
    case '*'
      exit
    end
  end
  
  read --local --export --silent --prompt-str="Password:" password0
  read --local --export --silent --prompt-str="Repeat:" password1
  
  set --local exit_status -1
  
  if not string match $password0 $password1 > /dev/null
    echo Passwords do not match. Exiting.
  else
    echo -n "Computing hash... "
    botan gen_bcrypt --work-factor=14 $password0 > {$hashes_path}{$filename}
    set exit_status $status
    if test $exit_status -eq 0
      echo Done.
    end
  end
  
  set password0 00000000000000000000000000000000
  set password1 00000000000000000000000000000000
  set --erase password0
  set --erase password1
  exit $exit_status
end

