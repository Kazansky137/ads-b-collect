#! /bin/bash

# (c) Kazansky137 - Wed Dec 18 17:04:03 CET 2019

  if [ $# -ne 1 ]; then
    echo Usage: $0 file.txt[.gz]
    exit 1
  fi

  in_file=$1

  if [ ! -r $in_file ]; then
    echo $0: file $in_file not readable
    exit 1
  fi

  echo Processing file $in_file

  in_name=$(basename $in_file)

  regname="^[[:alnum:]]+"
  regtime="[0-9]{6}-[0-9]{6}"

  if [[ $in_name =~ ($regname)-($regtime).txt$ ]]; then
    source="cat $in_file"
  elif [[ $in_name =~ ($regname)-($regtime).txt.gz$ ]]; then
    source="gzip -dcf $in_file"
  else
    echo $0: bad filename structure
    exit 1
  fi

# Various output files
  flgfile=flights-${BASH_REMATCH[2]}.txt
  runfile=log-${BASH_REMATCH[2]}.txt

  if [ -e $flgfile ]; then
    echo $0: file $flgfile is already existing
    exit 1
  fi

  if [ -e $runfile ]; then
    echo $0: file $runfile is already existing
    exit 1
  fi

# Environment variable for nice justified colored output
  export TERM_COLS=$(tput cols)

  $source | ./flights-2-txt.py > $flgfile 2> $runfile
  touch -r $in_file  $flgfile  $runfile
  
exit
