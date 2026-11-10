Rails.application.routes.draw do
  root "books#index"

  resource :session
  resources :books

  get "up" => "rails/health#show", as: :rails_health_check
end
