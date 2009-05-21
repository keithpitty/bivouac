require 'fileutils'

helpers do

  include Sinatra::Authorization

  def create_site(site)
    cat_key(site)
    init_repo(site)
    add_post_commit(site)
  end

  def init_repo(site)
    FileUtils.mkdir_p File.join(site.directory, 'tmp')
    `touch #{File.join(site.directory, 'tmp')}/never-deployed`
    FileUtils.mkdir_p File.join(site.directory, 'public')
    current_dir = Dir.getwd
    Dir.chdir site.directory
    `git init`
    Dir.chdir current_dir
    `ln -s #{site.directory} #{File.join(SITE_ROOT, site.name)}`
  end

  def add_post_commit(site)
    post_commit = File.join(site.directory, '.git/hooks/post-receive')
    File.open(post_commit, 'w') do |f|
      f.write <<-HERE
#!/bin/sh
cd #{site.directory};
git reset --hard;
# run initial_deploy_hook here unless /tmp/deployed exists
# initial_deploy should be created in site.directory/deploy-hooks

if [ -x deploy-hooks/initial-deploy -a -f tmp/never-deployed ]
then
  deploy-hooks/initial-deploy;
  rm #{site.directory}/tmp/never-deployed;
fi

# config_gem file should be in site.directory/deploy-hooks

# post_deploy_hook should be created in site.directory/deploy

if [ -x deploy-hooks/post-receive ]
then
  deploy-hooks/post-receive;
fi

cd #{site.directory} && git --git-dir=`pwd`/.git reset --hard;
touch #{site.directory}/tmp/restart.txt;
      HERE
      f.chmod(0775)
    end
  end

  def cat_key(site)
    File.open("#{ENV['HOME']}/.ssh/authorized_keys", 'a') do |f|
      f << site.ssh_public_key
    end
  end

  def authorization_realm
    'bivou.ac'
  end

  def authorize(login, password)
    login == "bivvy" && password == "whackers"
  end

end
