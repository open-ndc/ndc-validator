require 'bundler/setup'
require 'sinatra'
require 'sinatra/partial'
require 'pry'

require 'haml'
require 'net/http'
require 'sequel'
require 'sequel/plugins/serialization'
require 'nokogiri'
require './core_ext/object'

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
  errors = []
  if params[:xml_body].present? || !params[:version].present?
    message = params[:xml_body]
    doc = Nokogiri::XML(message)
    if doc.root
      ndc_method = doc.root.name
      #TODO validate with methods list
      if !ndc_method.empty?
        @message = Message.new(xml: message, ndc_method: ndc_method)
        schemas_path = SCHEMAS_DIR + params[:version]
        Dir.chdir(schemas_path) do
          begin
            schema_file = "#{ndc_method}.xsd"
            xsd = Nokogiri::XML::Schema(File.read(schema_file))
            errors += xsd.validate(doc)
          rescue
            errors << NDCValidator::IvalidNDCMessageError.new("Invalid/unknown NDC message")
          end
        end
      else
        errors << NDCValidator::EmptyMessageError.new("Can't parse an empty message")
      end
    else
      errors << NDCValidator::NDCParseUndefinedError.new("Unsuccessful message parsing")
    end
    @message.ndc_errors = errors
    if @message.save && @message.valid?
      redirect "/message/#{@message.hash_id}"
    else
      redirect "/"
    end
  else
    haml :"400", layout: false, status: 400
  end
end

get '/message/:hash_id' do
  @message = Message[hash_id: params[:hash_id]]
  if @message.present? && @message.valid?
    @url = "http://#{request.env["HTTP_HOST"]}/message/#{@message.hash_id}"
    haml :index, :format => :html5
  else
    haml :"404", layout: false, status: 404
  end
end
