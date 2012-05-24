require "bundler/setup"
require "pathological"
require "sinatra"
require "coffee-script"

class SocialTeeth < Sinatra::Base
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
    # Create user
    redirect "/"
  end
end
