Rails.application.routes.draw do
  root "books#index"

  resource :session
  resources :books
  resources :categories, except: [ :show ]
  get "admin", to: "admin#index", as: :admin

  get "up" => "rails/health#show", as: :rails_health_check
end
