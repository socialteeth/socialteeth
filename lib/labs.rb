class SocialTeeth < Sinatra::Base
  get "/labs" do
    redirect "/labs/resources"
  end

  get "/labs/resources" do
    erb :"labs/resources"
  end

  get "/labs/discussions" do
    erb :"labs/discussions", :locals => { :discussions => Discussion.order(:updated_at.desc) }
  end

  get "/labs/discussions/:public_id" do
    halt 404 unless discussion = Discussion.find(:public_id => params[:public_id])
    erb :"labs/discussion", :locals => { :discussion => discussion }
  end

  post "/labs/discussions/create_discussion" do
    halt 400 unless params.include?("user_id") && params.include?("title")
    halt 400 unless user = User.find(:public_id => params["user_id"])
    discussion = Discussion.create(:user_id => user.id, :title => params["title"])
    redirect "/labs/discussions/#{discussion.public_id}"
  end

  post "/labs/discussions/create_comment" do
    halt 400 unless params.include?("discussion_public_id") && params.include?("user_public_id") &&
        params.include?("text")
    halt 400 unless user = User.find(:public_id => params["user_public_id"])
    halt 400 unless discussion = Discussion.find(:public_id => params["discussion_public_id"])
    comment = discussion.add_new_comment(params["text"])
    erb :comment, :layout => false, :locals => { :comment => comment }
  end
end
