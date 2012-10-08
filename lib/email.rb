require "pony"

module Email

  def send_email(to,subject,body)
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
       :subject => subject, :html_body => body)
  end
end

