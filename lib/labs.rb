class SocialTeeth < Sinatra::Base
  get "/labs" do
    erb :"labs/index"
  end
end
