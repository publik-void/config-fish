# This file was mostly copied from https://github.com/ranger/ranger/wiki/Integration-with-other-programs#changing-directories

function ranger --description "Stay in the directory when quitting ranger"
  set tempfile (mktemp -t tmp.XXXXXX)
  command ranger --choosedir=$tempfile $argv
  if test -s $tempfile
    set ranger_pwd (cat $tempfile)
    if test -n $ranger_pwd -a -d $ranger_pwd
      builtin cd -- $ranger_pwd
    end
  end

  command rm -f -- $tempfile
end
