Spree::Core::Engine.add_routes do
  # Add your extension routes here
  post '/khalti', :to => "khalti#payment", :as => :khalti_payment
  get '/khalti/payment_config', :to => "khalti#khalti_payment_config", :as => :khalti_payment_config, format: :json

  get '/esewa-payment', :to => "esewa#payment", :as => :esewa_payment
end
