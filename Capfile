load 'deploy' if respond_to?(:namespace) # cap2 differentiator

set :user, "bivouac"
set :use_sudo, false

set :scm, :git
set :repository,  "git://github.com/martinstannard/bivouac.git"
set :deploy_via, :remote_cache

set :application, "bivouac"
set :deploy_to, "/home/bivouac"

role :app, "bivou.ac"
role :web, "bivou.ac"

ssh_options[:keys] = %w(~/.ssh/id_rsa ~/.ssh/id_dsa)
ssh_options[:forward_agent] = true

namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

task :after_deploy do
  run "ln -s #{shared_path}/connection.rb #{release_path}/connection.rb"
end


