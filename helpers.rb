require 'fileutils'

helpers do

  def init_repo(site)
    FileUtils.mkdir_p site.directory
    current_dir = Dir.getwd
    Dir.chdir site.directory
    `git init`
    Dir.chdir current_dir
  end

  def add_post_commit(name)
    post_commit = File.join(SITE_ROOT, domain, '.conf')
    File.open(post_commit, 'w') do |f|
      f <<-HERE
      #!/usr/env ruby
      HERE
    end
  end

  def cat_key(site)
    File.open("#{ENV['HOME']}/.ssh/authorized_keys", 'a') do |f|
      f << site.ssh_public_key
    end
  end

end

