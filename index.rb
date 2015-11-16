require 'bundler/setup'
require 'sinatra'
require 'sinatra/partial'
require 'pry'

require 'haml'
require 'net/http'
require 'sequel'
require 'nokogiri'
require './core_ext/object'

require 'pry'

module NDCValidator
  class IvalidNDCMessageError < RuntimeError; end
  class EmptyMessageError < RuntimeError; end
  class NDCParseUndefinedError < RuntimeError; end
end

SCHEMAS_DIR = "./schemas/"
SCHEMAS_VERSIONS = {'v113-p15-2' => "Version 1.1.3 - patch 15.2 (Oct 2015)"}

configure do
  enable :partial_underscores
	DB = Sequel.connect( ENV["DATABASE_URL"] || "sqlite://development.db" )
	require "./models"
end

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
          begin
            schema_file = "#{@ndc_message}.xsd"
            xsd = Nokogiri::XML::Schema(File.read(schema_file))
            @errors += xsd.validate(doc)
          rescue
            @errors << NDCValidator::IvalidNDCMessageError.new("Invalid/unknown NDC message")
          end
        end
      else
        @errors << NDCValidator::EmptyMessageError.new("Can't parse an empty message")
      end
    else
      @errors << NDCValidator::NDCParseUndefinedError.new("Unsuccessful message parsing")
    end
  else
    @errors << RuntimeError.new("Empty Message/Version")
  end
  haml :index, :format => :html5
end
