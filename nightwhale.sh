#!/bin/sh
if test -r /var/spool/anacron/cron.daily; then
    day=`cat /var/spool/anacron/cron.daily`
fi
if [ `date +%Y%m%d` = "$day" ]; then
    exit 0;
fi

# Do not run jobs when on battery power
if test -x /usr/bin/on_ac_power; then
    /usr/bin/on_ac_power >/dev/null 2>&1
    if test $? -eq 1; then
    exit 0
    fi
fi
/usr/sbin/anacron -s

# After cron completes: 

eval "$(ssh-agent -s)" # Start ssh-agent cache
chmod 600 .travis/id_rsa # Allow read access to the private key
ssh-add .travis/id_rsa # Add the private key to SSH

git config --global push.default matching
git remote add deploy ssh://git@$IP:$PORT$DEPLOY_DIR
git push deploy master --force # enforce for assurance

ssh apps@$IP -p $PORT <<EOF

[ ! -d "$XDG_DATA_HOME/bash" ] && mkdir -p "$XDG_DATA_HOME/bash"

load_bash_completions() {
  for f in $@
  do
    source $f
  done
}

brew_prefix=$(brew --prefix)

[ -f "$brew_prefix/etc/bash_completion" ] && . "$brew_prefix/etc/bash_completion"
[[ -f "$XDG_LIB_HOME/bash/gpip.sh" ]] && . "$XDG_LIB_HOME/bash/gpip.sh"
[[ -f "$XDG_LIB_HOME/bash/ln_yadm_encrypt.sh" ]] && . "$XDG_LIB_HOME/bash/ln_yadm_encrypt.sh"

which pip >/dev/null 2>&1 && eval "$(pip completion --bash)"
which pyenv >/dev/null && eval "$(pyenv init -)"
which rbenv >/dev/null && eval "$(rbenv init -)"
which nodenv >/dev/null && eval "$(nodenv init -)"
which swiftenv >/dev/null && eval "$(swiftenv init -)"

which virtualenvwrapper.sh >/dev/null && {
  export WORKON_HOME=$XDG_DATA_HOME/virtualenvs
  . virtualenvwrapper.sh
}
export PIP_REQUIRE_VIRTUALENV=true

PS1='\[\e[35m\]\h\[\e[00m\]:\[\e[1;36m\]\W\[\e[00m\] \u\[\e[1;32m\]$(__git_ps1)\[\e[00m\] \[\e[4;33m\]\t\[\e[00m\]\n\$ '


[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

eval "$(direnv hook bash)"
