# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin:/sbin:/usr/sbin
#ENV=$HOME/.bashrc
#USERNAME="root"

export PATH

export HISTSIZE=10000
export HISTFILESIZE=10000

mesg n

#alias vio='ssh -C -l god 194.239.248.147'

