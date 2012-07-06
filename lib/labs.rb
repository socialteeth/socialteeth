class SocialTeeth < Sinatra::Base
  get "/labs" do
    redirect "/labs/resources"
  end

  get "/labs/resources" do
    erb :"labs/resources"
  end
end
