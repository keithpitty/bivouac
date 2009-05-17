require 'rubygems'
require 'sinatra'
require 'haml'
require 'active_record'
require 'helpers'

USER_NAME = 'bivouac'
SITE_ROOT = "#{ENV['HOME']}/apps"

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
  attr_reader :error

  def directory
    File.join(SITE_ROOT, domain)
  end

  def repo
    "#{USER_NAME}@bivouac.com:~/apps/" + domain
  end

  def domain_name
    'http://' + domain
  end

  def valid?
    @error = nil
    domain_available?(domain) && domain_valid?(domain)
  end

  private
  def domain_available?(name)
    site = Site.find_by_domain(name)
    @error = "Domain name already snaffled. Be more creative and try another!" unless site.nil?
    return site.nil?
  end

  def domain_valid?(name)
    parts = name.split(".")
    parts.each do |part|
      if part.match(/^[a-z][a-z\d-]*[a-z\d]$/).nil?
        @error = "Badly formed domain name. Try again you palooka!"
      end
    end
    @error.nil?
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
  site.domain = site.domain.downcase
  if site.valid? && site.save!
    create_site(site)
    redirect "/site/#{site.id}"
  else
    @error = site.error
    haml :site_new
  end
end

get '/' do
  @sites = Site.find(:all, :order => 'domain')
  haml :index
end
