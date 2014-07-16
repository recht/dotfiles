# .bashrc

if [ -z $BASHRCLOADED ]; then
    export BASHRCLOADED=1
    
    # Source global definitions
    if [ -f /etc/bashrc ]; then
    	. /etc/bashrc
    fi
fi
if [ -f ~/.bash_local ]; then
    . ~/.bash_local
fi

shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dotglob
shopt -s extglob



#-----------------------
# Greeting, motd etc...
#-----------------------

# Define some colors first:
red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m'		# No Color


#---------------
# Shell prompt
#---------------

case $MC_CONTROL_FILE in
    /tmp*)
        TITLEBAR=''
        ;;
    *)
	case $TERM in
	    xterm*)
		TITLEBAR='\[\033]0;\u@\h: \w\007\]'
		;;
	    *)
		TITLEBAR=''
		;;
	esac
	;;
esac

if [ "$GET_PS1" = "" ] ; then
    COLOUR=44
    ESC=
	case $TERM in
		xterm | dtterm | rxvt | xterm-* | mlterm )
			PS1="${TITLEBAR}\[\033[40;37;1m\]\u@\H: \[\033[37;40;0m\]\w\$(__git_ps1 \" [%s]\")> "
			PS2="> "
			;;
		linux)
			PS1="${TITLEBAR}\[\033[40;37;1m\]u@\H: \[\033[37;40;0m\]\w\$(__git_ps1 \" [%s]\") > "
			PS2="> "
			;;
		*)
			PS1="\u@\H: \w > "
			PS2="> "
			;;
	esac
	export PS1
	export PS2
fi


# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls --color=auto'
alias dir='ls -lA --color=auto'
alias path='echo -e ${PATH//:/\\n}'
alias which='type -a'
alias du='du -h'
alias df='df -kh'
alias x='startx >~/X.log 2>&1'
alias j='rm -f *.class && jikes Gui.java && java Gui'
alias pico='nano -w'
alias nano='nano -w'
alias sock='export LD_PRELOAD="$LD_PRELOAD /usr/lib/libtsocks.so"'

alias more='less'

export PAGER=less
export LESS='-i  -e -M -X -F -R -P%t?f%f \
:stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'


# Need for a xterm & co if we don't make a -ls                                  
[ -n $DISPLAY ] && {                                                            
    [ -f /etc/profile.d/color_ls.sh ] && source /etc/profile.d/color_ls.sh  
#         export XAUTHORITY=$HOME/.Xauthority                                    
}                                                                               

# Xterm title				 		 

function xtitle () 
{ 
    case $TERM in
	xterm* | dtterm | rxvt) 
	    echo -n -e "\033]0;$USER@$HOSTNAME: $*\007" ;;
	*)  ;;
    esac
}

alias top='xtitle Processes on $HOSTNAME && top'
alias make='xtitle Making $(basename $PWD) ; make'


function man ()
{
    xtitle The $(basename $1|tr -d .[:digit:]) manual
    /usr/bin/man -a "$*"
}


# Process/system related functions:

