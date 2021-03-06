#! /bin/sh

set -e
set -u
set -x

browser=chromium
editor=subl
filemanager=pcmanfm

guesscwdwithmagic () {
	cwd=$HOME

	wintitle=$(xdotool getactivewindow getwindowname)
	case $wintitle in
		nixos:*:*)
			cwd=`echo $wintitle | cut -d : -f 3-`
		;;
		*Sublime\ Text)
			cwd=`echo $wintitle | cut -d ' ' -f 1`
			cwd=`dirname $cwd`
		;;
	esac

	case $cwd in
		~*)
			cwd=$HOME/$(echo $cwd | cut -c 2-)
		;;
	esac

	echo $cwd
}

cwd=$(guesscwdwithmagic)

manualexpand () {
	# hack to expand from string without eval
	case $1 in
		/*)
			echo $1
		;;
		~*)
			echo $HOME/$(echo $1 | cut -c 2-)
		;;
		*)
			echo $cwd/$1
		;;
	esac	
}

cwd=$(manualexpand $cwd)
text=$(xclip -o | head -n 1)

case $text in
	http://* | https://*)
		exec $browser $text
	;;
esac

if echo $text  | grep -q -E '^[a-zA-Z/~ \.]+(:[0-9]*)*:?'
then
	fwithpos=$(manualexpand $text)

	# strip trailing :, go error messages are one place this happens
	case $(echo $fwithpos | rev) in
		:*)
			fwithpos=$(echo $fwithpos | rev | cut -c 2- | rev)
		;;
	esac

	fnopos=$fwithpos
	if echo $fwithpos | grep -q -E ':'
	then
		fnopos=`echo $f | cut -d : -f 1`
	fi

	if test -f $fnopos
	then
		case $fnopos in
			*)
				exec $editor $fwithpos
			;;
		esac
	fi

	if test -d $fnopos
	then
		cd $fnopos
		exec $filemanager 
	fi
fi
