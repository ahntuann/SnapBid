Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

   root "home#index"

  namespace :admin do
    resource :settings, only: %i[show edit update]
  end

  # resource :otp_session, only: %i[new create] do
  #   get :verify
  #   post :confirm
  # end

  resource :email_verification, only: %i[new create] do
    post :resend
  end

  namespace :seller do
    get "listings/index"
    get "listings/new"
    get "listings/create"
    get "listings/edit"
    get "listings/update"
    get "listings/show"
    resources :listings do
      post :submit_ai_verification, on: :member
    end
  end
end
