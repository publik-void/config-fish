function encr --description "Custom file encryption script"
  
  if not type -q botan
    echo Required command \"botan\" could not be found. Exiting.
    exit
  end
  
  set --erase jobs
  set files (string trim $argv --right --chars '/')
  set hash_file ~/.config/fish/password-hashes/default
  
  for i in $files
    if not test -e $i
      echo \"{$i}\" does not exist.
    else
      if test -e {$i}.tar.enc
        echo \"{$i}.tar.enc\" already exists. Overwrite\? [Y/n]
        read --prompt="set_color green; echo -n '> '; set_color normal;"\
          --local overwrite
        switch $overwrite
        case 'n*' 'N*' 
          echo As requested, \"$i\" will not be archived.
        case '*'
          set jobs $jobs $i
        end
      else
        set jobs $jobs $i
      end
    end
  end
  
  if test -z "$jobs"
    echo Nothing to be done. Exiting.
    exit
  end
  
  if not test -e $hash_file
    echo Password hash file \"{$hash_file}\" missing. Exiting.
    exit
  end
  
  cat $hash_file | read --local hash 
  
  read --local --export --silent --prompt-str="Password:" password
  
  echo -n "Validating password... "
  botan check_bcrypt $password $hash | read --local validation
  set --local exit_status $status
  if test $exit_status -eq 0
    echo Done.
  else
    echo A problem occured while validating the password. Exiting.
    exit $exit_status
  end
  
  if not string match $validation "Password is valid" > /dev/null
    echo Password is not valid. Exiting.
    exit
  end
  
  # Serial execution
  #for i in $jobs
  #  tar -cf - $i |\
  #  openssl aes-192-ctr -e -salt -pass env:password -out {$i}.tar.enc
  #end
  
  # Parallel execution
  for i in $jobs
    tar -cf - $i |\
    openssl aes-192-ctr -e -salt -pass env:password -out {$i}.tar.enc &
  end
  
  set password 00000000000000000000000000000000
  set --erase password
end

