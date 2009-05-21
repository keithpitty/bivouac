require 'rubygems'
require 'sinatra'
require 'sinatra/authorization'
require 'haml'
require 'active_record'
require 'helpers'

#TODO use set -look up sinatra docs
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
    File.join(SITE_ROOT, name) + '.bivou.ac'
  end

  def repo
    "#{USER_NAME}@bivou.ac:~/apps/#{name}"
  end

  def domain_name
    "http://#{name}.bivou.ac"
  end

  def valid?
    @error = nil
    name_valid?(name) && name_available?(name) && ssh_key_entered
  end

  private
  def name_available?(name)
    site = Site.find_by_name(name)
    @error =  conjure_error_message("App name already snaffled. Be more creative and try another!") unless site.nil?
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
    @error = conjure_error_message("Sadly formed name. Try again you palooka!") unless valid
    @error.nil?
  end
  
  def ssh_key_entered
    if ssh_public_key.nil? || ssh_public_key.length == 0
      @error = conjure_error_message("Wake up camper and enter your public ssh key!")
    end
    @error.nil?
  end

  def conjure_error_message(error)
    bogus_messages = [
        "Watch out, wombats on the rampage!",
        "Your billy is boiling over!",
        "Strewth, your tent's blown over!",
        "Crikey, Bindi Irwin's on the loose!",
        "Those wallabies for your stew have escaped!",
        "Blimey, the beer has run out!",
        "Shiver me timbers, the fire has gone out!",
        "Look out, it's Dylan in his gorilla suit!",
        "It's dark, it's spooky and the strangler figs are about!",
        "Warning camper, Myles is about to pontificate!",
        "Shit, the server is down!",
        "Careful camper, that fire is hot!",
        "So you think you're a guitar hero?",
        "Bloody bananajour is buggered again!",
        "Careful villager, the werewolves are coming!"
      ]
    "#{bogus_messages[rand(bogus_messages.size - 1)]} #{error}"
  end
end

get '/:name' do
  login_required
  @site = Site.find_by_name params[:name]
  haml :site
end

post '/sites/create' do
  login_required
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
