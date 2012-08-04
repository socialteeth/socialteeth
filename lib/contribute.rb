class SocialTeeth < Sinatra::Base
  get "/ads/:id/contribute" do
    ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    erb :contribute, :locals => { :ad => ad }
  end

  post "/ads/:id/contribute" do
    ensure_signed_in
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    errors = enforce_required_params([:contribution_amount, :stripe_token])
    errors << "Invalid dollar amount" unless params[:contribution_amount].is_currency?

    flash[:errors] = errors
    redirect "/ads/#{ad.public_id}/contribute"
  end
end
