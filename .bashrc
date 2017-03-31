source ~/perl5/perlbrew/etc/bashrc
export PATH="$HOME/.gem/ruby/2.0.0/bin:$PATH"

export GOPATH="/usr/local/bin/go"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"

alias ll='ls -laG'
alias mysql="mysql --pager='less -S -n -i -F'"
alias lodge_start_dev="cd ~/Documents/lodge/; bin/rake sunspot:solr:start RAILS_ENV=development; bundle exec unicorn -c config/unicorn.rb -E development"
