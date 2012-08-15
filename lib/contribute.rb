class SocialTeeth < Sinatra::Base
  get "/ads/:id/contribute" do
    ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    erb :contribute, :locals => { :ad => ad }
  end

  get "/ads/:id/contribute_confirm" do
    ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    halt 400 unless params[:amount] && params[:token]

    erb :contribute_confirm, :locals => { :ad => ad, :amount => params[:amount], :token => params[:token] }
  end

  post "/ads/:id/contribute_confirm" do
    ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    errors = enforce_required_params([:amount, :stripe_token])

    begin
      dollars = params[:amount].to_dollars
    rescue CurrencyError => error
      errors << "Invalid contribution amount"
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
    ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    erb :contribute_success, :locals => { :ad => ad }
  end

  post "/ads/:id/contribute_submit" do
    ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    halt 400 unless params[:amount] && params[:token]
    halt 400 unless params[:amount].to_i.to_s == params[:amount].to_s
    halt 400 if production? && ad.id == 52 # Gary Johnson

    Stripe.api_key = STRIPE_SECRET_KEY

    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      charge = Stripe::Charge.create(
        :amount => params[:amount],
        :currency => "usd",
        :card => params[:token],
        :description => "#{current_user.email} -- #{ad.title}"
      )
    rescue Stripe::InvalidRequestError => error
      flash[:errors] = [error.message]
      redirect "/ads/#{ad.public_id}/contribute"
    rescue Stripe::CardError
      flash[:errors] = ["There was an error processing your payment. Please use a different card."]
      redirect "/ads/#{ad.public_id}/contribute"
    end

    # TODO(dmac): Validate the payment actually went through.
    Payment.create(:ad_id => ad.id, :user_id => current_user.id, :amount => params[:amount])

    redirect "/ads/#{ad.public_id}/contribute_success"
  end
end
