function l \
    --wraps "ls -lhAF"
  set opts -l -h -A -F
  ls $opts $argv
end

