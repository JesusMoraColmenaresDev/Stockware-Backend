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

  resources :products, only: [ :index, :create, :update, :destroy, :show ]
  resources :categories, only: [ :index, :show, :create, :update, :destroy ] do
    get "all", on: :collection
  end
  resources :stock_movements, only: [ :index, :show, :create ] do
    get "by_user/:user_id", to: "stock_movements#by_user", on: :collection # Nos deberia dar una forma de obtener todas las de 1 usuario, pa la pantalla de admin quizas
    get "by_product/:product_id", to: "stock_movements#by_product"
  end

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  resources :users, only: [ :index, :show, :update ] do # GetAll, Get, Update/Patch
    get "all", on: :collection
  end
end
