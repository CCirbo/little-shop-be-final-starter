Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  get "api/v1/merchants/:merchant_id/coupons", to: "api/v1/merchants/coupons#index"
  get "api/v1/merchants/:merchant_id/coupons/:coupon_id", to: "api/v1/merchants/coupons#show"
  post "api/v1/merchants/:merchant_id/coupons", to: "api/v1/merchants/coupons#create"
  patch "api/v1/merchants/:merchant_id/coupons/:coupon_id", to: "api/v1/merchants/coupons#update"
  patch "api/v1/merchants/:merchant_id/coupons/:coupon_id/activate", to: "api/v1/merchants/coupons#change_status"
  patch "api/v1/merchants/:merchant_id/coupons/:coupon_id/deactivate", to: "api/v1/merchants/coupons#change_status"
  # custom one for activate
  # custom one for deactivate



  namespace :api do
    namespace :v1 do
      namespace :items do    #items search
        resources :find, only: :index, controller: :search, action: :show
        resources :find_all, only: :index, controller: :search
      end
      resources :items, except: [:new, :edit] do  #standard items routes with merchant
        get "/merchant", to: "items/merchants#show"
      end
      namespace :merchants do #merchants search 
        resources :find, only: :index, controller: :search, action: :show
        resources :find_all, only: :index, controller: :search
      end
      resources :merchants, except: [:new, :edit] do #merchant standard routes
        resources :items, only: :index, controller: "merchants/items"
        resources :customers, only: :index, controller: "merchants/customers"
        resources :invoices, only: :index, controller: "merchants/invoices"
        #coupon routes with merchant
        # resources :coupons, only: [:index, :show, :create, :update] do
        #   member do
        #     patch :activate  #custom route for activate
        #     patch :deactivate  #custom route for deactivate
        #   end
        # end
      end
    end
  end

end
