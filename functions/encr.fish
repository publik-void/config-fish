# Requires Botan, OpenSSL, GNU Parallel
# And optionally lz4
function encr --description "Custom file encryption script"

  if not type -q botan
    echo Required command \"botan\" could not be found. Exiting.
    return
  end

  set --global tar_command gtar
  if not type -q $tar_command
    set --global tar_command tar
  end

  if not type -q $tar_command
    echo Required command \"tar\" or \"gtar\" could not be found. Exiting.
    return
  end

  if test $tar_command = tar; and test (uname) != Linux
    echo Caution: Using \"tar\" \(not \"gtar\"\) although this system does not\
    appear to be GNU.
  end

  set --global ssl_command openssl
  # Prefer paths where a newer openssl version is more likely.
  # LibreSSL and OpenSSL seem to be quite picky about which version is used.
  # This could present major issues for me in the future so I might want to
  # implement this in a better and more compatible way…
  if test -e /usr/local/opt/libressl/bin/openssl
    set ssl_command /usr/local/opt/libressl/bin/openssl
  else if test -e /usr/local/bin/openssl
    set ssl_command /usr/local/bin/openssl
  end
  if not type -q $ssl_command
    echo Required command \"openssl\" could not be found. Exiting.
    return
  else
    echo Using (eval $ssl_command version)
  end

  set --global compression none
  switch $argv[1]
    case "-z=*"
      set compression (string sub --start 5 0$argv[1])
      set argv $argv[2..-1]
    case "-z"
      # Default compression
      set compression lz4
      set argv $argv[2..-1]
  end

  set --global compression_level default
  if not test $compression = none
    switch $argv[1]
      case ""
      case "-l=*"
        set compression_level (string sub --start 5 0$argv[1])
        set argv $argv[2..-1]
    end
  end

  if not test $compression = none
    if not type -q $compression
      echo Required command \"$compression\" could not be found. Exiting.
      return
    end
  end

  set --global compression_pipe ""
  set --global compression_ext ""
  switch $compression
    case 'lz4'
      set compression_pipe " | lz4"
      set compression_ext ".lz4"
    case 'xz'
      set compression_pipe " | xz"
      set compression_ext ".xz"
    case '*'
  end
  if test compression_pipe != ""
    switch $compression_level
      case "default"
      case "*"
        set compression_pipe\
          (string join " -" $compression_pipe $compression_level)
    end
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
    set jobs $jobs "$tar_command -C \"$dirname\" -cf - \"$basename\"\
    $compression_pipe | $ssl_command aes-128-ctr -e -salt -pass env:password \
    -out \"$i.tar$compression_ext.enc\""
  end
  parallel ::: $jobs
  
  set password 00000000000000000000000000000000
  set --erase password
end

