require "bundler/setup"
require "pathological"
require "sinatra/base"
require "sinatra/reloader"
require "coffee-script"
require "sinatra/content_for2"
require "rack-flash"
require "lib/db"
require "lib/currency"
require "lib/authentication"

class SocialTeeth < Sinatra::Base
  enable :sessions
  set :session_secret, "abcdefghijklmnop"
  set :views, "views"
  use Rack::Flash

  helpers Sinatra::ContentFor2

  configure :development do
    register Sinatra::Reloader
  end

  def initialize(pinion)
    @pinion = pinion
    super
  end

  get "/" do
    erb :index
  end

  get "/submit" do
    erb :submit
  end

  post "/submit" do
    errors = enforce_required_params(:title, :description, :goal, :ad_type, :url)
    errors << "Goal must be dollar amount." unless params[:goal].is_currency?

    if errors.empty?
      Ad.create(:title => params[:title], :description => params[:description],
          :goal => params[:goal].to_dollars, :ad_type => params[:ad_type], :url => params[:url],
          :thumbnail_url => "http://example.com/thumbnail", :deadline => Time.now + 60 * 60 * 24 * 30)
      redirect "/"
    else
      flash[:errors] = errors
      redirect "/submit"
    end
  end

  def enforce_required_params(*args)
    empty_fields = args.select { |field| params[field].empty? }
    empty_fields.empty? ? [] : ["All fields are required."]
  end
end
