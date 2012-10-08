require "lib/email"
include Email

class SocialTeeth < Sinatra::Base

  get "/ads/:id/contribute" do
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    erb :contribute, :locals => { :ad => ad }
  end

  get "/ads/:id/contribute_confirm" do
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    halt 400 unless params[:amount] && params[:token]
    erb :contribute_confirm, :locals => { :ad => ad, :amount => params[:amount], :token => params[:token],
        :name => params[:name], :email => params[:email], :address => params[:address],
        :occupation => params[:occupation], :employer => params[:employer] }
  end

  post "/ads/:id/contribute_confirm" do
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    required_params = [:dollar_amount, :stripe_token]
    required_params += [:name, :address, :occupation, :employer] if ad.id == 52 # Gary Johnson
    email = params[:contribute_email]

    errors = enforce_required_params(required_params)

    errors << "Invalid Email" unless email && email.match(/[^@]+@[^@]+/)

    begin
      dollars = params[:dollar_amount] == "custom" ?
          params[:custom_amount].to_dollars : params[:dollar_amount].to_dollars
    rescue CurrencyError => error
      errors << "Invalid contribution amount"
    end

    if ad.id == 52 # Gary Johnson
      address = params[:address] if params[:address]
      occupation= params[:occupation] if params[:occupation]
      employer = params[:employer] if params[:employer]
      name =  params[:name] if params[:name]

      errors << "The maximum contribution amount for this ad is $2500." if dollars && dollars > 2500
    end

    if errors.empty?

      amount_in_cents = dollars * 100
      token = params[:stripe_token]
      redirect "/ads/#{ad.public_id}/contribute_confirm?amount=#{amount_in_cents}&token=#{token}&" +
          "email=#{email}&occupation=#{occupation}&address=#{address}&employer=#{employer}&name=#{name}"
    else
      flash[:errors] = errors
      redirect "/ads/#{ad.public_id}/contribute"
    end
  end

  get "/ads/:id/contribute_success" do
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    
   
    erb :contribute_success, :locals => { :ad => ad }
  end

  post "/ads/:id/contribute_submit" do
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    halt 400 unless params[:amount] && params[:token]
    halt 400 unless params[:amount].to_i.to_s == params[:amount].to_s
    if ad.id == 52
      halt 400 unless params[:address] && params[:occupation] && params[:employer] && params[:name]
    end

    Stripe.api_key = STRIPE_SECRET_KEY

    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      charge = Stripe::Charge.create(
        :amount => params[:amount],
        :currency => "usd",
        :card => params[:token],
        :description => "#{params[:name]} -- #{ad.title}"
      )
    rescue Stripe::InvalidRequestError => error
      flash[:errors] = [error.message]
      redirect "/ads/#{ad.public_id}/contribute"
    rescue Stripe::CardError
      flash[:errors] = ["There was an error processing your payment. Please use a different card."]
      redirect "/ads/#{ad.public_id}/contribute"
    end

    # TODO(dmac): Validate the payment actually went through.
    Payment.create(:ad_id => ad.id, :email => params[:email], :amount => params[:amount],
                   :address => params[:address], :occupation => params[:occupation],
                   :employer => params[:employer],:employer => params[:employer], :name => params[:name])
    
    body = "Thanks! You have just helped the '" + ad.title + "' 
    campaign get " + (params[:amount].to_i).to_currency + " closer to airtime. <br /> 
    Their ad will be on air once the total fundraising goal is reached 
    - so tell your friends! <br /><br /> You are the best,<br />Social Teeth"
    send_email(params[:email],"Social Teeth Contribution Confirmation", body)
    redirect "/ads/#{ad.public_id}/contribute_success"
  end
end
