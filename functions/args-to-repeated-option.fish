function args-to-repeated-option --description "Convert arguments to a list of \
  <option>=arg_i – custom-made because I couldn't find this as existing \
  functionality shipped with fish or unix shell"

  if [ (count $argv) = 0 ]
    return 1
  end

  set --local option $argv[1]
  set argv $argv[2..-1]
  for arg in $argv
    echo $option=$arg
  end
  return 0
end

