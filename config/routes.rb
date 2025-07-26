Rails.application.routes.draw do
  # get "categories/index"
  # get "categories/show"
  # get "categories/create"
  # get "categories/update"
  # get "categories/destroy"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :products, only: [ :index, :create, :update, :destroy, :show ], defaults: { format: :json }
  resources :categories, only: [ :index, :show, :create, :update, :destroy ], defaults: { format: :json } do
    get "all", on: :collection
  end
  resources :stock_movements, only: [ :index, :show, :create ], defaults: { format: :json } do
    get "by_user/:user_id", to: "stock_movements#by_user", on: :collection
    get "by_product/:product_id", to: "stock_movements#by_product", on: :collection
  end

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  resources :users, only: [ :index, :show, :update ], defaults: { format: :json } do # GetAll, Get, Update/Patch
    get "all", on: :collection
  end
end
