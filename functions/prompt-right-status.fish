function prompt-right-status
  if begin
      set --query argv[1]
      and [ $argv[1] != 0 ]
    end
    echo "$(set_color red)$argv[1]$(set_color normal) "
  end
end