alias my_ps='ps -u "$USER" -o user,pid,ppid,pcpu,pmem,args'
function pp() { my_ps | nawk '!/nawk/ && $0~pat' pat=${1:-".*"} ; }
function killps()	# Kill process by name
{			# works with gawk too
    local pid pname sig="-TERM" # default signal
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then 
	echo "Usage: killps [-SIGNAL] pattern"
	return;
    fi
    if [ $# = 2 ]; then sig=$1 ; fi
    for pid in $(my_ps | nawk '!/nawk/ && $0~pat { print $2 }' pat=${!#}) ; do
	pname=$(my_ps | nawk '$2~var { print $6 }' var=$pid )
	if ask "Kill process $pid <$pname> with signal $sig ? "
	    then kill $sig $pid
	fi
    done
}

function ii()   # get current host related info
{
    echo -e "\nYou are logged on ${RED}$HOST"
    echo -e "\nAdditionnal information:$NC " ; uname -a
    echo -e "\n${RED}IP Address :$NC" ; ypmatch $HOSTNAME hosts
	if [ -f /usr/ucb/users ]
	then
		echo -e "\n${RED}Users logged on:$NC " ; /usr/ucb/users
	fi
    echo -e "\n${RED}Current date :$NC " ; date
    echo -e "\n${RED}Machine stats :$NC " ; uptime
    echo -e "\n${RED}Memory stats :$NC " ; vmstat
    echo -e "\n${RED}NIS Server :$NC " ; ypwhich
    echo
}
function corename()   # get name of app that created core
{
    local file name;
    file=${1:-"core"}
    set -- $(adb $file < /dev/null 2>&1 | sed 1q)
    name=${7#??}
    echo $file: ${name%??}
}


# Autocompletions
complete -A hostname   rsh rcp telnet rlogin r ftp ping disk ncftp
complete -A command    nohup exec eval trace truss strace sotruss gdb
complete -A command    command type which 
complete -A export     printenv
complete -A variable   export local readonly unset
complete -A enabled    builtin
complete -A alias      alias unalias
complete -A function   function
complete -A user       su mail finger

complete -A helptopic  help
complete -A shopt      shopt
complete -A stopped -P '%' bg
complete -A job -P '%'     fg jobs disown

complete -A directory  mkdir rmdir
complete -A directory  cd

# commands
complete -o dirnames -f -X '*.gz'   gzip
complete -o dirnames -f -X '!*.ps?(.gz)'  gs ghostview gv
complete -o dirnames -f -X '!*.dvi?(.gz)' xdvi
complete -o dirnames -f -X '!*.pdf' acroread xpdf
complete -o dirnames -f -X '!*.+(gif|jpg|jpeg|GIF|JPG|bmp)' xv gimp qiv
complete -o dirnames -f -X '!*.+(mpg|MPG|mpeg|MPEG|avi|AVI|asf|ASF)' mplayer
complete -o dirnames -f -X '!*.tex' latex
complete -o dirnames -f -X '!*.java' jikes javac
complete -o dirnames -f -X '!*.rar' unrar

#complete -A directory gzip gs ghostview gv acroread xv gimp latex qiv mplayer jikes javac

#complete -f -X '!*.class' -C 'ls $2*.class|sed s/\.class//' java

_java_classes ()
{
	echo $(ls $2*.class|sed s/\.class//)
	COMPREPLY=( $(ls $2*.class | sed "s/\.class//") )
}

_make_targets ()
{
    local mdef makef gcmd cur prev i

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
	-*f)	COMPREPLY=( $(compgen -f $cur ) ); return 0;;
    esac

    case "$cur" in
	-)	COMPREPLY=(-e -f -i -k -n -p -q -r -S -s -t); return 0;;
    esac

    if [ -f makefile ]; then
	mdef=makefile
    elif [ -f Makefile ]; then
	mdef=Makefile
    else
	mdef=*.mk
    fi

    for (( i=0; i < ${#COMP_WORDS[@]}; i++ )); do
	if [[ ${COMP_WORDS[i]} == -*f ]]; then
	    eval makef=${COMP_WORDS[i+1]}	
	    break
	fi
    done

	[ -z "$makef" ] && makef=$mdef

    if [ -n "$2" ]; then gcmd='grep "^$2"' ; else gcmd=cat ; fi

    COMPREPLY=( $(cat $makef 2>/dev/null | awk 'BEGIN {FS=":"} /^[^.# 	][^=]*:/ {print $1}' | tr -s ' ' '\012' | sort -u | eval $gcmd ) )
}

complete -F _make_targets -X '+($*|*.[cho])' make gmake pmake

_configure_func ()
{
    case "$2" in
	-*)	;;
	*)	return ;;
    esac

    case "$1" in
	\~*)	eval cmd=$1 ;;
	*)	cmd="$1" ;;
    esac

    COMPREPLY=( $("$cmd" --help | awk '{if ($1 ~ /--.*/) print $1}' | grep ^"$2" | sort -u) )
}

complete -F _configure_func configure

_killps ()
{
    local cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    COMPREPLY=( $( ps -u $USER -o comm  | \
	sed -e '1,1d' -e 's#[]\[]##g' -e 's#^.*/##'| \
	awk '{if ($0 ~ /^'$cur'/) print $0}' ))

    return 0
}
complete -F _killps killps


_list_mans() {
    local cmd="$1" cur="$2"
    local prev

    case "$3" in 
        ?) prev="$3";;
        *) prev="";;
    esac

    COMPREPLY=(\
        $(/bin/ls {/usr/man,/usr/share/man,/usr/X11R6/man,/usr/local/man}/man$prev* 2>/dev/null |\
            perl -ne 'if (s/^('"$2"'.*?)(?:\.[^.]+(?:\.gz)?)$/$1/) { print }' |\
                grep -Ev ':$' ) \
            )
}

complete -F _list_mans man




# no core files
ulimit -c 0


export HISTCONTROL=ignoredups
export HISTSIZE=10000
export HISTFILESIZE=10000

set ignoreeof

export LESSCHARSET=latin1
#export LC_CTYPE=iso_8859_15

export CHARSET=ISO-8859-1
