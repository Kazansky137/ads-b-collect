#! /bin/bash

# (c) Kazansky137 - Thu May 14 17:29:37 UTC 2020

  debug=0

  function usage()
  { echo $0 [-h] [-f] [-d] dated_file.txt{.gz}
    exit
  }

  while getopts "hfd" option; do
    case "${option}" in
        h)
            usage
            ;;
        f)
            force=1
            ;;
        d)
            debug=1
            ;;
        *)
            usage
            ;;
    esac
  done
  shift "$((OPTIND-1))"

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
  txtfile=txt-${BASH_REMATCH[2]}.txt 

if [ ! $force ]; then
	if [ -e $flgfile ]; then
  		echo $0: file $flgfile is already existing
  		exit 1
	fi

	if [ -e $runfile ]; then
	  	echo $0: file $runfile is already existing
 	 	exit 1
	fi

	if [ -e $txtfile ]; then
  		echo $0: file $txtfile is already existing
 	 	exit 1
	fi
fi

# Environment variable for nice justified colored output
  export TERM_COLS=$(tput cols)

  $source | (./discover.py --live=0 --debug=$debug | tee $txtfile | \
             ./flights-2-txt.py --live=0 --debug=$debug > $flgfile) 2> $runfile
  touch -r $in_file $flgfile $runfile $txtfile
  
exit
