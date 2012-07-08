class SocialTeeth < Sinatra::Base
  get "/labs" do
    redirect "/labs/resources"
  end

  get "/labs/resources" do
    erb :"labs/resources"
  end

  get "/labs/discussions" do
    erb :"labs/discussions"
  end
end
