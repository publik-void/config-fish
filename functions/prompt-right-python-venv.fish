function prompt-right-python-venv
  if set --query VIRTUAL_ENV
    echo "$(set_color white)$VIRTUAL_ENV$(set_color normal) "
  end
end

