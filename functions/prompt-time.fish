function prompt-time --description "Utility to record and output fish \
    prompt opening times in a global variable"
  set --local max_length 1024
  set --local shift_length 512

  argparse --ignore-unknown --exclusive="h,d" \
    "h/human-readable" "d/elapsed" -- $argv
  if [ $status != 0 ]; return 1; end
  if set --query _flag_human_readable
    set --local unix_times (prompt-time $argv)
    set --local return_value $status
    if [ $return_value != 0 ]; return $return_value; end
    if [ (count $unix_times) != 0 ]; show-date $unix_times; end
    return $status
  else if set --query _flag_elapsed
    argparse --ignore-unknown "toc=!_validate_int" -- $argv
    if [ $status != 0 ]; return 1; end
    if ! set --query _flag_toc; set _flag_toc (date "+%s"); end
    set --local tics (prompt-time $argv)
    set --local return_value $status
    if [ $return_value != 0 ]; return $return_value; end
    for tic in $tics; echo (math --scale=0 $_flag_toc - $tic); end
    return $return_value
  end

  argparse --ignore-unknown \
    "r/read" "w/write=?!_validate_int --min 0" -- $argv
  if [ $status != 0 ]; return 1; end

  if set --query _flag_write
    if [ (count $prompt_opening_time_buffer) -ge $max_length ]
      set --global prompt_opening_time_buffer \
        $prompt_opening_time_buffer[(math --scale=0 $max_length - \
        $shift_length + 1)..$max_length]
    end

    if [ (count $_flag_write) = 0 ]
      prompt-time $argv $_flag_read --write=(date "+%s")
      return $status
    end

    set --global --append prompt_opening_time_buffer $_flag_write
  end

  argparse --ignore-unknown "n/number=+!_validate_int --min 1" -- $argv
  if [ $status != 0 ]; return 1; end
  if begin ! set --query _flag_write
      and ! set --query _flag_read
      and ! set --query _flag_number
    end
    set _flag_number 1
  end
  if set --query _flag_number; set _flag_read "--read"; end

  set --local return_value 0
  if set --query _flag_read
    set --local output

    if set --query _flag_number
      set --local is $_flag_number
      #if [ (count $is) = 0 ]; set is 1; end

      for i in $is
        set --local _i (math --scale=0 -$i)
        if set --query prompt_opening_time_buffer[$_i]
          set --append output $prompt_opening_time_buffer[$_i]
        else
          set return_value 2
        end
      end
    else
      set output $prompt_opening_time_buffer[-1..1]
    end

    if begin [ (count $output) = 0 ]
        and set --query _flag_number
      end
      set return_value 2
    end
    for t in $output
      echo $t
    end
  end

  return $return_value
end

