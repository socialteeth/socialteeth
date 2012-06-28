class SocialTeeth < Sinatra::Base
  get "/signup" do
    erb :signup
  end

  post "/signup" do
    flash[:name] = params[:name]
    flash[:email] = params[:email]
    errors = enforce_required_params([:name, :email, :password, :confirm_password])

    if params[:email] && params[:email].match(/[^@]+@[^@]+/)
      existing_user = User.find(:email => params[:email])
      errors << "Another user exists with that email." if existing_user
    else
      errors << "Invalid email."
    end

    errors << "Passwords must match." unless params[:password] == params[:confirm_password]

    if errors.empty?
      self.current_user =
          User.create(:name => params[:name], :email => params[:email], :password => params[:password])
      redirect "/"
    else
      flash[:errors] = errors
      redirect "/signup"
    end
    redirect "/signup"
  end

  get "/signin" do
    erb :signin
  end

  post "/signin" do
    flash[:email] = params[:email]
    errors = enforce_required_params([:email, :password])

    requested_user = User.find(:email => params[:email])
    if requested_user && requested_user.password == params[:password]
      self.current_user = requested_user
      redirect params[:redirect] ? params[:redirect] : "/"
    else
      errors << "Invalid login." if errors.empty?
      flash[:errors] = errors
      redirect "/signin"
    end
  end

  get "/signout" do
    session.clear
    redirect "/"
  end

  def current_user()
    @current_user ||= User.find(:email => session[:email])
  end

  def current_user=(user)
    return if session[:email] == user.email
    @current_user = nil
    session.clear
    session[:email] = user.email if user
  end
end
