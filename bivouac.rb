require 'rubygems'
require 'sinatra'
require 'haml'
require 'active_record'

ActiveRecord::Base.establish_connection(
   :adapter  => "mysql",
   :host     => "localhost",
   :username => "root",
   :password => "",
   :database => "bivouac"
)

class Site < ActiveRecord::Base

end

helpers do

  def write_vhost_conf
    vhost = File.join('/var/www/bivouac/', name, '.conf')
    File.open(vhost, 'w') do |f|
    end
  end

  def init_repo
  end

  def add_post_commit(name)
    post_commit = File.join('/var/www/bivouac/', name, '.conf')
    File.open(post_commit, 'w') do |f|
    end
  end

  def restart_server
    post_commit = File.join('/var/www/bivouac/', name, '/tmp/restart.txt')
    File.open(post_commit, 'w') do |f|
    end
  end

end

get '/' do
  @sites = Site.all
  haml :index
end

