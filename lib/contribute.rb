class SocialTeeth < Sinatra::Base
  get "/ads/:id/contribute" do
   # ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    erb :contribute, :locals => { :ad => ad }
  end

  get "/ads/:id/contribute_confirm" do
   # ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    halt 400 unless params[:amount] && params[:token]
   

    erb :contribute_confirm, :locals => { :ad => ad, :amount => params[:amount], :token => params[:token]}
  end

  post "/ads/:id/contribute_confirm" do
    #ensure_signed_in
    
    
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    required_params = [:dollar_amount, :stripe_token]
    required_params += [:name, :address, :occupation, :employer] if ad.id == 52 # Gary Johnson
    flash[:tempEmail] = params[:contributeEmail]
  
    errors = enforce_required_params(required_params)
    
    if params[:contributeEmail] && params[:contributeEmail].match(/[^@]+@[^@]+/)
    else
      errors << "Invalid Email"
    end

    begin
      dollars = params[:dollar_amount] == "custom" ?
          params[:custom_amount].to_dollars : params[:dollar_amount].to_dollars
    rescue CurrencyError => error
      errors << "Invalid contribution amount"
    end

    if ad.id == 52 # Gary Johnson
      current_user.name = params[:name] if params[:name]
      current_user.address = params[:address] if params[:address]
      current_user.occupation = params[:occupation] if params[:occupation]
      current_user.employer = params[:employer] if params[:employer]
      current_user.save

      errors << "The maximum contribution amount for this ad is $2500." if dollars > 2500
    end

    if errors.empty?
      amount_in_cents = dollars * 100
      token = params[:stripe_token]
      redirect "/ads/#{ad.public_id}/contribute_confirm?amount=#{amount_in_cents}&token=#{token}"
    else
      flash[:errors] = errors
      redirect "/ads/#{ad.public_id}/contribute"
    end
  end

  get "/ads/:id/contribute_success" do
   # ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    erb :contribute_success, :locals => { :ad => ad }
  end

  post "/ads/:id/contribute_submit" do
    #ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    halt 400 unless params[:amount] && params[:token]
    halt 400 unless params[:amount].to_i.to_s == params[:amount].to_s

    Stripe.api_key = STRIPE_SECRET_KEY

    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      charge = Stripe::Charge.create(
        :amount => params[:amount],
        :currency => "usd",
        :card => params[:token],
        :description => "#{flash[:tempEmail]} -- #{ad.title}"
      )
    rescue Stripe::InvalidRequestError => error
      flash[:errors] = [error.message]
      redirect "/ads/#{ad.public_id}/contribute"
    rescue Stripe::CardError
      flash[:errors] = ["There was an error processing your payment. Please use a different card."]
      redirect "/ads/#{ad.public_id}/contribute"
    end

    # TODO(dmac): Validate the payment actually went through.
   
#    puts params[:contributeEmail]
    Payment.create(:ad_id => ad.id, :email_id => flash[:tempEmail], :amount => params[:amount])

    redirect "/ads/#{ad.public_id}/contribute_success"
  end
end
