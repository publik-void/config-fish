function l --wraps=ls
  set -- opts -l -h -A -F
  set -- args
  set -- opts_end_reached false
  if test -t 1
    set --append -- opts --color=always
  end
  for arg in $argv
    if not $opts_end_reached && string match --quiet -- "-*" "$arg"
      if [ "$arg" = "--" ]
        set -- opts_end_reached true
      else
        set --append -- opts "$arg"
      end
    else
      set --append -- args (path normalize -- "$arg")
    end
  end
  if [ (count $args) = 1 ]
    if not string match --quiet -- "*/" "$args[1]"
      set --prepend -- opts -d
    end
  end
  ls $opts -- $args | string match --regex --invert -- "^total .*[^:]\$"
end

