# woodward has rubygems 1.3.5, but bundler proper needs 1.3.6.
# I don't want to keep managing my own copy of rubygems up there.
depend :remote, :gem, 'bundler08', '~> 0.8.5'

set :application, 'feeds'
set :repository,  'git://github.com/matthewtodd/feeds.git'
set :scm,         :git
set :deploy_to,   '/users/home/matthew/domains/feeds.matthewtodd.org/var/www'
set :deploy_via,  :remote_cache
set :use_sudo,    false

server 'woodward.joyent.us', :web, :app, :db, :primary => true, :user => 'matthew'

namespace :deploy do
  task(:start)   { }
  task(:stop)    { }
  task(:restart) { }
end
