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
require "lib/uploader"

class SocialTeeth < Sinatra::Base
  enable :sessions
  set :session_secret, "abcdefghijklmnop"
  set :views, "views"
  set :public_folder, "public"
  use Rack::Flash

  helpers Sinatra::ContentFor2

  configure :development do
    register Sinatra::Reloader
    also_reload "lib/*"
    also_reload "models/*"
  end

  configure do
    set :root, File.expand_path(File.dirname(__FILE__))
  end

  def initialize(pinion)
    @pinion = pinion
    super
  end

  before do
    request.path_info = "/placeholder" if ENV["RACK_ENV"] == "production"
  end

  get "/placeholder" do
    erb :placeholder, :locals => { :render_header => false }
  end

  get "/" do
    featured_ads = Ad.order_by(:id.desc).limit(8).all
    erb :index, :locals => { :featured_ads => featured_ads }
  end

  get "/browse" do
    ads = Ad.order_by(:id.desc).all
    erb :browse, :locals => { :ads => ads }
  end

  get "/submit" do
    redirect "/signin" if current_user.nil?
    erb :submit
  end

  post "/submit" do
    redirect "/signin" if current_user.nil?
    errors = enforce_required_params(:title, :description, :goal, :ad_type, :url)
    errors << "Goal must be dollar amount." unless params[:goal].is_currency?

    if errors.empty?
      ad = Ad.create(:title => params[:title], :description => params[:description],
          :goal => params[:goal].to_dollars, :ad_type => params[:ad_type], :url => params[:url],
          :user_id => current_user.id, :deadline => Time.now + 60 * 60 * 24 * 30)

      ad.thumbnail_url_base = Uploader.new.upload_ad_thumbnail(ad, params[:thumbnail][:tempfile])
      ad.save

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
