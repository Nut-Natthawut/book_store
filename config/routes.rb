Rails.application.routes.draw do
  root "books#index"

  resource :session
  resources :books
  resources :categories, except: [ :show ]
  resources :markets, except: [ :show ]
  resources :users, only: [ :new, :create ]
  get "admin", to: "admin#index", as: :admin

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resource :session, only: [ :new, :create, :destroy ]
      resources :books, :categories, :markets, :users, except: [ :new, :edit ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
