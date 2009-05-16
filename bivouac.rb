require 'rubygems'
require 'sinatra'
require 'haml'
require 'active_record'
require 'helpers'

USER_NAME = 'bivouac'
SITE_ROOT = '/home/#{USER_NAME}/apps'

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

  def repo_name
    'bivouac@bivouac.com:~/app/' + domain
  end

  def domain_name
    'http://' + domain
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
    redirect back
  else
    if site.save!
      cat_key(site)
      init_repo(site)
      #add_post_commit(site)
      redirect "/site/#{site.id}"
    else
      # TODO: display errors
      redirect back
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

