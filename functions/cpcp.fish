for file in "$HOME/.config/cross-platform-copy-paste/cpcp.sh"
  type -q cpcp; and break
  test -x "$file"; and eval "function cpcp; $file \$argv; end"
end

