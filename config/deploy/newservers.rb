set :mytask, 'newservers'

set :ssh_options, {:forward_agent => true}

set :port, 22
role :app, 'nfs'
role :web, 'nfs'
role :db, 'nfs', :primary => true

set :default_environment, { 'PATH' => "/home/deploy/.rbenv/shims:/home/deploy/.rbenv/bin:/home/deploy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games" }
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

namespace :deploy do
  task :stop do
    sudo "stop app_#{application}"
  end
  task :start do
    sudo "start app_#{application}"
  end
  task :status do
    sudo "status app_#{application}"
  end
  task :restart do
    sudo "stop app_#{application}"
    sudo "start app_#{application}"
    sudo "status app_#{application}"
  end
  task :rbenv_setup do
    run "mkdir -p #{deploy_to}"
    run "echo 1.9.2-p290 > #{deploy_to}/.rbenv-version"
    run "cd #{deploy_to} && gem i rake"
    run "cd #{deploy_to} && gem i pry"
    run "cd #{deploy_to} && gem i bundler --pre"
  end
  task :banner do
    run %{cd #{deploy_to} && echo "==== [ $(ruby -v) ] ===="}
    run %{cd #{deploy_to} && echo "==== [ $(gem env home) ] ===="}
  end
end

before "deploy:setup", "deploy:banner"
before "deploy:setup", "deploy:rbenv_setup"
after "deploy:setup", "deploy:banner"

