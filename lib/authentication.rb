require "securerandom"
require "pony"

class SocialTeeth < Sinatra::Base
  get "/signup" do
    erb :signin
  end

  post "/signup" do
    flash[:name] = params[:name]
    flash[:email] = params[:email]
    errors = enforce_required_params([:name, :email, :password])

    if params[:email] && params[:email].match(/[^@]+@[^@]+/)
      existing_user = User.find(:email => params[:email])
      errors << "Another user exists with that email." if existing_user
    else
      errors << "Invalid email."
    end

    if errors.empty?
      self.current_user =
          User.create(:name => params[:name], :email => params[:email], :password => params[:password],
                      :votes => 100)
      redirect params[:redirect] ? params[:redirect] : "/"
    else
      flash[:errors] = errors
      redirect "/signin?action=signup"
    end
    redirect "/signin"
  end

  post "/profile" do
    ensure_signed_in
    if params[:password] == params[:password_check]
      flash[:message] = "Password changed successfully."
      current_user.password = params[:password]
      current_user.save
    else
      flash[:errors] = ["Passwords did not match."]
    end

    redirect "/profile"
  end

  post "/newPassword" do
    if params[:email] && params[:email].match(/[^@]+@[^@]+/)
      existing_user = User.find(:email => params[:email])

      if existing_user
        new_password = SecureRandom.hex(8)
        existing_user.password = new_password
        existing_user.save
        send_email(params[:email], new_password)
        flash[:message] = "A new password has been sent to your email address."
      else
        flash[:errors] = ["We have no record of that email in our database."]
      end
    else
      flash[:errors] = ["Invalid email."]
    end
    redirect "/signin?action=signin"
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
      redirect "/signin?action=signin"
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

 def send_email(to, password)
   Pony.mail(
     :to => to,
     :from => "Social Teeth Support <contact@socialteeth.org>",
     :via => :smtp,
     :via_options => {
       :address => "smtp.gmail.com",
       :port => "587",
       :enable_starttls_auto => true,
       :user_name => "contact@socialteeth.org",
       :password => EMAIL_PASSWORD,
       :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
     },
     :subject => "Social Teeth Temporary Password", :html_body => "Your temporary password is: "+ password +"<br /> Once you login you can change your password on your user preferences page. <br /><br /> Best,<br />Social Teeth Support")
  end
end
