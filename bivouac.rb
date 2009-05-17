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
    t.string "name"
    t.text "ssh_public_key"
  end
end

class Site < ActiveRecord::Base
  attr_reader :error

  def directory
    File.join(SITE_ROOT, name)
  end

  def repo
    "#{USER_NAME}@bivouac.com:/home/bivouac/apps/#{name}.bivouac.com"
  end

  def domain_name
    "http://#{name}.bivouac.com"
  end

  def valid?
    @error = nil
    name_valid?(name) && name_available?(name) && ssh_key_entered
  end

  private
  def name_available?(name)
    site = Site.find_by_name(name)
    @error = "Domain name already snaffled. Be more creative and try another!" unless site.nil?
    return site.nil?
  end

  def name_valid?(name)
    valid = true
    if name.nil? || name.length == 0 || name[0] == "-" || name[name.length - 1] == "-"
      valid = false
    else
      parts = name.split('-')
      parts.each do |part|
        if part.match(/^[a-z][a-z\d-]*[a-z\d]$/).nil?
          valid = false
        end
      end
    end
    @error = "Sadly formed name. Try again you palooka!" unless valid
    @error.nil?
  end
  
  def ssh_key_entered
    if ssh_public_key.nil? || ssh_public_key.length == 0
      @error = "Wake up camper and enter your public ssh key!"
    end
    @error.nil?
  end
end

get '/:name' do
  @site = Site.find_by_name params[:name]
  haml :site
end

post '/sites/create' do
  @site = Site.new(params[:site])
  @site.name = @site.name.downcase
  if @site.valid? && @site.save!
    create_site(@site)
    redirect "/#{@site.name}"
  else
    @sites = Site.find(:all, :order => 'name')
    haml :index
  end
end

get '/' do
  @sites = Site.find(:all, :order => 'name')
  @site = Site.new
  haml :index
end
