function command-time --description "Utility to output fish command history
    times"

  argparse --ignore-unknown --exclusive="h,d" \
    "h/human-readable" "d/elapsed" -- $argv
  if [ $status != 0 ]; return 1; end
  if set --query _flag_human_readable
    set --local unix_times (command-time $argv)
    set --local return_value $status
    if [ $return_value != 0 ]; return $return_value; end
    if [ (count $unix_times) != 0 ]; show-date $unix_times; end
    return $status
  else if set --query _flag_elapsed
    argparse --ignore-unknown "toc=!_validate_int" -- $argv
    if [ $status != 0 ]; return 1; end
    if ! set --query _flag_toc; set --function _flag_toc (date "+%s"); end
    set --local tics (command-time $argv)
    set --local return_value $status
    if [ $return_value != 0 ]; return $return_value; end
    for tic in $tics; echo (math --scale=0 $_flag_toc - $tic); end
    return $return_value
  end

  argparse --ignore-unknown "r/read" "n/number=+!_validate_int --min 1" -- $argv
  if [ $status != 0 ]; return 1; end
  if begin ! set --query _flag_read
      and ! set --query _flag_number
    end
    set --function _flag_number 1
  end
  if set --query _flag_number; set --function _flag_read "--read"; end

  set --function return_value 0
  if set --query _flag_read
    argparse --ignore-unknown "override-tic=+!_validate_int" -- $argv
    if [ $status != 0 ]; return 1; end

    if ! set --query _flag_override_tic
      set --local max_option
      if set --query _flag_number
        set --local max_args (string join ", " $_flag_number)
        set --local max (math "max($max_args)")
        set max_option "--max=$max"
      end

      set --local bs 12
      set --local id (dd if=/dev/urandom bs=$bs count=1 status=none | base64)
      set --local id_esc \
        (echo $id | sed -n 's/\//\\\\\//g; s/+/\\\+/g; s/\=/\\\=/g; p')
      set --local output \
        (history --show-time="#$id %s%n" $max_option | sed -n "s/^\#$id_esc //p")
      if set --query _flag_number; set output $output[$_flag_number]; end

      if [ (count $output) = 0 ]
        if set --query _flag_number
          set return_value 2
        else
          set return_value 0
        end
      else
        command-time $argv $_flag_read \
          (args-to-repeated-option --number $_flag_number) \
          (args-to-repeated-option --override-tic $output)
        set return_value $status
      end
    else
      if begin set --query _flag_number
          and [ (count $_flag_number) != (count $_flag_override_tic) ]
        end
        set return_value 2
      end

      for tic in $_flag_override_tic; echo $tic; end
    end
  end

  return $return_value
end

