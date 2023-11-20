function prompt-right-git
  set --query argv[1] && cd "$argv[1]"

  set --local output "$(string trim -- "$(fish_git_prompt)")"

  # We could pass `--end -1` to `string sub`, but let's support older Fish's:
  set --local length (math --scale=0 "$(string length -- "$output") - 2")
  if [ "$length" -gt "0" ]
    echo "$(string sub --start 2 --length "$length" -- "$output") "
  end
end

