function configured-git-prompt --wraps fish_git_prompt
  # if not set -q __fish_git_prompt_show_informative_status
  #     set -g __fish_git_prompt_show_informative_status 1
  # end
  # if not set -q __fish_git_prompt_hide_untrackedfiles
  #     set -g __fish_git_prompt_hide_untrackedfiles 1
  # end

  # if not set -q __fish_git_prompt_color_branch
  #     set -g __fish_git_prompt_color_branch magenta --bold
  # end
  # if not set -q __fish_git_prompt_showupstream
  #     set -g __fish_git_prompt_showupstream "informative"
  # end
  # if not set -q __fish_git_prompt_char_upstream_ahead
  #     set -g __fish_git_prompt_char_upstream_ahead "↑"
  # end
  # if not set -q __fish_git_prompt_char_upstream_behind
  #     set -g __fish_git_prompt_char_upstream_behind "↓"
  # end
  # if not set -q __fish_git_prompt_char_upstream_prefix
  #     set -g __fish_git_prompt_char_upstream_prefix ""
  # end

  # if not set -q __fish_git_prompt_char_stagedstate
  #     set -g __fish_git_prompt_char_stagedstate "●"
  # end
  # if not set -q __fish_git_prompt_char_dirtystate
  #     set -g __fish_git_prompt_char_dirtystate "✚"
  # end
  # if not set -q __fish_git_prompt_char_untrackedfiles
  #     set -g __fish_git_prompt_char_untrackedfiles "…"
  # end
  # if not set -q __fish_git_prompt_char_conflictedstate
  #     set -g __fish_git_prompt_char_conflictedstate "✖"
  # end
  # if not set -q __fish_git_prompt_char_cleanstate
  #     set -g __fish_git_prompt_char_cleanstate "✔"
  # end

  # if not set -q __fish_git_prompt_color_dirtystate
  #     set -g __fish_git_prompt_color_dirtystate blue
  # end
  # if not set -q __fish_git_prompt_color_stagedstate
  #     set -g __fish_git_prompt_color_stagedstate yellow
  # end
  # if not set -q __fish_git_prompt_color_invalidstate
  #     set -g __fish_git_prompt_color_invalidstate red
  # end
  # if not set -q __fish_git_prompt_color_untrackedfiles
  #     set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal
  # end
  # if not set -q __fish_git_prompt_color_cleanstate
  #     set -g __fish_git_prompt_color_cleanstate green --bold
  # end

  # set str (fish_git_prompt $argv)

  # It's ridiculous, but this is actually faster than `fish_git_prompt`
  # TODO: Set the interpreter (bash or zsh) at startup
  # TODO: Set the variables to customize the output and also do trimming in bash
  set git_prompt_sh "$__fish_config_dir/aux/git-prompt.sh"
  if test -f "$git_prompt_sh"
    set str (bash -c "source \"$git_prompt_sh\"; __git_ps1")
  else
    return
  end

  # string sub --start 2 --end -1 -- (string trim -- "$str")
  # The above rewritten for compatibility:
  set output (string trim -- "$str")
  set length (string length -- "$output")
  if [ $length -gt 2 ]
    string sub --start 2 --length (math --scale=0 "$length - 2") -- "$output"
  end
  echo " "
end

