load 'deploy' if respond_to?(:namespace) # cap2 differentiator

set :user, "bivouac"
set :use_sudo, false

set :scm, :git
set :repository,  "git@github.com:agencyrainford/pearson-author.git"
set :branch, "production"
set :deploy_via, :remote_cache

set :application, "bivouac"
set :deploy_to, "/home/bivouac/current/public"

role :app, "bivouac.com"
role :web, "bivouac.com"

ssh_options[:keys] = %w(~/.ssh/id_rsa ~/.ssh/id_dsa)
ssh_options[:forward_agent] = true

namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end