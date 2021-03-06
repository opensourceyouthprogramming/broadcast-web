require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

set :domain, 'shidur.bbdomain'
set :deploy_to, '/sites/shidur/broadcast-web'
set :repository, 'https://github.com/edoshor/broadcast-web'
set :branch, 'master'
set :shared_paths, %w(config/database.yml config/thin.yml config/environments/production.yml)
set :user, 'edoshor'
set :term_mode, nil


task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue %[echo "-----> Be sure to edit 'shared/config/database.yml'."]

  queue! %[mkdir -p "#{deploy_to}/shared/config/environments"]
  queue! %[touch "#{deploy_to}/shared/config/environments/production.yml"]
  queue %[echo "-----> Be sure to edit 'shared/config/environments/production.yml'."]

  queue! %[touch "#{deploy_to}/shared/config/thin.yml"]
  queue %[echo "-----> Be sure to edit 'shared/config/thin.yml'."]
end

desc 'Deploys the current version to the server.'
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      queue %{
          if [ -f $(cat config/thin.yml | grep pid: | sed '/^pid: */!d; s///;q') ];
          then
            echo "thin is up. restarting"
            bundle exec thin -C config/thin.yml restart
            exit
          else
            echo "thin is down. starting"
            bundle exec thin -C config/thin.yml start
            exit
          fi
      %}
    end
  end
end