alias update='apk update && apk upgrade'
export HISTTIMEFORMAT="%d/%m/%y %T "
export PS1='\u@\h:\W \$ '
export TIME_STYLE='+%Y/%m/%d %H:%M:%S'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'

if [ -f /etc/profile.d/bash_completion.sh ]; then
  . /etc/profile.d/bash_completion.sh
fi

if [ -f /etc/profile.d/ansible-completion.bash ]; then
  . /etc/profile.d/ansible-completion.bash
fi