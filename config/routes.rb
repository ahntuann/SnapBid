Rails.application.routes.draw do
  devise_for :users
  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

   root "home#index"

  namespace :admin do
    resource :settings, only: %i[show edit update]
  end
end
