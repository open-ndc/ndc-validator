require "bundler/setup"
require "sinatra"
require 'sinatra/partial'
require 'pry'

require 'haml'
require "net/http"
require 'nokogiri'

require 'pry'

SCHEMAS_DIR = "./schemas/"
SCHEMAS_VERSIONS = {'v113-p15' => "Version 1.1.3-patch 15 (Oct 2015)"}
get '/' do
  haml :index, :format => :html5
end

post '/validate' do
  if !params[:xml_body].nil? && !params[:version].nil?
    @message = params[:xml_body]
    doc = Nokogiri::XML(@message)
    @ndc_message = doc.root.name
    schemas_path = SCHEMAS_DIR + params[:version]
    Dir.chdir(schemas_path) do
      schema_file = "#{@ndc_message}.xsd"
      puts "Loading NDC Schema... (#{schema_file})"
      xsd = Nokogiri::XML::Schema(File.read(schema_file))
      @errors = xsd.validate(doc)
    end
  else
    @errors = "UNDEFINED ERROR while processing request"
  end
  haml :index, :format => :html5
end
