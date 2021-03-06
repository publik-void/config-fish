function aif-to-ogg --description "custom ad-hoc audio file conversion"
  switch (basename (pwd))
  case 'aif' 'wav'
    if not test -d ../ogg
      mkdir ../ogg
    end
    for i in *.aif
        avconv -i $i -c:a libvorbis -q:a 10\
          ../ogg/(string split --max 1 --right "." $i)[1].ogg &
    end
    for i in *.wav
        avconv -i $i -c:a libvorbis -q:a 10\
          ../ogg/(string split --max 1 --right "." $i)[1].ogg &
    end
    wait
  case '*'
    echo "Seems like you forgot to provide the required directory structure."
  end
end

