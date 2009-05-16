require 'rubygems'
require 'sinatra'
require 'haml'
require 'active_record'

helpers do

  def write_vhost_conf
    vhost = File.join('/var/www/bivouac/', name, '.conf')
    File.open(vhost, 'w') do |f|
      end
  end

  def init_repo
  end

  def add_post_commit(name)
    File.join('/var/www/bivouac/', name, '.conf')
  end

  def restart_server
  end

end

get '/' do
  haml :index
end

class Sites < ActiveRecord::Base



end

__END__
  
@@ index
%h1
  BIVOUAC
