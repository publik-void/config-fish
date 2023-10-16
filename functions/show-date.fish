function show-date --description "Function to format unix times to my liking, \
    platform-independently and useable in other functions"

  argparse "d/date" "t/time" "s/seconds" "z/timezone" \
    "S/sep=" "D/date-sep=" "T/time-sep=" "Z/timezone-sep=" \
    "a/all-sep=" "y/short-year" \
    -- $argv
  if [ $status != 0 ]; return 1; end

  if begin not set --query _flag_date
      and not set --query _flag_time
      and not set --query _flag_seconds
    end
    set _flag_date --date
    set _flag_time --time
    set _flag_seconds --seconds
  end

  if set --query _flag_seconds; set _flag_time --time; end

  set --local default_sep " "
  set --local default_date_sep "-"
  set --local default_time_sep ":"

  if set --query _flag_all_sep
    set default_sep $_flag_all_sep
    set default_date_sep $_flag_all_sep
    set default_time_sep $_flag_all_sep
  end

  if not set --query _flag_sep
    set _flag_sep $default_sep
  end
  if not set --query _flag_date_sep
    set _flag_date_sep $default_date_sep
  end
  if not set --query _flag_time_sep
    set _flag_time_sep $default_time_sep
  end

  set --local default_timezone_sep $_flag_time_sep
  if not set --query _flag_timezone_sep
    set _flag_timezone_sep $default_timezone_sep
  end

  set --local format "+"
  if set --query _flag_date
    if set --query _flag_short_year
      set --append format "%y"
    else
      set --append format "%Y"
    end
    set --append format $_flag_date_sep "%m" $_flag_date_sep "%d"
  end
  if begin set --query _flag_date
      and set --query _flag_time
    end
    set --append format $_flag_sep
  end
  if set --query _flag_time
    set --append format "%H" $_flag_time_sep "%M"
    if set --query _flag_seconds
      set --append format $_flag_time_sep "%S"
    end
  end
  set format (string join "" $format)

  set --local timezone
  if set --query _flag_timezone
    set --local tz (date "+%z")
    set timezone (string join "" \
      (string sub --length=3 $tz) \
      $_flag_timezone_sep \
      (string sub --start=4 $tz))
  end

  set --local directive
  set --local platform (uname)
  if [ $platform = Darwin ]
    set directive "-r "
  else if [ $platform = Linux ]
    set directive "-d @"
  else
    echo "(platform $platform not supported)" >&2
    return 2
  end

  if [ (count $argv) = 0 ]; set argv (date "+%s"); end

  for unix_time in $argv
    set --local time (eval "date $directive$unix_time \"$format\"")
    echo "$time$timezone"
  end
end

