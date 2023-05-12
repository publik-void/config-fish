function seq0 --description \
  "helper function to avoid inconsistencies with `seq 0`"
  if [ (count $argv) != 1 ]
    echo "seq0 expects exactly one argument (last)" >&2
    return 1
  end

  if [ "$argv[1]" -gt "0" ]
    seq "$argv[1]"
  end
end

