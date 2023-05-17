function cdr
  set --function dir \
    (get-data-directory --kind=r --name="$argv[1]" $argv[2..-1])
  or return $status
  cd "$dir"
  return $status
end

