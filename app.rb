require "bundler/setup"
require "pathological"
require "sinatra"
require "coffee-script"
require "rack-flash"
require "lib/models"
require "lib/authentication"

class SocialTeeth < Sinatra::Base
  enable :sessions
  set :session_secret, "abcdefghijklmnop"
  set :views, "views"
  use Rack::Flash

  def initialize(pinion)
    @pinion = pinion
    super
  end

  get "/" do
    erb :index
  end

  def enforce_required_params(*args)
    empty_fields = args.select { |field| params[field].empty? }
    empty_fields.empty? ? [] : ["All fields are required."]
  end
end
