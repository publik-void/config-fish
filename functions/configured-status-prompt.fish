function configured-status-prompt
  if begin
      set --query argv[1]
      and [ $argv[1] != 0 ]
    end
    echo "$argv[1]$(set_color red)↵$(set_color normal) "
  end
end

