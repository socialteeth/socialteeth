require "bundler/setup"
require "pathological"
require "sinatra"
require "coffee-script"
require "rack-flash"
require "lib/models"

class SocialTeeth < Sinatra::Base
  enable :sessions
  use Rack::Flash, :sweep => true

  def initialize(pinion)
    @pinion = pinion
    super
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    errors = []

    empty_fields = [:name, :email, :password, :confirm_password].select { |field| params[field].empty? }
    errors << "All fields are required." unless empty_fields.empty?

    if params[:email]
      existing_user = User.find(:email => params[:email])
      errors << "Another user exists with that email." if existing_user
    end

    errors << "Passwords must match." unless params[:password] == params[:confirm_password]

    if errors.empty?
      User.create(:name => params[:name], :email => params[:email], :password => params[:password])
      redirect "/"
    else
      flash[:errors] = errors
      redirect "/signup"
    end
    redirect "/signup"
  end
end
