class SocialTeeth < Sinatra::Base
  get "/labs" do
    redirect "/labs/resources"
  end

  get "/labs/resources" do
    erb :"labs/resources"
  end

  get "/labs/discussions" do
    erb :"labs/discussions", :locals => { :discussions => Discussion.all }
  end

  get "/labs/discussions/:public_id" do
    puts "\n\n\n#{params.inspect}\n\n\n"
    halt 404 unless discussion = Discussion.find(:public_id => params[:public_id])
    erb :"labs/discussion", :locals => { :discussion => discussion }
  end

  post "/labs/discussions/create_discussion" do
    puts "\n\n\n#{params.inspect}\n\n\n"
    halt 400 unless params.include?("user_id") && params.include?("title")
    halt 400 unless user = User.find(:public_id => params["user_id"])
    discussion = Discussion.create(:user_id => user.id, :title => params["title"])
    redirect "/labs/discussions/#{discussion.public_id}"
  end
end
