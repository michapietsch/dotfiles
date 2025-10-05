alias brew='/opt/homebrew/bin/brew'

# Git:

alias gco='git checkout';
alias gst='git status';
alias gd='git diff -w';
alias gl='git log --graph --oneline --all';
alias gcam='git commit -am';
alias gprp='git pull --rebase; git push';


# Composer:

alias composer='php -d memory_limit=-1 /usr/local/bin/composer'
alias cda='composer dump-autoload';


# Magallanes:

alias mage='~/.composer/vendor/bin/mage';


# PHP: 
alias phpunit='php -d memory_limit=-1 vendor/bin/phpunit';


## Laravel

alias pamm='php artisan make:migration'
alias pami='php artisan migrate'


## NPM

alias nrd="npm run dev"
alias nrv="npm run vite"


