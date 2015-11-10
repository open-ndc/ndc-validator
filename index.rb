require 'bundler/setup'
require 'sinatra'
require 'sinatra/partial'
require 'pry'

require 'haml'
require 'net/http'
# require 'sequel'
require 'nokogiri'
require './core_ext/object'

require 'pry'

module NDCValidator
  class IvalidNDCMessageError < RuntimeError; end
  class NDCParseUndefinedError < RuntimeError; end
end

SCHEMAS_DIR = "./schemas/"
SCHEMAS_VERSIONS = {'v113-p15-2' => "Version 1.1.3 - patch 15.2 (Oct 2015)"}
get '/' do
  haml :index, :format => :html5
end

post '/validate' do
  @errors = []
  if params[:xml_body].present? || !params[:version].present?
    @message = params[:xml_body]
    doc = Nokogiri::XML(@message)
    if doc.root
      @ndc_message = doc.root.name
      if !@ndc_message.empty?
        schemas_path = SCHEMAS_DIR + params[:version]
        Dir.chdir(schemas_path) do
          schema_file = "#{@ndc_message}.xsd"
          xsd = Nokogiri::XML::Schema(File.read(schema_file))
          @errors = xsd.validate(doc)
        end
      else
        @errors << NDCValidator::IvalidNDCMessageError.new("Invalid/unknown NDC method")
      end
    else
      @errors << NDCValidator::NDCParseUndefinedError.new("Unsuccessful message parsing")
    end
  else
    @errors << RuntimeError.new("Invalid/empty Message/Version")
  end
  haml :index, :format => :html5
end
