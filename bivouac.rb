require 'rubygems'
require 'sinatra'
require 'haml'

helpers do

end

get '/' do
  haml :index
end

__END__
  
@@ index
%h1
  BIVOUAC
