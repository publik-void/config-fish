function l --wraps=ls
  set opts -l -h -A -F
  set args
  for arg in $argv
    if string match --quiet -- "-*" "$arg"
      set --append -- opts "$arg"
    else
      set --append -- args "$arg"
    end
  end
  if [ (count $args) = 1 ]
    if not string match --quiet -- "*/" "$args[1]"
      set --append -- opts -d
    end
  end
  ls $opts -- $args
end

