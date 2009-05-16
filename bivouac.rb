require 'rubygems'
require 'sinatra'
require 'haml'
require 'active_record'

SITE_ROOT = '/home/bivouac/apps'

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
    t.string "domain"
    t.text "ssh_public_key"
  end
end

class Site < ActiveRecord::Base
  def directory
    File.join(SITE_ROOT, domain)
  end
end

helpers do

  def write_vhost_conf
    vhost = File.join(SITE_ROOT, domain, '.conf')
    File.open(vhost, 'w') do |f|
    end
  end

  def init_repo(site)
    directory = site.directory
    Dir.chdir(directory)
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
end

get '/sites/new' do
  haml :site_new
end

get '/site/:id' do
  @site = Site.find params[:id]
  haml :site
end

get '/sites/create' do
  site = Site.new(params[:site])
  if domain_taken?(site.domain)
    # TODO: display errors
    back
  else
    if site.save!
      redirect "/site/#{site.id}"
    else
      # TODO: display errors
      back
    end
  end
end

get '/' do
  @sites = Site.all
  haml :index
end

private
def domain_taken?(name)
  site = Site.find_by_domain(name)
  return !site.nil?
end

