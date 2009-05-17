require 'fileutils'

helpers do

  def create_site(site)
    cat_key(site)
    init_repo(site)
    add_post_commit(site)
  end

  def init_repo(site)
    FileUtils.mkdir_p File.join(site.directory, 'tmp')
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

end
