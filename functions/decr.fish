function decr --description "Custom file decryption script"
  
  if not type -q botan
    echo Required command \"botan\" could not be found. Exiting.
    return
  end
  
  set --erase jobs
  set files (string trim $argv --right --chars '/')
  set hash_file ~/.config/fish/password-hashes/default
  
  for i in $files
    if not test -e $i
  		echo \"{$i}\" does not exist.
    else if test -d $i
      echo \"{$i}\" is a directory.
  	else if not string match ".tar.enc" (string sub --start -8 $i)\
      > /dev/null
  		echo \"{$i}\" does not have the required extension \".tar.enc\". 
  	else
  		set --local extracted\
      (string sub --length (math (string length $i) - 8) $i)
      if test -e $extracted
        echo \"$extracted\" already exists. Overwrite\? [Y/n]
        read --prompt="set_color green; echo -n '> '; set_color normal;"\
          --local overwrite
        switch $overwrite
        case 'n*' 'N*' 
          echo As requested, \"$i\" will not be unarchived.
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
    return
  end
  
  if not test -e $hash_file
    echo Password hash file \"{$hash_file}\" missing. Exiting.
    return
  end
  
  cat $hash_file | read --local hash 
  
  read --local --export --silent --prompt-str="Password:" password
  
  echo -n "Validating password... "
  botan check_bcrypt $password $hash | read --local validation
  set --local return_status $status
  if test $return_status -eq 0
    echo Done.
  else
    echo A problem occured while validating the password. Exiting.
    return $return_status
  end
  
  if not string match $validation "Password is valid" > /dev/null
    echo Password is not valid. Exiting.
    return
  end
  
  # Serial execution
  for i in $jobs
    openssl aes-192-ctr -d -pass env:password -in $i | tar -x
  end
  
  # Parallel execution
  #for i in $jobs
  #  openssl aes-192-ctr -d -pass env:password -in $i | tar -x &
  #end
  
  set password 00000000000000000000000000000000
  set --erase password
end
  
