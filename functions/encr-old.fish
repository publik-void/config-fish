# Requires Botan, OpenSSL, GNU Parallel and GNU Tar

function encr --description "Custom file encryption script"
  
  if not type -q botan
    echo Required command \"botan\" could not be found. Exiting.
    return
  end
  
  set --erase queued_files
  set input_files (string trim $argv --right --chars '/')
  set hash_file ~/.config/fish/password-hashes/default.hash
  set salt_file ~/.config/fish/password-hashes/default.salt
  
  for i in $input_files
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
          set queued_files $queued_files $i
        end
      else
        set queued_files $queued_files $i
      end
    end
  end
  
  if test -z "$queued_files"
    echo Nothing to be done. Exiting.
    return
  end
  
  if not test -e $hash_file
    echo Password hash file \"{$hash_file}\" missing. Exiting.
    return
  end
  
  if not test -e $salt_file
    echo Password salt file \"{$salt_file}\" missing. Exiting.
    return
  end
  
  cat $hash_file | read --local hash 
  cat $salt_file | read --local salt
  
  read --local --export --silent --prompt-str="Password:" password
  
  echo -n "Validating password... "
  botan check_bcrypt (string join "" $salt $password) $hash |\
    read --local validation
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
  #for i in $queued_files
  #  tar -C (dirname $i) -cf - (basename $i) |\
  #    openssl aes-192-ctr -e -salt -pass env:password -out {$i}.tar.enc
  #end
  
  # Parallel execution
  #for i in $queued_files
  #  tar -C (dirname $i) -cf - (basename $i) |\
  #    openssl aes-192-ctr -e -salt -pass env:password -out {$i}.tar.enc &
  #end

  # Parallel execution using GNU parallel
  set --erase jobs
  for i in $queued_files
    set --local dirname (dirname $i)
    set --local basename (basename $i)
    set jobs $jobs "tar -C \"$dirname\" -cf - \"$basename\" |\
      openssl aes-192-ctr -e -salt -pass env:password -out \"$i.tar.enc\""
  end
  parallel ::: $jobs
  
  set password 00000000000000000000000000000000
  set --erase password
end

