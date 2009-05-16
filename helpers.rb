helpers do
  def init_repo(site)
    File.mkdir_p site.directory
    Dir.chdir site.directory
    `git init`
  end
  
  def add_post_commit(site)
    post_commit = File.join(site.directory, '.git/hooks/post-commit')
    File.open(post_commit, 'w') do |f|
      f.write <<-HERE
#!/bin/sh
touch #{site.directory}/tmp/restart.txt;
HERE
    end
  end
  
  def cat_key(site)
    File.write("~/.ssh/authorized_keys", 'a') do |f|
      f << site.authorized_keys
    end
  end
end
