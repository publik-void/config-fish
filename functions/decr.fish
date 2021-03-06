# Requires Botan, OpenSSL, GNU Parallel
# And optionally lz4
function decr --description "Custom file decryption script"

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
    appear to be GNU. This is likely not a problem, though.
  end

  # Try to use LibreSSL if possible.
  # Prefer paths where a newer SSL version is more likely.
  # I should look into a way of incorporating the encryption algorithm and the
  # key hashing mechanism into the file name or so. I might also want to
  # consider expanding the options to this script accordingly…
  set --global ssl_command openssl
  if test -e /usr/local/opt/libressl/bin/openssl
    set ssl_command /usr/local/opt/libressl/bin/openssl
  else if type -q libressl
    set ssl_command libressl
  else if test -e /usr/local/bin/openssl
    set ssl_command /usr/local/bin/openssl
  end
  switch $argv[1]
    case "-c=*"
      set ssl_command (string sub --start 5 0$argv[1])
      set argv $argv[2..-1]
  end
  if not type -q $ssl_command
    echo Required command \"openssl\" could not be found. Exiting.
    return
  else
    echo Using (eval $ssl_command version)
  end

  set --erase queued_files
  set input_files (string trim $argv --right --chars '/')
  set hash_file ~/.config/fish/password-hashes/default.hash
  set salt_file ~/.config/fish/password-hashes/default.salt

  for i in $input_files
    set --local filetype ""
    switch $i
      case "*.tar.enc"
        set filetype ".tar.enc"
      case "*.tar.lz4.enc"
        set filetype ".tar.lz4.enc"
      case "*.tar.xz.enc"
        set filetype ".tar.xz.enc"
    end

    if not test -e $i
      echo \"{$i}\" does not exist.
    else if test -d $i
      echo \"{$i}\" is a directory.
    else if test $filetype = ""
      echo \"{$i}\" does not have the required filename extension.
    else if test $filetype = ".tar.lz4.enc"; and not type -q lz4
      echo Required command \"lz4\" could not be found in order \
      to extract \"{$i}\".
    else if test $filetype = ".tar.xz.enc"; and not type -q xz
      echo Required command \"xz\" could not be found in order \
      to extract \"{$i}\".
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

  echo -n "Validating password..."
  botan check_bcrypt (string join "" $salt $password) $hash |\
    read --local validation
  set --local return_status $status
  if test $return_status -eq 0
    echo " Done."
  else
    echo A problem occured while validating the password. Exiting.
    return $return_status
  end

  if not test $validation = "Password is valid"
    echo "Password is not valid. Exiting."
    return
  end

  # Serial execution
  #for i in $queued_files
  #  openssl aes-192-ctr -d -pass env:password -in $i |\
  #    tar -C (dirname $i) -xf -
  #end

  # Parallel execution
  #for i in $queued_files
  #  openssl aes-192-ctr -d -pass env:password -in $i |\
  #    tar -C (dirname $i) -xf - &
  #end

  # Parallel execution using GNU parallel
  set --erase jobs
  for i in $queued_files
    set --local extraction_pipe ""
    switch $i
      case "*.tar.lz4.enc"
        set extraction_pipe " | lz4 -d"
      case "*.tar.xz.enc"
        set extraction_pipe " | xz -d"
    end

    set --local dirname (dirname $i)
    set jobs $jobs "$ssl_command aes-128-ctr -d -pass env:password -in \"$i\"\
      $extraction_pipe | tar -C \"$dirname\" -xf -"
  end
  parallel ::: $jobs

  set password 00000000000000000000000000000000
  set --erase password
end

