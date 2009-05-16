require 'rubygems'
require 'sinatra'
require 'haml'
require 'active_record'

SITE_ROOT = '/var/www/bivouac/'

ActiveRecord::Base.establish_connection(
   :adapter  => "mysql",
   :host     => "localhost",
   :username => "root",
   :password => "",
   :database => "bivouac"
)

unless ActiveRecord::Base.connection.tables.include?('sites')
  puts "Creating sites table..."
  ActiveRecord::Base.connection.create_table("sites") do |t|
    t.string "name", "hostname"
  end
end

class Site < ActiveRecord::Base
  def directory
    File.join(SITE_ROOT, name)
  end
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

get '/sites/new' do
  haml :site_new
end

get '/sites/create' do
  # TODO: complete
  puts "/sites/create invoked..."
  site = Site.new(:name => params[:name], :hostname => params[:hostname])
  if site.save!
    render "/site/#{site.id}"
  else
    # TODO finish
  end
end

get '/' do
  @sites = Site.all
  haml :index
end

