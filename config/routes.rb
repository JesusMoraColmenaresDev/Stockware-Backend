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
  resources :categories, only: [ :index, :show, :create, :update, :destroy ]

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }
end
