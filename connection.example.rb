require 'active_record'

def connect_to_db
  ActiveRecord::Base.establish_connection(
    :adapter  => "mysql",
    :host     => "localhost",
    :username => "root",
    :password => "",
    :database => "bivouac"
  )
end

