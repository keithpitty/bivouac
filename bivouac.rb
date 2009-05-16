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
    vhost = File.join(SITE_ROOT, name, '.conf')
    File.open(vhost, 'w') do |f|
    end
  end

  def init_repo(site)
    directory = site.directory
    Dir.chdir(directory)
    `git init`
  end

  def add_post_commit(name)
    post_commit = File.join(SITE_ROOT, name, '.conf')
    File.open(post_commit, 'w') do |f|
    end
  end

  def restart_app
    post_commit = File.join(SITE_ROOT, name, '/tmp/restart.txt')
    File.open(post_commit, 'w') do |f|
    end
  end

end

get '/sites/new' do
  haml :site_new
end

get '/site/:id' do
  @site = Site.find params[:id]
  haml :site
end

get '/sites/create' do
  puts "/sites/create invoked..."
  puts "#{params[:site]}"
  site = Site.new(params[:site])
  if site.save!
    redirect "/site/#{site.id}"
  else
    # TODO: display errors
    back
  end
end

get '/' do
  @sites = Site.all
  haml :index
end

