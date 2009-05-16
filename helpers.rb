
helpers do

  def init_repo(site)
    File.mkdir_p site.directory
    Dir.chdir site.directory
    `git init`
  end

  def add_post_commit(name)
    post_commit = File.join(SITE_ROOT, domain, '.conf')
    File.open(post_commit, 'w') do |f|
      f << HERE__
      #!/usr/env ruby
      HERE
    end
  end

  def cat_key(site)
    File.write("~/#{USER_NAME}/.ssh/authorized_keys", 'a') do |f|
      f << site.authorized_keys
    end
  end

end

