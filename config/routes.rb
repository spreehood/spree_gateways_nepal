Spree::Core::Engine.add_routes do
  # Add your extension routes here
  post '/khalti', :to => "khalti#payment", :as => :khalti_payment
  get '/khalti/payment_config', :to => "khalti#khalti_payment_config", :as => :khalti_payment_config, format: :json

 # config/routes.rb
  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :storefront do
        resource :khalti, only: [] do
          collection do
            post :payment_initiate, to: 'khalti#payment_initiate'
            post :update, to: 'khalti#update'
          end
        end

        resources :stripe_payment, only: :create
      end
    end
  end
end
