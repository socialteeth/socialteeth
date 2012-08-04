class SocialTeeth < Sinatra::Base
  get "/ads/:id/contribute" do
    ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    erb :contribute, :locals => { :ad => ad }
  end

  get "/ads/:id/contribute_success" do
    ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    erb :contribute_success, :locals => { :ad => ad }
  end

  post "/ads/:id/contribute" do
    ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    errors = enforce_required_params([:dollar_amount, :cent_amount, :stripe_token])
    begin
      dollars = Integer(params[:dollar_amount])
      cents = Integer(params[:cent_amount])
      if params[:cent_amount] && params[:cent_amount].size != 2
        errors << "Invalid contribution amount: $#{dollars}.#{cents}"
      end
    rescue ArgumentError => error
      errors << "Invalid contribution amount"
    end

    if errors.empty?
      Stripe.api_key = STRIPE_TEST_SECRET_KEY

      token = params[:stripe_token]
      amount_in_cents = dollars * 100 + cents

      # Create the charge on Stripe's servers - this will charge the user's card
      charge = Stripe::Charge.create(
        :amount => amount_in_cents,
        :currency => "usd",
        :card => token,
        :description => "#{current_user.email} -- #{ad.title} -- $#{dollars}.#{cents}"
      )

      redirect "/ads/#{ad.public_id}/contribute_success"
    else
      flash[:errors] = errors
      redirect "/ads/#{ad.public_id}/contribute"
    end
  end
end
