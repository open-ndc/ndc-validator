require "bundler/setup"
require "sinatra"
require 'sinatra/partial'
require 'pry'

require 'haml'
require "net/http"
require 'sequel'
require 'nokogiri'

require 'pry'
get '/' do
  haml :index, :format => :html5
end
