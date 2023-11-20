function prompt-right-guix
  # For now, this is just a very basic indicator for being in a `guix shell`
  if set --query GUIX_ENVIRONMENT
    echo "guix "
  end
end
